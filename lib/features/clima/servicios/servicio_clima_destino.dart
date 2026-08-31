import '../modelos/pronostico_clima.dart';
import '../modelos/ubicacion_clima.dart';
import 'cliente_open_meteo.dart';

/// Resultado completo de una consulta meteorológica por texto de destino.
class ClimaDestino {
  const ClimaDestino({
    required this.consulta,
    required this.ubicacion,
    required this.pronostico,
  });

  final String consulta;
  final UbicacionClima ubicacion;
  final PronosticoClima pronostico;
}

/// Contrato consumido por la interfaz de clima.
abstract interface class FuenteClimaDestino {
  Future<ClimaDestino> consultar(String destino);
}

/// Convierte un destino escrito por el usuario en un pronóstico utilizable.
class ServicioClimaDestino implements FuenteClimaDestino {
  ServicioClimaDestino({
    FuenteClimaRemota? fuente,
  }) : _fuente = fuente ?? ClienteOpenMeteo();

  final FuenteClimaRemota _fuente;

  @override
  Future<ClimaDestino> consultar(String destino) async {
    final consulta = destino.trim();

    if (consulta.length < 2) {
      throw const ExcepcionClima(
        'Escribe un destino para consultar el clima.',
      );
    }

    var ubicaciones = await _fuente.buscarUbicaciones(
      consulta,
      limite: 8,
    );

    // Los destinos guardados pueden incluir país o región. Si la búsqueda
    // completa no devuelve resultados, se intenta con la primera parte.
    if (ubicaciones.isEmpty && consulta.contains(',')) {
      final ciudad = consulta.split(',').first.trim();

      if (ciudad.length >= 2 && ciudad != consulta) {
        ubicaciones = await _fuente.buscarUbicaciones(
          ciudad,
          limite: 8,
        );
      }
    }

    if (ubicaciones.isEmpty) {
      throw ExcepcionClima(
        'No encontramos una ubicación para "$consulta".',
      );
    }

    final ubicacion = _elegirMejorUbicacion(
      consulta,
      ubicaciones,
    );

    final pronostico = await _fuente.obtenerPronostico(
      latitud: ubicacion.latitud,
      longitud: ubicacion.longitud,
    );

    return ClimaDestino(
      consulta: consulta,
      ubicacion: ubicacion,
      pronostico: pronostico,
    );
  }

  UbicacionClima _elegirMejorUbicacion(
    String consulta,
    List<UbicacionClima> opciones,
  ) {
    final tokensConsulta = _tokens(consulta);

    var mejor = opciones.first;
    var mejorPuntaje = _puntaje(mejor, tokensConsulta);

    for (final opcion in opciones.skip(1)) {
      final puntaje = _puntaje(opcion, tokensConsulta);

      if (puntaje > mejorPuntaje) {
        mejor = opcion;
        mejorPuntaje = puntaje;
      }
    }

    return mejor;
  }

  int _puntaje(
    UbicacionClima ubicacion,
    Set<String> tokensConsulta,
  ) {
    final tokensUbicacion = _tokens(ubicacion.nombreCompleto);
    var puntaje = 0;

    for (final token in tokensConsulta) {
      if (tokensUbicacion.contains(token)) {
        puntaje += 10;
      }
    }

    final nombreConsulta = _normalizar(
      tokensConsulta.join(' '),
    );
    final nombreUbicacion = _normalizar(ubicacion.nombre);

    if (nombreConsulta.startsWith(nombreUbicacion) ||
        nombreUbicacion.startsWith(nombreConsulta)) {
      puntaje += 15;
    }

    return puntaje;
  }

  Set<String> _tokens(String texto) {
    return _normalizar(texto)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.length >= 2)
        .toSet();
  }

  String _normalizar(String texto) {
    const reemplazos = <String, String>{
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    var resultado = texto.toLowerCase().trim();

    reemplazos.forEach((origen, destino) {
      resultado = resultado.replaceAll(origen, destino);
    });

    return resultado;
  }
}
