import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/cliente_open_meteo.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_destino.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_ubicacion_actual.dart';
import 'package:destino_plus/features/ubicacion/modelos/ubicacion_actual.dart';
import 'package:destino_plus/features/ubicacion/servicios/servicio_geolocalizacion.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteUbicacionControlada implements FuenteUbicacionActual {
  _FuenteUbicacionControlada({
    this.ubicacion,
    this.error,
  });

  final UbicacionActual? ubicacion;
  final Object? error;
  int llamadas = 0;

  @override
  Future<UbicacionActual> obtenerUbicacionActual() async {
    llamadas += 1;

    if (error != null) {
      return Future<UbicacionActual>.error(error!);
    }

    return ubicacion!;
  }
}

class _FuenteClimaCoordenadasControlada
    implements FuenteClimaCoordenadas {
  _FuenteClimaCoordenadasControlada({
    this.error,
  });

  final Object? error;
  int llamadas = 0;
  double? ultimaLatitud;
  double? ultimaLongitud;

  @override
  Future<ClimaDestino> consultarCoordenadas({
    required double latitud,
    required double longitud,
    String nombre = 'Mi ubicación actual',
  }) async {
    llamadas += 1;
    ultimaLatitud = latitud;
    ultimaLongitud = longitud;

    if (error != null) {
      return Future<ClimaDestino>.error(error!);
    }

    return ClimaDestino(
      consulta: nombre,
      ubicacion: UbicacionClima(
        id: 0,
        nombre: nombre,
        latitud: latitud,
        longitud: longitud,
        zonaHoraria: 'America/La_Paz',
      ),
      pronostico: PronosticoClima.fromMap({
        'latitude': latitud,
        'longitude': longitud,
        'timezone': 'America/La_Paz',
        'current': {
          'time': '2026-08-31T14:00',
          'temperature_2m': 21.0,
          'relative_humidity_2m': 40,
          'apparent_temperature': 20.0,
          'is_day': 1,
          'weather_code': 1,
          'wind_speed_10m': 10.0,
        },
        'daily': {
          'time': ['2026-08-31'],
          'temperature_2m_max': [25.0],
          'temperature_2m_min': [8.0],
          'precipitation_probability_max': [5],
          'weather_code': [1],
        },
      }),
    );
  }
}

UbicacionActual _ubicacionValida() {
  return UbicacionActual(
    latitud: -21.535,
    longitud: -64.729,
    precisionMetros: 9.0,
    fechaHora: DateTime(2026, 8, 31, 14),
  );
}

void main() {
  group('ServicioClimaUbicacionActual', () {
    test('si falla la ubicación no consulta Open-Meteo', () async {
      const errorUbicacion = ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.permisoDenegado,
        mensaje: 'Permiso denegado.',
      );

      final ubicacion = _FuenteUbicacionControlada(
        error: errorUbicacion,
      );
      final clima = _FuenteClimaCoordenadasControlada();

      final servicio = ServicioClimaUbicacionActual(
        fuenteUbicacion: ubicacion,
        fuenteClima: clima,
      );

      await expectLater(
        servicio.consultar(),
        throwsA(
          isA<ExcepcionUbicacion>().having(
            (error) => error.tipo,
            'tipo',
            TipoErrorUbicacion.permisoDenegado,
          ),
        ),
      );

      expect(ubicacion.llamadas, 1);
      expect(clima.llamadas, 0);
    });

    test('si falla Open-Meteo conserva el error meteorológico', () async {
      final ubicacion = _FuenteUbicacionControlada(
        ubicacion: _ubicacionValida(),
      );
      final clima = _FuenteClimaCoordenadasControlada(
        error: const ExcepcionClima(
          'No fue posible conectar con el servicio del clima.',
        ),
      );

      final servicio = ServicioClimaUbicacionActual(
        fuenteUbicacion: ubicacion,
        fuenteClima: clima,
      );

      await expectLater(
        servicio.consultar(),
        throwsA(
          isA<ExcepcionClima>().having(
            (error) => error.mensaje,
            'mensaje',
            contains('conectar con el servicio del clima'),
          ),
        ),
      );

      expect(ubicacion.llamadas, 1);
      expect(clima.llamadas, 1);
      expect(clima.ultimaLatitud, -21.535);
      expect(clima.ultimaLongitud, -64.729);
    });

    test('en éxito conserva ubicación y clima en un mismo resultado', () async {
      final ubicacionReal = _ubicacionValida();
      final ubicacion = _FuenteUbicacionControlada(
        ubicacion: ubicacionReal,
      );
      final clima = _FuenteClimaCoordenadasControlada();

      final resultado = await ServicioClimaUbicacionActual(
        fuenteUbicacion: ubicacion,
        fuenteClima: clima,
      ).consultar();

      expect(resultado.ubicacion, same(ubicacionReal));
      expect(resultado.ubicacion.precisionMetros, 9);
      expect(resultado.clima.ubicacion.nombre, 'Mi ubicación actual');
      expect(resultado.clima.pronostico.actual.temperatura, 21);
      expect(clima.llamadas, 1);
    });
  });
}
