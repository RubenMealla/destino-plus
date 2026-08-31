import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UbicacionClima construye un nombre legible', () {
    final ubicacion = UbicacionClima.fromMap({
      'id': 1,
      'name': 'Cercado',
      'latitude': -21.5,
      'longitude': -64.7,
      'admin1': 'Tarija',
      'country': 'Bolivia',
      'country_code': 'BO',
      'timezone': 'America/La_Paz',
    });

    expect(ubicacion.nombreCompleto, 'Cercado, Tarija, Bolivia');
  });

  test('PronosticoClima usa la menor longitud de arreglos diarios', () {
    final pronostico = PronosticoClima.fromMap({
      'latitude': -21.5,
      'longitude': -64.7,
      'timezone': 'America/La_Paz',
      'current': {
        'time': '2026-08-31T11:00',
        'temperature_2m': 20,
        'relative_humidity_2m': 40,
        'apparent_temperature': 19,
        'is_day': 1,
        'weather_code': 0,
        'wind_speed_10m': 5,
      },
      'daily': {
        'time': ['2026-08-31', '2026-09-01'],
        'temperature_2m_max': [24, 25],
        'temperature_2m_min': [8],
        'precipitation_probability_max': [0, 10],
        'weather_code': [0, 1],
      },
    });

    expect(pronostico.dias, hasLength(1));
    expect(pronostico.dias.first.fecha, DateTime(2026, 8, 31));
  });
}
