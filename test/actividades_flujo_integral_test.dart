import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/actividades/modelos/actividad_viaje.dart';
import 'package:destino_plus/features/actividades/pantalla_formulario_actividad.dart';
import 'package:destino_plus/features/actividades/servicios/repositorio_actividades.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_detalle_viaje.dart';
import 'package:destino_plus/features/viajes/servicios/repositorio_viajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ViajesFalsos implements FuenteViajes {
  _ViajesFalsos(this.viaje);

  final Viaje viaje;

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
  Future<Viaje> actualizar(Viaje viaje) async => viaje;

  @override
  Future<void> eliminar(String id) async {}
}

class _ActividadesFalsas implements FuenteActividades {
  _ActividadesFalsas([List<ActividadViaje>? iniciales])
      : actividades = [...?iniciales];

  final List<ActividadViaje> actividades;
  int creaciones = 0;
  int actualizaciones = 0;
  int eliminaciones = 0;

  @override
  Future<List<ActividadViaje>> listarPorViaje(String viajeId) async {
    return actividades
        .where((actividad) => actividad.viajeId == viajeId)
        .toList(growable: false);
  }

  @override
  Future<ActividadViaje?> obtenerPorId(String id) async {
    for (final actividad in actividades) {
      if (actividad.id == id) {
        return actividad;
      }
    }
    return null;
  }

  @override
  Future<ActividadViaje> crear({
    required String viajeId,
    required String titulo,
    required DateTime fecha,
    String? horaInicio,
    String? lugar,
    String? notas,
  }) async {
    creaciones += 1;

    final actividad = ActividadViaje(
      id: 'actividad-$creaciones',
      viajeId: viajeId,
      titulo: titulo.trim(),
      fecha: fecha,
      horaInicio:
          horaInicio?.trim().isEmpty == true ? null : horaInicio?.trim(),
      lugar: lugar?.trim().isEmpty == true ? null : lugar?.trim(),
      notas: notas?.trim().isEmpty == true ? null : notas?.trim(),
      completada: false,
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );

    actividades.add(actividad);
    return actividad;
  }

  @override
  Future<ActividadViaje> actualizar(ActividadViaje actividad) async {
    actualizaciones += 1;

    final indice = actividades.indexWhere(
      (item) => item.id == actividad.id,
    );

    if (indice >= 0) {
      actividades[indice] = actividad;
    }

    return actividad;
  }

  @override
  Future<void> eliminar(String id) async {
    eliminaciones += 1;
    actividades.removeWhere((actividad) => actividad.id == id);
  }
}

Viaje _viaje() {
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

ActividadViaje _actividad() {
  return ActividadViaje(
    id: 'actividad-1',
    viajeId: 'viaje-1',
    titulo: 'Cena en el centro',
    fecha: DateTime(2026, 9, 11),
    horaInicio: '20:00',
    lugar: 'Centro',
    notas: 'Reservar mesa',
    completada: false,
    creadoEn: DateTime.utc(2026, 8, 31),
    actualizadoEn: DateTime.utc(2026, 8, 31),
  );
}

void main() {
  testWidgets('una actividad no puede quedar fuera de las fechas del viaje', (
    tester,
  ) async {
    final viaje = _viaje();
    final actividades = _ActividadesFalsas();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioActividad(
          viajeId: viaje.id,
          viaje: viaje,
          repositorio: actividades,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);

    await tester.enterText(campos.at(0), 'Actividad fuera del viaje');
    await tester.enterText(campos.at(1), '09/09/2026');

    await tester.tap(find.text('Guardar actividad'));
    await tester.pumpAndSettle();

    expect(actividades.creaciones, 0);
    expect(actividades.actividades, isEmpty);
    expect(
      find.text(
        'La actividad debe estar entre 10/09/2026 y 15/09/2026.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('los días inicial y final del viaje son válidos', (
    tester,
  ) async {
    final viaje = _viaje();
    final actividades = _ActividadesFalsas();

    Future<void> crearEnFecha(String fecha) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaApp.claro,
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<bool>(
              builder: (_) => PantallaFormularioActividad(
                viajeId: viaje.id,
                viaje: viaje,
                repositorio: actividades,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Actividad válida');
      await tester.enterText(campos.at(1), fecha);

      await tester.tap(find.text('Guardar actividad'));
      await tester.pumpAndSettle();
    }

    await crearEnFecha('10/09/2026');
    await crearEnFecha('15/09/2026');

    expect(actividades.creaciones, 2);
    expect(
      actividades.actividades.map((actividad) => actividad.fecha),
      containsAll([
        DateTime(2026, 9, 10),
        DateTime(2026, 9, 15),
      ]),
    );
  });

  testWidgets('marcar completada se refleja después de recargar itinerario', (
    tester,
  ) async {
    final viaje = _viaje();
    final actividades = _ActividadesFalsas([_actividad()]);

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaDetalleViaje(
          viajeId: viaje.id,
          repositorio: _ViajesFalsos(viaje),
          repositorioActividades: actividades,
        ),
      ),
    );
    await tester.pumpAndSettle();

    var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isFalse);
    expect(
      find.byTooltip('Marcar como completada'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(actividades.actualizaciones, 1);
    expect(actividades.actividades.single.completada, isTrue);

    checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
    expect(
      find.byTooltip('Marcar como pendiente'),
      findsOneWidget,
    );
  });

  testWidgets('eliminar actividad exige confirmar y actualiza el itinerario', (
    tester,
  ) async {
    final viaje = _viaje();
    final actividades = _ActividadesFalsas([_actividad()]);

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaDetalleViaje(
          viajeId: viaje.id,
          repositorio: _ViajesFalsos(viaje),
          repositorioActividades: actividades,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cena en el centro'), findsOneWidget);

    await tester.tap(find.byTooltip('Opciones de actividad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();

    expect(find.text('Eliminar actividad'), findsOneWidget);
    expect(
      find.textContaining(
        '¿Seguro que deseas eliminar "Cena en el centro"',
      ),
      findsOneWidget,
    );
    expect(actividades.eliminaciones, 0);

    final confirmar = find.widgetWithText(FilledButton, 'Eliminar');
    expect(confirmar, findsOneWidget);

    await tester.tap(confirmar);
    await tester.pumpAndSettle();

    expect(actividades.eliminaciones, 1);
    expect(actividades.actividades, isEmpty);
    expect(find.text('Aún no hay actividades'), findsOneWidget);
    expect(find.text('Actividad eliminada.'), findsOneWidget);
  });
}
