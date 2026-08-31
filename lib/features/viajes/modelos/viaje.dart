/// Modelo principal de un viaje en Destino+.
class Viaje {
  const Viaje({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.destino,
    required this.fechaInicio,
    required this.fechaFin,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final String usuarioId;
  final String titulo;
  final String destino;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? descripcion;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory Viaje.fromMap(Map<String, dynamic> map) {
    return Viaje(
      id: map['id'] as String,
      usuarioId: map['usuario_id'] as String,
      titulo: map['titulo'] as String,
      destino: map['destino'] as String,
      fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
      fechaFin: DateTime.parse(map['fecha_fin'] as String),
      descripcion: map['descripcion'] as String?,
      creadoEn: DateTime.parse(map['creado_en'] as String),
      actualizadoEn: DateTime.parse(map['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'titulo': titulo.trim(),
      'destino': destino.trim(),
      'fecha_inicio': _fechaSql(fechaInicio),
      'fecha_fin': _fechaSql(fechaFin),
      'descripcion': _normalizarDescripcion(descripcion),
    };
  }

  Viaje copyWith({
    String? id,
    String? usuarioId,
    String? titulo,
    String? destino,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? descripcion,
    bool limpiarDescripcion = false,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return Viaje(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      destino: destino ?? this.destino,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      descripcion:
          limpiarDescripcion ? null : (descripcion ?? this.descripcion),
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  static String fechaSql(DateTime fecha) => _fechaSql(fecha);

  static String _fechaSql(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '$anio-$mes-$dia';
  }

  static String? _normalizarDescripcion(String? valor) {
    final descripcion = valor?.trim();
    if (descripcion == null || descripcion.isEmpty) return null;
    return descripcion;
  }
}
