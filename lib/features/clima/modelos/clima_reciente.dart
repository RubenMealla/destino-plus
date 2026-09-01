import '../servicios/servicio_clima_destino.dart';

/// Resumen persistente de una consulta meteorológica realizada por el usuario.
///
/// Las temperaturas se guardan siempre en Celsius, que es la unidad recibida
/// desde Open-Meteo. La conversión a Fahrenheit se hace únicamente al mostrar.
class ClimaReciente {
  const ClimaReciente({
    required this.ubicacion,
    required this.temperaturaCelsius,
    required this.temperaturaAparenteCelsius,
    required this.humedadRelativa,
    required this.velocidadViento,
    required this.codigoClima,
    required this.esDeDia,
    required this.consultadoEn,
  });

  final String ubicacion;
  final double temperaturaCelsius;
  final double temperaturaAparenteCelsius;
  final int humedadRelativa;
  final double velocidadViento;
  final int codigoClima;
  final bool esDeDia;
  final DateTime consultadoEn;

  factory ClimaReciente.desdeResultado(
    ClimaDestino resultado, {
    DateTime? consultadoEn,
  }) {
    final actual = resultado.pronostico.actual;
    return ClimaReciente(
      ubicacion: resultado.ubicacion.nombreCompleto,
      temperaturaCelsius: actual.temperatura,
      temperaturaAparenteCelsius: actual.temperaturaAparente,
      humedadRelativa: actual.humedadRelativa,
      velocidadViento: actual.velocidadViento,
      codigoClima: actual.codigoClima,
      esDeDia: actual.esDeDia,
      consultadoEn: consultadoEn ?? DateTime.now(),
    );
  }

  factory ClimaReciente.fromJson(Map<String, dynamic> json) {
    return ClimaReciente(
      ubicacion: json['ubicacion'] as String,
      temperaturaCelsius: (json['temperatura_celsius'] as num).toDouble(),
      temperaturaAparenteCelsius: (json['temperatura_aparente_celsius'] as num)
          .toDouble(),
      humedadRelativa: (json['humedad_relativa'] as num).toInt(),
      velocidadViento: (json['velocidad_viento'] as num).toDouble(),
      codigoClima: (json['codigo_clima'] as num).toInt(),
      esDeDia: json['es_de_dia'] as bool? ?? true,
      consultadoEn: DateTime.parse(json['consultado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'ubicacion': ubicacion,
    'temperatura_celsius': temperaturaCelsius,
    'temperatura_aparente_celsius': temperaturaAparenteCelsius,
    'humedad_relativa': humedadRelativa,
    'velocidad_viento': velocidadViento,
    'codigo_clima': codigoClima,
    'es_de_dia': esDeDia,
    'consultado_en': consultadoEn.toIso8601String(),
  };
}
