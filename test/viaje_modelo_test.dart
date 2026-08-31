import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Viaje convierte correctamente una fila de Supabase', () {
    final viaje = Viaje.fromMap({
      'id': 'viaje-1',
      'usuario_id': 'usuario-1',
      'titulo': 'Vacaciones',
      'destino': 'Tarija',
      'fecha_inicio': '2026-09-10',
      'fecha_fin': '2026-09-15',
      'descripcion': 'Viaje de prueba',
      'creado_en': '2026-08-31T12:00:00.000Z',
      'actualizado_en': '2026-08-31T12:00:00.000Z',
    });

    expect(viaje.id, 'viaje-1');
    expect(viaje.usuarioId, 'usuario-1');
    expect(viaje.titulo, 'Vacaciones');
    expect(viaje.destino, 'Tarija');
    expect(viaje.fechaInicio, DateTime(2026, 9, 10));
    expect(viaje.fechaFin, DateTime(2026, 9, 15));
    expect(viaje.descripcion, 'Viaje de prueba');
  });

  test('Viaje genera fechas SQL sin información de hora', () {
    expect(Viaje.fechaSql(DateTime(2026, 9, 5, 18, 30)), '2026-09-05');
  });

  test('toUpdateMap normaliza espacios y descripción vacía', () {
    final viaje = Viaje(
      id: 'viaje-1',
      usuarioId: 'usuario-1',
      titulo: '  Congreso  ',
      destino: '  La Paz ',
      fechaInicio: DateTime(2026, 10, 1),
      fechaFin: DateTime(2026, 10, 3),
      descripcion: '   ',
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );

    final map = viaje.toUpdateMap();

    expect(map['titulo'], 'Congreso');
    expect(map['destino'], 'La Paz');
    expect(map['fecha_inicio'], '2026-10-01');
    expect(map['fecha_fin'], '2026-10-03');
    expect(map['descripcion'], isNull);
  });
}
