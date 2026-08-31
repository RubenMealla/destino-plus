import 'package:destino_plus/app/monitoreo/configuracion_monitoreo.dart';
import 'package:destino_plus/app/monitoreo/inicializador_monitoreo.dart';
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

void main() {
  group('InicializadorMonitoreo', () {
    test('sin DSN ejecuta la app sin inicializar la plataforma', () async {
      final plataforma = _PlataformaMonitoreoFalsa();
      var aplicacionesEjecutadas = 0;

      final inicializador = InicializadorMonitoreo(
        configuracion: const ConfiguracionMonitoreo(
          dsn: '',
          entorno: 'development',
        ),
        plataforma: plataforma,
      );

      await inicializador.iniciar(() async {
        aplicacionesEjecutadas += 1;
      });

      expect(aplicacionesEjecutadas, 1);
      expect(plataforma.inicializaciones, 0);
    });

    test('con DSN inicializa monitoreo y ejecuta la app una vez', () async {
      final plataforma = _PlataformaMonitoreoFalsa();
      var aplicacionesEjecutadas = 0;

      final inicializador = InicializadorMonitoreo(
        configuracion: const ConfiguracionMonitoreo(
          dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
          entorno: 'production',
        ),
        plataforma: plataforma,
      );

      await inicializador.iniciar(() async {
        aplicacionesEjecutadas += 1;
      });

      expect(plataforma.inicializaciones, 1);
      expect(aplicacionesEjecutadas, 1);
      expect(
        plataforma.ultimaConfiguracion?.entornoNormalizado,
        'production',
      );
    });

    test('la configuración habilitada llega sin modificar al adaptador',
        () async {
      final plataforma = _PlataformaMonitoreoFalsa();

      const configuracion = ConfiguracionMonitoreo(
        dsn: '  https://clave-publica@ejemplo.ingest.sentry.io/456  ',
        entorno: 'staging',
      );

      await InicializadorMonitoreo(
        configuracion: configuracion,
        plataforma: plataforma,
      ).iniciar(() async {});

      expect(plataforma.ultimaConfiguracion, same(configuracion));
      expect(plataforma.ultimaConfiguracion?.dsn, configuracion.dsn);
      expect(
        plataforma.ultimaConfiguracion?.entornoNormalizado,
        'staging',
      );
    });
  });
}
