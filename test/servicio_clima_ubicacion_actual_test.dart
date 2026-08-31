import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_destino.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_ubicacion_actual.dart';
import 'package:destino_plus/features/ubicacion/modelos/ubicacion_actual.dart';
import 'package:destino_plus/features/ubicacion/servicios/servicio_geolocalizacion.dart';
import 'package:flutter_test/flutter_test.dart';

class _UbicacionFalsa implements FuenteUbicacionActual {
  const _UbicacionFalsa(this.ubicacion);

  final UbicacionActual ubicacion;

  @override
  Future<UbicacionActual> obtenerUbicacionActual() async => ubicacion;
}

class _ClimaCoordenadasFalso implements FuenteClimaCoordenadas {
  double? latitudRecibida;
  double? longitudRecibida;

  @override
  Future<ClimaDestino> consultarCoordenadas({
    required double latitud,
    required double longitud,
    String nombre = 'Mi ubicación actual',
  }) async {
    latitudRecibida = latitud;
    longitudRecibida = longitud;

    return ClimaDestino(
      consulta: nombre,
      ubicacion: UbicacionClima(
        id: 0,
        nombre: nombre,
        latitud: latitud,
        longitud: longitud,
      ),
      pronostico: PronosticoClima.fromMap({
        'latitude': latitud,
        'longitude': longitud,
        'timezone': 'America/La_Paz',
        'current': {
          'time': '2026-08-31T12:00',
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

void main() {
  test('usa las coordenadas del dispositivo para consultar Open-Meteo',
      () async {
    final ubicacion = UbicacionActual(
      latitud: -21.535,
      longitud: -64.729,
      precisionMetros: 7.5,
      fechaHora: DateTime(2026, 8, 31, 12),
    );
    final clima = _ClimaCoordenadasFalso();

    final resultado = await ServicioClimaUbicacionActual(
      fuenteUbicacion: _UbicacionFalsa(ubicacion),
      fuenteClima: clima,
    ).consultar();

    expect(clima.latitudRecibida, -21.535);
    expect(clima.longitudRecibida, -64.729);
    expect(resultado.ubicacion.precisionMetros, 7.5);
    expect(resultado.clima.pronostico.actual.temperatura, 21);
    expect(resultado.clima.ubicacion.nombre, 'Mi ubicación actual');
  });
}
