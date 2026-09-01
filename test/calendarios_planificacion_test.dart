import 'package:destino_plus/features/actividades/modelos/actividad_viaje.dart';
import 'package:destino_plus/features/actividades/pantalla_formulario_actividad.dart';
import 'package:destino_plus/features/actividades/servicios/repositorio_actividades.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_formulario_viaje.dart';
import 'package:destino_plus/features/viajes/servicios/repositorio_viajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ViajesVacios implements FuenteViajes {
  @override
  Future<List<Viaje>> listar() async => const [];

  @override
  Future<Viaje?> obtenerPorId(String id) async => null;

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Viaje> actualizar(Viaje viaje) {
    throw UnimplementedError();
  }

  @override
  Future<void> eliminar(String id) async {}
}

class _ActividadesVacias implements FuenteActividades {
  const _ActividadesVacias();

  @override
  Future<List<ActividadViaje>> listarPorViaje(String viajeId) async => const [];

  @override
  Future<ActividadViaje?> obtenerPorId(String id) async => null;

  @override
  Future<ActividadViaje> crear({
    required String viajeId,
    required String titulo,
    required DateTime fecha,
    String? horaInicio,
    String? lugar,
    String? notas,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ActividadViaje> actualizar(ActividadViaje actividad) {
    throw UnimplementedError();
  }

  @override
  Future<void> eliminar(String id) async {}
}

Viaje _viaje() {
  return Viaje(
    id: 'v1',
    usuarioId: 'u1',
    titulo: 'Tarija',
    destino: 'Tarija, Bolivia',
    fechaInicio: DateTime(2026, 9, 10),
    fechaFin: DateTime(2026, 9, 15),
    creadoEn: DateTime(2026, 9, 1),
    actualizadoEn: DateTime(2026, 9, 1),
  );
}

void main() {
  testWidgets('nuevo viaje inicia con hoy y el calendario no permite pasado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaFormularioViaje(
          repositorio: _ViajesVacios(),
          fechaActual: DateTime(2026, 9, 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final inicio = tester.widget<TextFormField>(
      find.byKey(const Key('fecha-inicio-viaje')),
    );
    final fin = tester.widget<TextFormField>(
      find.byKey(const Key('fecha-fin-viaje')),
    );

    expect(inicio.controller!.text, '01/09/2026');
    expect(fin.controller!.text, '01/09/2026');

    await tester.tap(find.byKey(const Key('fecha-inicio-viaje')));
    await tester.pumpAndSettle();

    final calendario = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(calendario.firstDate, DateTime(2026, 9, 1));

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('calendario de actividad queda limitado al rango del viaje', (
    tester,
  ) async {
    final viaje = _viaje();

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaFormularioActividad(
          viajeId: viaje.id,
          viaje: viaje,
          repositorio: const _ActividadesVacias(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campo = tester.widget<TextFormField>(
      find.byKey(const Key('fecha-actividad')),
    );
    expect(campo.controller!.text, '10/09/2026');

    await tester.tap(find.byKey(const Key('fecha-actividad')));
    await tester.pumpAndSettle();

    final calendario = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(calendario.firstDate, DateTime(2026, 9, 10));
    expect(calendario.lastDate, DateTime(2026, 9, 15));

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });
}
