/// Coordenadas obtenidas del dispositivo.
class UbicacionActual {
  const UbicacionActual({
    required this.latitud,
    required this.longitud,
    required this.precisionMetros,
    required this.fechaHora,
  });

  final double latitud;
  final double longitud;

  /// Precisión estimada informada por la plataforma, expresada en metros.
  final double precisionMetros;
  final DateTime fechaHora;
}

/// Resultado normalizado de los permisos soportados por la aplicación.
enum PermisoUbicacion {
  denegado,
  denegadoPermanentemente,
  mientrasUso,
  siempre,
}

/// Tipos de problema que pueden ocurrir al obtener la ubicación.
enum TipoErrorUbicacion {
  servicioDeshabilitado,
  permisoDenegado,
  permisoDenegadoPermanentemente,
  tiempoAgotado,
  noDisponible,
}

/// Error de dominio utilizado por la interfaz de Destino+.
class ExcepcionUbicacion implements Exception {
  const ExcepcionUbicacion({
    required this.tipo,
    required this.mensaje,
  });

  final TipoErrorUbicacion tipo;
  final String mensaje;

  @override
  String toString() => mensaje;
}
