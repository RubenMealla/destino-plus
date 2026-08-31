import 'package:destino_plus/features/viajes/validacion/validadores_viaje.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidadoresViaje', () {
    test('rechaza título y destino demasiado cortos', () {
      expect(
        ValidadoresViaje.titulo('A'),
        'El título debe tener al menos 2 caracteres.',
      );
      expect(
        ValidadoresViaje.destino('B'),
        'El destino debe tener al menos 2 caracteres.',
      );
    });

    test('acepta título y destino válidos', () {
      expect(ValidadoresViaje.titulo('Vacaciones'), isNull);
      expect(ValidadoresViaje.destino('Tarija'), isNull);
    });

    test('rechaza fecha inexistente', () {
      expect(
        ValidadoresViaje.fecha('31/02/2026'),
        'Usa el formato DD/MM/AAAA.',
      );
    });

    test('convierte fecha válida', () {
      expect(
        ValidadoresViaje.parsearFecha('05/09/2026'),
        DateTime(2026, 9, 5),
      );
    });

    test('rechaza fecha final anterior a la inicial', () {
      expect(
        ValidadoresViaje.rangoFechas(
          DateTime(2026, 9, 10),
          DateTime(2026, 9, 9),
        ),
        'La fecha de fin no puede ser anterior a la fecha de inicio.',
      );
    });

    test('acepta viaje de un solo día', () {
      expect(
        ValidadoresViaje.rangoFechas(
          DateTime(2026, 9, 10),
          DateTime(2026, 9, 10),
        ),
        isNull,
      );
    });
  });
}
