import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_detalle_viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_formulario_viaje.dart';
import 'package:destino_plus/features/viajes/servicios/repositorio_viajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'soporte/fuente_actividades_vacia_prueba.dart';

class _FuenteViajesFalsa implements FuenteViajes {
  _FuenteViajesFalsa(this.viaje);

  Viaje viaje;

  @override
  Future<List<Viaje>> listar() async => [viaje];

  @override
  Future<Viaje?> obtenerPorId(String id) async {
    return id == viaje.id ? viaje : null;
  }

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) async {
    return viaje;
  }

  @override
  Future<Viaje> actualizar(Viaje actualizado) async {
    viaje = actualizado;
    return viaje;
  }

  @override
  Future<void> eliminar(String id) async {}
}

Viaje _viajePrueba() {
  return Viaje(
    id: 'viaje-1',
    usuarioId: 'usuario-prueba',
    titulo: 'Vacaciones',
    destino: 'Tarija, Bolivia',
    fechaInicio: DateTime(2026, 9, 10),
    fechaFin: DateTime(2026, 9, 15),
    descripcion: 'Viaje familiar',
    creadoEn: DateTime.utc(2026, 8, 31),
    actualizadoEn: DateTime.utc(2026, 8, 31),
  );
}

void main() {
  testWidgets('el detalle muestra la información del viaje', (tester) async {
    final fuente = _FuenteViajesFalsa(_viajePrueba());

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaDetalleViaje(
          viajeId: 'viaje-1',
          repositorio: fuente,
          repositorioActividades:
              const FuenteActividadesVaciaPrueba(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vacaciones'), findsOneWidget);
    expect(find.text('Tarija, Bolivia'), findsOneWidget);
    expect(find.text('10/09/2026'), findsOneWidget);
    expect(find.text('15/09/2026'), findsOneWidget);
    expect(find.text('6 días'), findsOneWidget);
    expect(find.text('Viaje familiar'), findsOneWidget);
  });

  testWidgets('el formulario de edición carga los valores existentes', (
    tester,
  ) async {
    final fuente = _FuenteViajesFalsa(_viajePrueba());

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioViaje(
          viajeId: 'viaje-1',
          repositorio: fuente,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar viaje'), findsOneWidget);
    expect(find.text('Actualiza tu viaje'), findsOneWidget);
    expect(find.text('Vacaciones'), findsOneWidget);
    expect(find.text('Tarija, Bolivia'), findsOneWidget);
    expect(find.text('10/09/2026'), findsOneWidget);
    expect(find.text('15/09/2026'), findsOneWidget);
    expect(find.text('Viaje familiar'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
  });

  testWidgets('edición informa cuando el viaje no existe', (tester) async {
    final fuente = _FuenteViajesFalsa(_viajePrueba());

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioViaje(
          viajeId: 'otro-id',
          repositorio: fuente,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar el viaje'), findsOneWidget);
    expect(find.text('El viaje solicitado no existe.'), findsOneWidget);
  });
}
