import 'package:destino_plus/features/actividades/modelos/actividad_viaje.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ActividadViaje convierte una fila de Supabase', () {
    final actividad = ActividadViaje.fromMap({
      'id': 'actividad-1',
      'viaje_id': 'viaje-1',
      'titulo': 'Visitar plaza principal',
      'fecha': '2026-09-10',
      'hora_inicio': '09:30:00',
      'lugar': 'Centro de Tarija',
      'notas': 'Llevar cámara',
      'completada': false,
      'creado_en': '2026-08-31T12:00:00.000Z',
      'actualizado_en': '2026-08-31T12:00:00.000Z',
    });

    expect(actividad.id, 'actividad-1');
    expect(actividad.viajeId, 'viaje-1');
    expect(actividad.titulo, 'Visitar plaza principal');
    expect(actividad.fecha, DateTime(2026, 9, 10));
    expect(actividad.horaInicio, '09:30');
    expect(actividad.lugar, 'Centro de Tarija');
    expect(actividad.notas, 'Llevar cámara');
    expect(actividad.completada, isFalse);
  });

  test('toUpdateMap normaliza campos opcionales vacíos', () {
    final actividad = ActividadViaje(
      id: 'actividad-1',
      viajeId: 'viaje-1',
      titulo: '  Cena  ',
      fecha: DateTime(2026, 9, 11),
      horaInicio: '',
      lugar: '   ',
      notas: '',
      completada: true,
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );

    final map = actividad.toUpdateMap();

    expect(map['titulo'], 'Cena');
    expect(map['fecha'], '2026-09-11');
    expect(map['hora_inicio'], isNull);
    expect(map['lugar'], isNull);
    expect(map['notas'], isNull);
    expect(map['completada'], isTrue);
  });

  test('copyWith permite limpiar datos opcionales', () {
    final actividad = ActividadViaje(
      id: 'actividad-1',
      viajeId: 'viaje-1',
      titulo: 'Cena',
      fecha: DateTime(2026, 9, 11),
      horaInicio: '20:00',
      lugar: 'Restaurante',
      notas: 'Reservar',
      completada: false,
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );

    final actualizada = actividad.copyWith(
      limpiarHoraInicio: true,
      limpiarLugar: true,
      limpiarNotas: true,
      completada: true,
    );

    expect(actualizada.horaInicio, isNull);
    expect(actualizada.lugar, isNull);
    expect(actualizada.notas, isNull);
    expect(actualizada.completada, isTrue);
  });
}
