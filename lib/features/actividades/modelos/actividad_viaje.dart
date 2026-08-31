/// Actividad planificada dentro de un viaje de Destino+.
class ActividadViaje {
  const ActividadViaje({
    required this.id,
    required this.viajeId,
    required this.titulo,
    required this.fecha,
    this.horaInicio,
    this.lugar,
    this.notas,
    required this.completada,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final String viajeId;
  final String titulo;
  final DateTime fecha;

  /// Hora opcional en formato `HH:mm`.
  final String? horaInicio;

  final String? lugar;
  final String? notas;
  final bool completada;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory ActividadViaje.fromMap(Map<String, dynamic> map) {
    return ActividadViaje(
      id: map['id'] as String,
      viajeId: map['viaje_id'] as String,
      titulo: map['titulo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      horaInicio: _normalizarHora(map['hora_inicio'] as String?),
      lugar: map['lugar'] as String?,
      notas: map['notas'] as String?,
      completada: map['completada'] as bool? ?? false,
      creadoEn: DateTime.parse(map['creado_en'] as String),
      actualizadoEn: DateTime.parse(map['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'titulo': titulo.trim(),
      'fecha': fechaSql(fecha),
      'hora_inicio': _normalizarHora(horaInicio),
      'lugar': _normalizarOpcional(lugar),
      'notas': _normalizarOpcional(notas),
      'completada': completada,
    };
  }

  ActividadViaje copyWith({
    String? id,
    String? viajeId,
    String? titulo,
    DateTime? fecha,
    String? horaInicio,
    bool limpiarHoraInicio = false,
    String? lugar,
    bool limpiarLugar = false,
    String? notas,
    bool limpiarNotas = false,
    bool? completada,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return ActividadViaje(
      id: id ?? this.id,
      viajeId: viajeId ?? this.viajeId,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      horaInicio:
          limpiarHoraInicio ? null : (horaInicio ?? this.horaInicio),
      lugar: limpiarLugar ? null : (lugar ?? this.lugar),
      notas: limpiarNotas ? null : (notas ?? this.notas),
      completada: completada ?? this.completada,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  static String fechaSql(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }

  static String? _normalizarHora(String? valor) {
    final hora = valor?.trim();

    if (hora == null || hora.isEmpty) {
      return null;
    }

    // PostgreSQL puede devolver `HH:mm:ss`; la aplicación trabaja con HH:mm.
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }

  static String? _normalizarOpcional(String? valor) {
    final texto = valor?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }
}
