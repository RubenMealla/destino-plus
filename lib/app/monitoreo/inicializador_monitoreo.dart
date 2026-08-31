import 'package:sentry_flutter/sentry_flutter.dart';

import 'configuracion_monitoreo.dart';

typedef EjecutorAplicacion = Future<void> Function();

/// Adaptador mínimo para desacoplar el arranque de Destino+ del SDK concreto.
abstract interface class PlataformaMonitoreo {
  Future<void> iniciar({
    required ConfiguracionMonitoreo configuracion,
    required EjecutorAplicacion ejecutarAplicacion,
  });
}

/// Implementación real de monitoreo mediante Sentry para Flutter.
class PlataformaMonitoreoSentry implements PlataformaMonitoreo {
  const PlataformaMonitoreoSentry();

  @override
  Future<void> iniciar({
    required ConfiguracionMonitoreo configuracion,
    required EjecutorAplicacion ejecutarAplicacion,
  }) {
    return SentryFlutter.init(
      (options) {
        options.dsn = configuracion.dsn.trim();
        options.environment = configuracion.entornoNormalizado;

        // Destino+ utiliza Sentry únicamente para diagnóstico técnico.
        options.sendDefaultPii = false;
        options.attachScreenshot = false;
        options.attachViewHierarchy = false;

        // En esta primera integración no se activa monitoreo de rendimiento.
        // Esto evita generar telemetría innecesaria para el alcance académico.
        options.tracesSampleRate = 0;
      },
      appRunner: ejecutarAplicacion,
    );
  }
}

/// Decide si Destino+ debe arrancar dentro de Sentry o de forma normal.
///
/// La ausencia de DSN es un estado válido: la aplicación debe seguir
/// funcionando aunque el monitoreo remoto no esté configurado.
class InicializadorMonitoreo {
  InicializadorMonitoreo({
    required this.configuracion,
    PlataformaMonitoreo? plataforma,
  }) : _plataforma = plataforma ?? const PlataformaMonitoreoSentry();

  final ConfiguracionMonitoreo configuracion;
  final PlataformaMonitoreo _plataforma;

  Future<void> iniciar(EjecutorAplicacion ejecutarAplicacion) {
    if (!configuracion.habilitado) {
      return ejecutarAplicacion();
    }

    return _plataforma.iniciar(
      configuracion: configuracion,
      ejecutarAplicacion: ejecutarAplicacion,
    );
  }
}
