import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/pronostico_clima.dart';
import '../modelos/ubicacion_clima.dart';

class ExcepcionClima implements Exception {
  const ExcepcionClima(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato remoto utilizado por la lógica de clima.
///
/// Permite probar la consulta por destino sin realizar peticiones reales.
abstract interface class FuenteBusquedaUbicaciones {
  Future<List<UbicacionClima>> buscarUbicaciones(
    String consulta, {
    int limite = 5,
  });
}

abstract interface class FuenteClimaRemota
    implements FuenteBusquedaUbicaciones {
  Future<PronosticoClima> obtenerPronostico({
    required double latitud,
    required double longitud,
  });
}

/// Cliente HTTP mínimo para los servicios públicos de Open-Meteo.
class ClienteOpenMeteo implements FuenteClimaRemota {
  ClienteOpenMeteo({http.Client? clienteHttp})
    : _clienteHttp = clienteHttp ?? http.Client();

  static const String _hostGeocodificacion = 'geocoding-api.open-meteo.com';
  static const String _hostPronostico = 'api.open-meteo.com';

  final http.Client _clienteHttp;

  /// Busca ubicaciones por nombre en español.
  ///
  /// Open-Meteo acepta nombres de ciudades, códigos postales y calificadores
  /// como país o región.
  @override
  Future<List<UbicacionClima>> buscarUbicaciones(
    String consulta, {
    int limite = 5,
  }) async {
    final termino = consulta.trim();

    if (termino.length < 2) {
      return const [];
    }

    final limiteSeguro = limite.clamp(1, 10);

    final uri = Uri.https(_hostGeocodificacion, '/v1/search', {
      'name': termino,
      'count': '$limiteSeguro',
      'language': 'es',
      'format': 'json',
    });

    final respuesta = await _obtener(uri);

    final resultados = respuesta['results'];

    if (resultados == null) {
      return const [];
    }

    if (resultados is! List) {
      throw const ExcepcionClima(
        'Open-Meteo devolvió una respuesta de ubicaciones no válida.',
      );
    }

    return resultados
        .whereType<Map<String, dynamic>>()
        .map(UbicacionClima.fromMap)
        .toList(growable: false);
  }

  /// Obtiene condiciones actuales y siete días de pronóstico.
  @override
  Future<PronosticoClima> obtenerPronostico({
    required double latitud,
    required double longitud,
  }) async {
    if (latitud < -90 || latitud > 90) {
      throw const ExcepcionClima('La latitud no es válida.');
    }

    if (longitud < -180 || longitud > 180) {
      throw const ExcepcionClima('La longitud no es válida.');
    }

    final uri = Uri.https(_hostPronostico, '/v1/forecast', {
      'latitude': '$latitud',
      'longitude': '$longitud',
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'apparent_temperature',
        'is_day',
        'weather_code',
        'wind_speed_10m',
      ].join(','),
      'daily': [
        'weather_code',
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_probability_max',
      ].join(','),
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final respuesta = await _obtener(uri);

    try {
      return PronosticoClima.fromMap(respuesta);
    } catch (_) {
      throw const ExcepcionClima(
        'Open-Meteo devolvió un pronóstico con formato inesperado.',
      );
    }
  }

  Future<Map<String, dynamic>> _obtener(Uri uri) async {
    http.Response respuesta;

    try {
      respuesta = await _clienteHttp
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ExcepcionClima(
        'No fue posible conectar con el servicio del clima.',
      );
    }

    Map<String, dynamic> cuerpo;

    try {
      final decodificado = jsonDecode(respuesta.body);

      if (decodificado is! Map<String, dynamic>) {
        throw const FormatException();
      }

      cuerpo = decodificado;
    } catch (_) {
      throw const ExcepcionClima(
        'El servicio del clima devolvió una respuesta no válida.',
      );
    }

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      final motivo = cuerpo['reason'];

      if (motivo is String && motivo.trim().isNotEmpty) {
        throw ExcepcionClima(
          'Open-Meteo rechazó la consulta: ${motivo.trim()}',
        );
      }

      throw ExcepcionClima(
        'El servicio del clima respondió con el código '
        '${respuesta.statusCode}.',
      );
    }

    if (cuerpo['error'] == true) {
      final motivo = cuerpo['reason'];

      throw ExcepcionClima(
        motivo is String && motivo.trim().isNotEmpty
            ? motivo.trim()
            : 'Open-Meteo informó un error en la consulta.',
      );
    }

    return cuerpo;
  }

  void cerrar() {
    _clienteHttp.close();
  }
}
