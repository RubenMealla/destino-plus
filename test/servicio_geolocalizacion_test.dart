import 'dart:async';

import 'package:destino_plus/features/ubicacion/modelos/ubicacion_actual.dart';
import 'package:destino_plus/features/ubicacion/servicios/servicio_geolocalizacion.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteGeolocalizacionFalsa implements FuenteGeolocalizacion {
  bool servicioActivo = true;
  PermisoUbicacion permisoInicial = PermisoUbicacion.mientrasUso;
  PermisoUbicacion permisoSolicitado = PermisoUbicacion.mientrasUso;
  bool seSolicitoPermiso = false;
  Object? errorPosicion;

  LecturaGeolocalizacion lectura = LecturaGeolocalizacion(
    latitud: -21.535,
    longitud: -64.729,
    precisionMetros: 8.5,
    fechaHora: DateTime(2026, 8, 31, 12),
  );

  @override
  Future<bool> servicioHabilitado() async => servicioActivo;

  @override
  Future<PermisoUbicacion> verificarPermiso() async => permisoInicial;

  @override
  Future<PermisoUbicacion> solicitarPermiso() async {
    seSolicitoPermiso = true;
    return permisoSolicitado;
  }

  @override
  Future<LecturaGeolocalizacion> obtenerPosicionActual() async {
    if (errorPosicion != null) {
      return Future<LecturaGeolocalizacion>.error(errorPosicion!);
    }

    return lectura;
  }
}

void main() {
  group('ServicioGeolocalizacion', () {
    test('devuelve coordenadas cuando servicio y permiso están disponibles',
        () async {
      final fuente = _FuenteGeolocalizacionFalsa();
      final servicio = ServicioGeolocalizacion(fuente: fuente);

      final ubicacion = await servicio.obtenerUbicacionActual();

      expect(ubicacion.latitud, -21.535);
      expect(ubicacion.longitud, -64.729);
      expect(ubicacion.precisionMetros, 8.5);
      expect(fuente.seSolicitoPermiso, isFalse);
    });

    test('solicita permiso cuando todavía está denegado', () async {
      final fuente = _FuenteGeolocalizacionFalsa()
        ..permisoInicial = PermisoUbicacion.denegado
        ..permisoSolicitado = PermisoUbicacion.mientrasUso;

      final ubicacion = await ServicioGeolocalizacion(
        fuente: fuente,
      ).obtenerUbicacionActual();

      expect(fuente.seSolicitoPermiso, isTrue);
      expect(ubicacion.latitud, -21.535);
    });

    test('informa cuando el servicio de ubicación está desactivado', () async {
      final fuente = _FuenteGeolocalizacionFalsa()
        ..servicioActivo = false;

      expect(
        () => ServicioGeolocalizacion(
          fuente: fuente,
        ).obtenerUbicacionActual(),
        throwsA(
          isA<ExcepcionUbicacion>().having(
            (error) => error.tipo,
            'tipo',
            TipoErrorUbicacion.servicioDeshabilitado,
          ),
        ),
      );
    });

    test('informa cuando el usuario niega el permiso', () async {
      final fuente = _FuenteGeolocalizacionFalsa()
        ..permisoInicial = PermisoUbicacion.denegado
        ..permisoSolicitado = PermisoUbicacion.denegado;

      expect(
        () => ServicioGeolocalizacion(
          fuente: fuente,
        ).obtenerUbicacionActual(),
        throwsA(
          isA<ExcepcionUbicacion>().having(
            (error) => error.tipo,
            'tipo',
            TipoErrorUbicacion.permisoDenegado,
          ),
        ),
      );
    });

    test('distingue permiso bloqueado permanentemente', () async {
      final fuente = _FuenteGeolocalizacionFalsa()
        ..permisoInicial = PermisoUbicacion.denegadoPermanentemente;

      expect(
        () => ServicioGeolocalizacion(
          fuente: fuente,
        ).obtenerUbicacionActual(),
        throwsA(
          isA<ExcepcionUbicacion>().having(
            (error) => error.tipo,
            'tipo',
            TipoErrorUbicacion.permisoDenegadoPermanentemente,
          ),
        ),
      );
    });

    test('traduce timeout de posición a error de dominio', () async {
      final fuente = _FuenteGeolocalizacionFalsa()
        ..errorPosicion = TimeoutException('GPS lento');

      expect(
        () => ServicioGeolocalizacion(
          fuente: fuente,
        ).obtenerUbicacionActual(),
        throwsA(
          isA<ExcepcionUbicacion>().having(
            (error) => error.tipo,
            'tipo',
            TipoErrorUbicacion.tiempoAgotado,
          ),
        ),
      );
    });
  });
}
