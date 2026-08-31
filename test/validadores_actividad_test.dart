import 'package:destino_plus/features/actividades/validacion/validadores_actividad.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:flutter_test/flutter_test.dart';

Viaje _viaje() {
  return Viaje(
    id: 'viaje-1',
    usuarioId: 'usuario-1',
    titulo: 'Vacaciones',
    destino: 'Tarija',
    fechaInicio: DateTime(2026, 9, 10),
    fechaFin: DateTime(2026, 9, 15),
    creadoEn: DateTime.utc(2026, 8, 31),
    actualizadoEn: DateTime.utc(2026, 8, 31),
  );
}

void main() {
  group('ValidadoresActividad', () {
    test('acepta fecha dentro del viaje', () {
      expect(
        ValidadoresActividad.fechaDentroDelViaje(
          DateTime(2026, 9, 12),
          _viaje(),
        ),
        isNull,
      );
    });

    test('rechaza fecha anterior al viaje', () {
      expect(
        ValidadoresActividad.fechaDentroDelViaje(
          DateTime(2026, 9, 9),
          _viaje(),
        ),
        'La actividad debe estar entre 10/09/2026 y 15/09/2026.',
      );
    });

    test('rechaza fecha posterior al viaje', () {
      expect(
        ValidadoresActividad.fechaDentroDelViaje(
          DateTime(2026, 9, 16),
          _viaje(),
        ),
        isNotNull,
      );
    });

    test('valida hora de 24 horas', () {
      expect(ValidadoresActividad.hora('09:30'), isNull);
      expect(ValidadoresActividad.hora('23:59'), isNull);
      expect(ValidadoresActividad.hora('24:10'), 'Usa el formato HH:mm.');
    });

    test('acepta actividad sin hora', () {
      expect(ValidadoresActividad.hora(''), isNull);
      expect(ValidadoresActividad.hora(null), isNull);
    });
  });
}
