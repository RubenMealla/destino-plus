import 'package:destino_plus/app/monitoreo/configuracion_monitoreo.dart';
import 'package:destino_plus/app/monitoreo/inicializador_monitoreo.dart';
import 'package:destino_plus/app/monitoreo/verificador_monitoreo.dart';
import 'package:flutter_test/flutter_test.dart';

class _PlataformaMonitoreoFalsa implements PlataformaMonitoreo {
  int inicializaciones = 0;
  ConfiguracionMonitoreo? ultimaConfiguracion;

  @override
  Future<void> iniciar({
    required ConfiguracionMonitoreo configuracion,
    required EjecutorAplicacion ejecutarAplicacion,
  }) async {
    inicializaciones += 1;
    ultimaConfiguracion = configuracion;
    await ejecutarAplicacion();
  }
}

class _VerificadorMonitoreoFalso implements VerificadorMonitoreo {
  int eventosEnviados = 0;
  ConfiguracionMonitoreo? ultimaConfiguracion;

  @override
  Future<void> enviarEventoPrueba(
    ConfiguracionMonitoreo configuracion,
  ) async {
    eventosEnviados += 1;
    ultimaConfiguracion = configuracion;
  }
}

void main() {
  group('InicializadorMonitoreo', () {
    test('sin DSN ejecuta la app sin inicializar plataforma ni verificador',
        () async {
      final plataforma = _PlataformaMonitoreoFalsa();
      final verificador = _VerificadorMonitoreoFalso();
      var aplicacionesEjecutadas = 0;

      final inicializador = InicializadorMonitoreo(
        configuracion: const ConfiguracionMonitoreo(
          dsn: '',
          entorno: 'development',
          eventoPruebaSolicitado: true,
        ),
        plataforma: plataforma,
        verificador: verificador,
      );

      await inicializador.iniciar(() async {
        aplicacionesEjecutadas += 1;
      });

      expect(aplicacionesEjecutadas, 1);
      expect(plataforma.inicializaciones, 0);
      expect(verificador.eventosEnviados, 0);
    });

    test('con DSN inicializa monitoreo y ejecuta la app una vez', () async {
      final plataforma = _PlataformaMonitoreoFalsa();
      final verificador = _VerificadorMonitoreoFalso();
      var aplicacionesEjecutadas = 0;

      final inicializador = InicializadorMonitoreo(
        configuracion: const ConfiguracionMonitoreo(
          dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
          entorno: 'production',
        ),
        plataforma: plataforma,
        verificador: verificador,
      );

      await inicializador.iniciar(() async {
        aplicacionesEjecutadas += 1;
      });

      expect(plataforma.inicializaciones, 1);
      expect(aplicacionesEjecutadas, 1);
      expect(verificador.eventosEnviados, 0);
      expect(
        plataforma.ultimaConfiguracion?.entornoNormalizado,
        'production',
      );
    });

    test('envía exactamente un evento controlado cuando está habilitado',
        () async {
      final plataforma = _PlataformaMonitoreoFalsa();
      final verificador = _VerificadorMonitoreoFalso();

      const configuracion = ConfiguracionMonitoreo(
        dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
        entorno: 'development',
        eventoPruebaSolicitado: true,
      );

      await InicializadorMonitoreo(
        configuracion: configuracion,
        plataforma: plataforma,
        verificador: verificador,
      ).iniciar(() async {});

      expect(plataforma.inicializaciones, 1);
      expect(verificador.eventosEnviados, 1);
      expect(verificador.ultimaConfiguracion, same(configuracion));
    });

    test('production bloquea el evento aunque se haya solicitado', () async {
      final plataforma = _PlataformaMonitoreoFalsa();
      final verificador = _VerificadorMonitoreoFalso();

      await InicializadorMonitoreo(
        configuracion: const ConfiguracionMonitoreo(
          dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
          entorno: 'production',
          eventoPruebaSolicitado: true,
        ),
        plataforma: plataforma,
        verificador: verificador,
      ).iniciar(() async {});

      expect(plataforma.inicializaciones, 1);
      expect(verificador.eventosEnviados, 0);
    });
  });
}
