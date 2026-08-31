import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/cliente_open_meteo.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_destino.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteClimaFalsa implements FuenteClimaRemota {
  _FuenteClimaFalsa({
    required this.respuestasBusqueda,
    required this.pronostico,
  });

  final Map<String, List<UbicacionClima>> respuestasBusqueda;
  final PronosticoClima pronostico;
  final List<String> consultasRealizadas = [];
  double? latitudConsultada;
  double? longitudConsultada;

  @override
  Future<List<UbicacionClima>> buscarUbicaciones(
    String consulta, {
    int limite = 5,
  }) async {
    consultasRealizadas.add(consulta);
    return respuestasBusqueda[consulta] ?? const [];
  }

  @override
  Future<PronosticoClima> obtenerPronostico({
    required double latitud,
    required double longitud,
  }) async {
    latitudConsultada = latitud;
    longitudConsultada = longitud;
    return pronostico;
  }
}

UbicacionClima _ubicacion({
  required int id,
  required String nombre,
  required double latitud,
  required double longitud,
  String? region,
  String? pais,
}) {
  return UbicacionClima(
    id: id,
    nombre: nombre,
    latitud: latitud,
    longitud: longitud,
    region: region,
    pais: pais,
  );
}

PronosticoClima _pronostico() {
  return PronosticoClima.fromMap({
    'latitude': -21.535,
    'longitude': -64.729,
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
  });
}

void main() {
  group('ServicioClimaDestino', () {
    test('consulta ubicación y luego obtiene su pronóstico', () async {
      final tarija = _ubicacion(
        id: 1,
        nombre: 'Tarija',
        latitud: -21.535,
        longitud: -64.729,
        region: 'Tarija',
        pais: 'Bolivia',
      );

      final fuente = _FuenteClimaFalsa(
        respuestasBusqueda: {
          'Tarija, Bolivia': [tarija],
        },
        pronostico: _pronostico(),
      );

      final servicio = ServicioClimaDestino(fuente: fuente);
      final resultado = await servicio.consultar(' Tarija, Bolivia ');

      expect(resultado.consulta, 'Tarija, Bolivia');
      expect(resultado.ubicacion.nombre, 'Tarija');
      expect(resultado.pronostico.actual.temperatura, 21);
      expect(fuente.latitudConsultada, tarija.latitud);
      expect(fuente.longitudConsultada, tarija.longitud);
    });

    test('elige la opción que mejor coincide con país y ciudad', () async {
      final tarijaEspaña = _ubicacion(
        id: 1,
        nombre: 'Tarija',
        latitud: 40,
        longitud: -3,
        pais: 'España',
      );
      final tarijaBolivia = _ubicacion(
        id: 2,
        nombre: 'Tarija',
        latitud: -21.535,
        longitud: -64.729,
        region: 'Tarija',
        pais: 'Bolivia',
      );

      final fuente = _FuenteClimaFalsa(
        respuestasBusqueda: {
          'Tarija, Bolivia': [tarijaEspaña, tarijaBolivia],
        },
        pronostico: _pronostico(),
      );

      final resultado = await ServicioClimaDestino(
        fuente: fuente,
      ).consultar('Tarija, Bolivia');

      expect(resultado.ubicacion.id, 2);
      expect(fuente.latitudConsultada, tarijaBolivia.latitud);
    });

    test('reintenta con la primera parte si el destino tiene coma', () async {
      final tarija = _ubicacion(
        id: 1,
        nombre: 'Tarija',
        latitud: -21.535,
        longitud: -64.729,
        pais: 'Bolivia',
      );

      final fuente = _FuenteClimaFalsa(
        respuestasBusqueda: {
          'Tarija, Bolivia': const [],
          'Tarija': [tarija],
        },
        pronostico: _pronostico(),
      );

      final resultado = await ServicioClimaDestino(
        fuente: fuente,
      ).consultar('Tarija, Bolivia');

      expect(
        fuente.consultasRealizadas,
        ['Tarija, Bolivia', 'Tarija'],
      );
      expect(resultado.ubicacion.nombre, 'Tarija');
    });

    test('sin resultados devuelve un error comprensible', () async {
      final fuente = _FuenteClimaFalsa(
        respuestasBusqueda: const {},
        pronostico: _pronostico(),
      );

      expect(
        () => ServicioClimaDestino(
          fuente: fuente,
        ).consultar('Lugar inexistente'),
        throwsA(
          isA<ExcepcionClima>().having(
            (error) => error.mensaje,
            'mensaje',
            contains('No encontramos una ubicación'),
          ),
        ),
      );
    });

    test('destino vacío se rechaza antes de consultar la API', () async {
      final fuente = _FuenteClimaFalsa(
        respuestasBusqueda: const {},
        pronostico: _pronostico(),
      );

      expect(
        () => ServicioClimaDestino(fuente: fuente).consultar(' '),
        throwsA(isA<ExcepcionClima>()),
      );
      expect(fuente.consultasRealizadas, isEmpty);
    });
  });
}
