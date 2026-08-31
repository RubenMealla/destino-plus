import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/viajes/modelos/viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_formulario_viaje.dart';
import 'package:destino_plus/features/viajes/pantalla_viajes.dart';
import 'package:destino_plus/features/viajes/servicios/repositorio_viajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FuenteViajesControlada implements FuenteViajes {
  final List<Viaje> viajes = [];
  int llamadasListar = 0;
  bool fallarPrimerListado = false;

  @override
  Future<List<Viaje>> listar() async {
    llamadasListar += 1;

    if (fallarPrimerListado && llamadasListar == 1) {
      throw const ExcepcionViajes(
        'Error temporal de conexión.',
      );
    }

    return List.unmodifiable(viajes);
  }

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) async {
    final viaje = Viaje(
      id: 'viaje-${viajes.length + 1}',
      usuarioId: 'usuario-prueba',
      titulo: titulo.trim(),
      destino: destino.trim(),
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      descripcion:
          descripcion?.trim().isEmpty == true ? null : descripcion?.trim(),
      creadoEn: DateTime.utc(2026, 8, 31),
      actualizadoEn: DateTime.utc(2026, 8, 31),
    );

    viajes.add(viaje);
    return viaje;
  }

  @override
  Future<Viaje?> obtenerPorId(String id) async {
    for (final viaje in viajes) {
      if (viaje.id == id) {
        return viaje;
      }
    }
    return null;
  }

  @override
  Future<Viaje> actualizar(Viaje viaje) async {
    final indice = viajes.indexWhere((item) => item.id == viaje.id);

    if (indice >= 0) {
      viajes[indice] = viaje;
    }

    return viaje;
  }

  @override
  Future<void> eliminar(String id) async {
    viajes.removeWhere((viaje) => viaje.id == id);
  }
}

void main() {
  testWidgets('crear viaje persiste los datos válidos del formulario', (
    tester,
  ) async {
    final fuente = _FuenteViajesControlada();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<bool>(
            builder: (_) => PantallaFormularioViaje(
              repositorio: fuente,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(5));

    await tester.enterText(campos.at(0), 'Escapada de septiembre');
    await tester.enterText(campos.at(1), 'Tarija, Bolivia');
    await tester.enterText(campos.at(2), '10/09/2026');
    await tester.enterText(campos.at(3), '15/09/2026');
    await tester.enterText(campos.at(4), 'Viaje de prueba');

    await tester.tap(find.text('Guardar viaje'));
    await tester.pumpAndSettle();

    expect(fuente.viajes, hasLength(1));

    final viaje = fuente.viajes.single;
    expect(viaje.titulo, 'Escapada de septiembre');
    expect(viaje.destino, 'Tarija, Bolivia');
    expect(viaje.fechaInicio, DateTime(2026, 9, 10));
    expect(viaje.fechaFin, DateTime(2026, 9, 15));
    expect(viaje.descripcion, 'Viaje de prueba');
  });

  testWidgets('el formulario rechaza un rango de fechas invertido', (
    tester,
  ) async {
    final fuente = _FuenteViajesControlada();

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaFormularioViaje(
          repositorio: fuente,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);

    await tester.enterText(campos.at(0), 'Viaje');
    await tester.enterText(campos.at(1), 'Tarija');
    await tester.enterText(campos.at(2), '15/09/2026');
    await tester.enterText(campos.at(3), '10/09/2026');

    await tester.tap(find.text('Guardar viaje'));
    await tester.pumpAndSettle();

    expect(fuente.viajes, isEmpty);
    expect(
      find.text(
        'La fecha de fin no puede ser anterior a la fecha de inicio.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('la lista permite recuperarse de un error temporal', (
    tester,
  ) async {
    final fuente = _FuenteViajesControlada()
      ..fallarPrimerListado = true
      ..viajes.add(
        Viaje(
          id: 'viaje-1',
          usuarioId: 'usuario-prueba',
          titulo: 'Viaje recuperado',
          destino: 'Sucre',
          fechaInicio: DateTime(2026, 10, 1),
          fechaFin: DateTime(2026, 10, 4),
          creadoEn: DateTime.utc(2026, 8, 31),
          actualizadoEn: DateTime.utc(2026, 8, 31),
        ),
      );

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: PantallaViajes(
          repositorio: fuente,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos cargar tus viajes'),
      findsOneWidget,
    );
    expect(find.text('Error temporal de conexión.'), findsOneWidget);
    expect(fuente.llamadasListar, 1);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(fuente.llamadasListar, 2);
    expect(find.text('Viaje recuperado'), findsOneWidget);
    expect(find.text('Sucre'), findsOneWidget);
  });
}
