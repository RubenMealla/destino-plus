import 'package:destino_plus/app/monitoreo/configuracion_monitoreo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfiguracionMonitoreo', () {
    test('sin DSN mantiene el monitoreo remoto deshabilitado', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: '',
        entorno: 'development',
      );

      expect(configuracion.habilitado, isFalse);
      expect(configuracion.entornoNormalizado, 'development');
      expect(configuracion.permiteEventoPrueba, isFalse);
    });

    test('un DSN configurado habilita el monitoreo remoto', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
        entorno: 'production',
      );

      expect(configuracion.habilitado, isTrue);
      expect(configuracion.entornoNormalizado, 'production');
    });

    test('ignora espacios al determinar si existe un DSN', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: '   ',
        entorno: 'development',
      );

      expect(configuracion.habilitado, isFalse);
    });

    test('entorno vacío vuelve al valor development', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
        entorno: '   ',
      );

      expect(configuracion.entornoNormalizado, 'development');
    });

    test('permite evento de prueba solo si fue solicitado en desarrollo', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
        entorno: 'development',
        eventoPruebaSolicitado: true,
      );

      expect(configuracion.permiteEventoPrueba, isTrue);
    });

    test('bloquea evento de prueba en production', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
        entorno: 'production',
        eventoPruebaSolicitado: true,
      );

      expect(configuracion.permiteEventoPrueba, isFalse);
    });

    test('no envía evento si no fue solicitado explícitamente', () {
      const configuracion = ConfiguracionMonitoreo(
        dsn: 'https://clave-publica@ejemplo.ingest.sentry.io/123',
        entorno: 'development',
      );

      expect(configuracion.permiteEventoPrueba, isFalse);
    });
  });
}
