/// Condiciones meteorológicas actuales.
class ClimaActual {
  const ClimaActual({
    required this.fechaHora,
    required this.temperatura,
    required this.temperaturaAparente,
    required this.humedadRelativa,
    required this.codigoClima,
    required this.velocidadViento,
    required this.esDeDia,
  });

  final DateTime fechaHora;
  final double temperatura;
  final double temperaturaAparente;
  final int humedadRelativa;
  final int codigoClima;
  final double velocidadViento;
  final bool esDeDia;

  factory ClimaActual.fromMap(Map<String, dynamic> map) {
    return ClimaActual(
      fechaHora: DateTime.parse(map['time'] as String),
      temperatura: (map['temperature_2m'] as num).toDouble(),
      temperaturaAparente:
          (map['apparent_temperature'] as num).toDouble(),
      humedadRelativa:
          (map['relative_humidity_2m'] as num).toInt(),
      codigoClima: (map['weather_code'] as num).toInt(),
      velocidadViento: (map['wind_speed_10m'] as num).toDouble(),
      esDeDia: (map['is_day'] as num).toInt() == 1,
    );
  }
}

/// Pronóstico resumido para un día.
class PronosticoDiario {
  const PronosticoDiario({
    required this.fecha,
    required this.temperaturaMaxima,
    required this.temperaturaMinima,
    required this.probabilidadPrecipitacion,
    required this.codigoClima,
  });

  final DateTime fecha;
  final double temperaturaMaxima;
  final double temperaturaMinima;
  final int probabilidadPrecipitacion;
  final int codigoClima;
}

/// Respuesta meteorológica lista para ser consumida por la interfaz.
class PronosticoClima {
  const PronosticoClima({
    required this.latitud,
    required this.longitud,
    required this.zonaHoraria,
    required this.actual,
    required this.dias,
  });

  final double latitud;
  final double longitud;
  final String zonaHoraria;
  final ClimaActual actual;
  final List<PronosticoDiario> dias;

  factory PronosticoClima.fromMap(Map<String, dynamic> map) {
    final actualMap = map['current'] as Map<String, dynamic>;
    final diario = map['daily'] as Map<String, dynamic>;

    final fechas = _lista<String>(diario['time']);
    final maximas = _lista<num>(diario['temperature_2m_max']);
    final minimas = _lista<num>(diario['temperature_2m_min']);
    final probabilidades =
        _lista<num>(diario['precipitation_probability_max']);
    final codigos = _lista<num>(diario['weather_code']);

    final cantidad = [
      fechas.length,
      maximas.length,
      minimas.length,
      probabilidades.length,
      codigos.length,
    ].reduce((a, b) => a < b ? a : b);

    final dias = <PronosticoDiario>[
      for (var i = 0; i < cantidad; i++)
        PronosticoDiario(
          fecha: DateTime.parse(fechas[i]),
          temperaturaMaxima: maximas[i].toDouble(),
          temperaturaMinima: minimas[i].toDouble(),
          probabilidadPrecipitacion: probabilidades[i].toInt(),
          codigoClima: codigos[i].toInt(),
        ),
    ];

    return PronosticoClima(
      latitud: (map['latitude'] as num).toDouble(),
      longitud: (map['longitude'] as num).toDouble(),
      zonaHoraria: map['timezone'] as String? ?? 'GMT',
      actual: ClimaActual.fromMap(actualMap),
      dias: List.unmodifiable(dias),
    );
  }

  static List<T> _lista<T>(Object? valor) {
    if (valor is! List) {
      return const [];
    }

    return valor.cast<T>();
  }
}
