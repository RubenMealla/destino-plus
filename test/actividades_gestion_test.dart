import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/actividades/modelos/actividad_viaje.dart';
import 'package:destino_plus/features/actividades/pantalla_formulario_actividad.dart';
import 'package:destino_plus/features/actividades/servicios/repositorio_actividades.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteActividadesFalsa implements FuenteActividades {
  _FuenteActividadesFalsa([List<ActividadViaje>? iniciales])
    : actividades = [...?iniciales];

  final List<ActividadViaje> actividades;

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
    final actividad = ActividadViaje(
      id: 'actividad-${actividades.length + 1}',
      viajeId: viajeId,
      titulo: titulo.trim(),
      fecha: fecha,
      horaInicio: horaInicio?.trim().isEmpty == true
          ? null
          : horaInicio?.trim(),
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
    final indice = actividades.indexWhere((item) => item.id == actividad.id);

    if (indice >= 0) {
      actividades[indice] = actividad;
    }

    return actividad;
  }

  @override
  Future<void> eliminar(String id) async {
    actividades.removeWhere((actividad) => actividad.id == id);
  }
}

void main() {
  testWidgets('el formulario de actividad valida campos obligatorios', (
    tester,
  ) async {
    final fuente = _FuenteActividadesFalsa();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioActividad(
          viajeId: 'viaje-1',
          repositorio: fuente,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Guardar actividad'));
    await tester.tap(find.text('Guardar actividad'));
    await tester.pump();

    expect(
      find.text('El título debe tener al menos 2 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('Usa el formato DD/MM/AAAA.'), findsOneWidget);
  });

  testWidgets('el formulario permite crear una actividad', (tester) async {
    final fuente = _FuenteActividadesFalsa();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<bool>(
            builder: (_) => PantallaFormularioActividad(
              viajeId: 'viaje-1',
              repositorio: fuente,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);

    await tester.enterText(campos.at(0), 'Visitar San Jacinto');
    tester
            .widget<TextFormField>(find.byKey(const Key('fecha-actividad')))
            .controller!
            .text =
        '11/09/2026';
    await tester.enterText(campos.at(2), '09:30');
    await tester.enterText(campos.at(3), 'San Jacinto');
    await tester.enterText(campos.at(4), 'Llevar agua');

    await tester.ensureVisible(find.text('Guardar actividad'));
    await tester.tap(find.text('Guardar actividad'));
    await tester.pumpAndSettle();

    expect(fuente.actividades, hasLength(1));
    expect(fuente.actividades.first.titulo, 'Visitar San Jacinto');
    expect(fuente.actividades.first.horaInicio, '09:30');
    expect(fuente.actividades.first.lugar, 'San Jacinto');
  });

  testWidgets('la edición carga los datos de la actividad', (tester) async {
    final actividad = ActividadViaje(
      id: 'actividad-1',
      viajeId: 'viaje-1',
      titulo: 'Cena',
      fecha: DateTime(2026, 9, 11),
      horaInicio: '20:00',
      lugar: 'Centro',
      notas: 'Reservar mesa',
      completada: false,
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );
    final fuente = _FuenteActividadesFalsa([actividad]);

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioActividad(
          viajeId: 'viaje-1',
          actividadId: 'actividad-1',
          repositorio: fuente,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar actividad'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('11/09/2026'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('Centro'), findsOneWidget);
    expect(find.text('Reservar mesa'), findsOneWidget);
  });
}
