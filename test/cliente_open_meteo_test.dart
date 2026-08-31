import 'package:destino_plus/features/clima/servicios/cliente_open_meteo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ClienteOpenMeteo', () {
    test('convierte resultados de geocodificación', () async {
      final httpClient = MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.path, '/v1/search');
        expect(request.url.queryParameters['language'], 'es');
        expect(request.url.queryParameters['name'], 'Tarija');

        return http.Response(
          '''
          {
            "results": [
              {
                "id": 3907584,
                "name": "Tarija",
                "latitude": -21.53549,
                "longitude": -64.72956,
                "country": "Bolivia",
                "country_code": "BO",
                "admin1": "Tarija",
                "timezone": "America/La_Paz"
              }
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final cliente = ClienteOpenMeteo(clienteHttp: httpClient);

      final resultados = await cliente.buscarUbicaciones('Tarija');

      expect(resultados, hasLength(1));
      expect(resultados.first.nombre, 'Tarija');
      expect(resultados.first.latitud, closeTo(-21.53549, 0.00001));
      expect(resultados.first.longitud, closeTo(-64.72956, 0.00001));
      expect(resultados.first.pais, 'Bolivia');
      expect(resultados.first.zonaHoraria, 'America/La_Paz');
    });

    test('consulta corta devuelve lista vacía sin hacer red', () async {
      final httpClient = MockClient((request) async {
        fail('No debería realizar una petición HTTP.');
      });

      final cliente = ClienteOpenMeteo(clienteHttp: httpClient);

      expect(await cliente.buscarUbicaciones('T'), isEmpty);
    });

    test('convierte clima actual y pronóstico diario', () async {
      final httpClient = MockClient((request) async {
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.path, '/v1/forecast');
        expect(request.url.queryParameters['timezone'], 'auto');
        expect(request.url.queryParameters['forecast_days'], '7');

        return http.Response(
          '''
          {
            "latitude": -21.5,
            "longitude": -64.7,
            "timezone": "America/La_Paz",
            "current": {
              "time": "2026-08-31T11:00",
              "temperature_2m": 20.4,
              "relative_humidity_2m": 42,
              "apparent_temperature": 19.8,
              "is_day": 1,
              "weather_code": 1,
              "wind_speed_10m": 12.5
            },
            "daily": {
              "time": ["2026-08-31", "2026-09-01"],
              "weather_code": [1, 3],
              "temperature_2m_max": [24.1, 22.3],
              "temperature_2m_min": [8.2, 9.0],
              "precipitation_probability_max": [5, 20]
            }
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final cliente = ClienteOpenMeteo(clienteHttp: httpClient);

      final pronostico = await cliente.obtenerPronostico(
        latitud: -21.5,
        longitud: -64.7,
      );

      expect(pronostico.zonaHoraria, 'America/La_Paz');
      expect(pronostico.actual.temperatura, 20.4);
      expect(pronostico.actual.humedadRelativa, 42);
      expect(pronostico.actual.esDeDia, isTrue);
      expect(pronostico.dias, hasLength(2));
      expect(pronostico.dias.first.temperaturaMaxima, 24.1);
      expect(pronostico.dias[1].probabilidadPrecipitacion, 20);
    });

    test('propaga el motivo de un error HTTP de Open-Meteo', () async {
      final httpClient = MockClient((request) async {
        return http.Response(
          '{"error":true,"reason":"Invalid latitude"}',
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final cliente = ClienteOpenMeteo(clienteHttp: httpClient);

      expect(
        () => cliente.obtenerPronostico(
          latitud: 20,
          longitud: -64,
        ),
        throwsA(
          isA<ExcepcionClima>().having(
            (error) => error.mensaje,
            'mensaje',
            contains('Invalid latitude'),
          ),
        ),
      );
    });

    test('rechaza coordenadas imposibles antes de consultar', () async {
      final httpClient = MockClient((request) async {
        fail('No debería realizar una petición HTTP.');
      });

      final cliente = ClienteOpenMeteo(clienteHttp: httpClient);

      expect(
        () => cliente.obtenerPronostico(
          latitud: 91,
          longitud: 0,
        ),
        throwsA(isA<ExcepcionClima>()),
      );

      expect(
        () => cliente.obtenerPronostico(
          latitud: 0,
          longitud: 181,
        ),
        throwsA(isA<ExcepcionClima>()),
      );
    });
  });
}
