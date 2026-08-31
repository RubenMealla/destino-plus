import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_detalle_viaje.dart';
import 'package:destino_plus/features/viajes/servicios/repositorio_viajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteViajesFalsa implements FuenteViajes {
  _FuenteViajesFalsa(this.viaje);

  Viaje? viaje;
  bool eliminado = false;

  @override
  Future<List<Viaje>> listar() async => [
        if (viaje != null) viaje!,
      ];

  @override
  Future<Viaje?> obtenerPorId(String id) async {
    if (viaje?.id == id) {
      return viaje;
    }
    return null;
  }

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) async {
    return viaje!;
  }

  @override
  Future<Viaje> actualizar(Viaje actualizado) async {
    viaje = actualizado;
    return actualizado;
  }

  @override
  Future<void> eliminar(String id) async {
    if (viaje?.id == id) {
      eliminado = true;
      viaje = null;
    }
  }
}

Viaje _viajePrueba() {
  return Viaje(
    id: 'viaje-1',
    usuarioId: 'usuario-prueba',
    titulo: 'Vacaciones',
    destino: 'Tarija',
    fechaInicio: DateTime(2026, 9, 10),
    fechaFin: DateTime(2026, 9, 15),
    creadoEn: DateTime.utc(2026, 8, 31),
    actualizadoEn: DateTime.utc(2026, 8, 31),
  );
}

void main() {
  testWidgets('eliminar viaje requiere confirmación', (tester) async {
    final fuente = _FuenteViajesFalsa(_viajePrueba());

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaDetalleViaje(
          viajeId: 'viaje-1',
          repositorio: fuente,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar viaje'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar viaje'), findsWidgets);
    expect(
      find.textContaining('Esta acción no se puede deshacer.'),
      findsOneWidget,
    );
    expect(fuente.eliminado, isFalse);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(fuente.eliminado, isFalse);
  });

  testWidgets('confirmar eliminación elimina el viaje', (tester) async {
    final fuente = _FuenteViajesFalsa(_viajePrueba());

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<bool>(
            builder: (_) => PantallaDetalleViaje(
              viajeId: 'viaje-1',
              repositorio: fuente,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar viaje'));
    await tester.pumpAndSettle();

    final eliminar = find.widgetWithText(FilledButton, 'Eliminar');
    expect(eliminar, findsOneWidget);

    await tester.tap(eliminar);
    await tester.pumpAndSettle();

    expect(fuente.eliminado, isTrue);
  });
}
