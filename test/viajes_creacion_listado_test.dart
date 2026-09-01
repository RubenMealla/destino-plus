import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_formulario_viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_viajes.dart';
import 'package:destino_plus/features/viajes/servicios/repositorio_viajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteViajesFalsa implements FuenteViajes {
  _FuenteViajesFalsa([List<Viaje>? iniciales]) : viajes = [...?iniciales];

  final List<Viaje> viajes;

  @override
  Future<List<Viaje>> listar() async => List.unmodifiable(viajes);

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) async {
    final viaje = Viaje(
      id: 'nuevo-${viajes.length + 1}',
      usuarioId: 'usuario-prueba',
      titulo: titulo.trim(),
      destino: destino.trim(),
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      descripcion: descripcion?.trim(),
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );
    viajes.add(viaje);
    return viaje;
  }

  @override
  Future<Viaje?> obtenerPorId(String id) async {
    for (final viaje in viajes) {
      if (viaje.id == id) return viaje;
    }
    return null;
  }

  @override
  Future<Viaje> actualizar(Viaje viaje) async => viaje;

  @override
  Future<void> eliminar(String id) async {
    viajes.removeWhere((viaje) => viaje.id == id);
  }
}

void main() {
  testWidgets('el formulario valida campos vacíos', (tester) async {
    final fuente = _FuenteViajesFalsa();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioViaje(repositorio: fuente),
      ),
    );

    await tester.ensureVisible(find.text('Guardar viaje'));
    await tester.tap(find.text('Guardar viaje'));
    await tester.pump();

    expect(
      find.text('El título debe tener al menos 2 caracteres.'),
      findsOneWidget,
    );
    expect(
      find.text('El destino debe tener al menos 2 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('Usa el formato DD/MM/AAAA.'), findsNothing);
  });

  testWidgets('la lista muestra viajes existentes', (tester) async {
    final fuente = _FuenteViajesFalsa([
      Viaje(
        id: 'viaje-1',
        usuarioId: 'usuario-prueba',
        titulo: 'Vacaciones',
        destino: 'Tarija',
        fechaInicio: DateTime(2026, 9, 10),
        fechaFin: DateTime(2026, 9, 15),
        creadoEn: DateTime.utc(2026, 8, 31),
        actualizadoEn: DateTime.utc(2026, 8, 31),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaViajes(repositorio: fuente),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vacaciones'), findsOneWidget);
    expect(find.text('Tarija'), findsOneWidget);
    expect(find.text('10/09/2026 - 15/09/2026'), findsOneWidget);
  });

  testWidgets('la lista muestra estado vacío sin viajes', (tester) async {
    final fuente = _FuenteViajesFalsa();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaViajes(repositorio: fuente),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todavía no tienes viajes'), findsOneWidget);
    expect(find.text('Crear mi primer viaje'), findsOneWidget);
  });
}
