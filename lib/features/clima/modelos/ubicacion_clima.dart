/// Ubicación devuelta por el servicio de geocodificación de Open-Meteo.
class UbicacionClima {
  const UbicacionClima({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.pais,
    this.codigoPais,
    this.region,
    this.zonaHoraria,
  });

  final int id;
  final String nombre;
  final double latitud;
  final double longitud;
  final String? pais;
  final String? codigoPais;
  final String? region;
  final String? zonaHoraria;

  factory UbicacionClima.fromMap(Map<String, dynamic> map) {
    return UbicacionClima(
      id: (map['id'] as num).toInt(),
      nombre: map['name'] as String,
      latitud: (map['latitude'] as num).toDouble(),
      longitud: (map['longitude'] as num).toDouble(),
      pais: map['country'] as String?,
      codigoPais: map['country_code'] as String?,
      region: map['admin1'] as String?,
      zonaHoraria: map['timezone'] as String?,
    );
  }

  String get nombreCompleto {
    final partes = <String>[
      nombre,
      if (region != null &&
          region!.trim().isNotEmpty &&
          region!.trim().toLowerCase() != nombre.trim().toLowerCase())
        region!.trim(),
      if (pais != null && pais!.trim().isNotEmpty) pais!.trim(),
    ];

    return partes.join(', ');
  }
}
