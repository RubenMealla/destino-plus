import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/actividades/modelos/actividad_viaje.dart';
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
  Future<Viaje?> obtenerPorId(String id) async => id == viaje.id ? viaje : null;

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) async => viaje;

  @override
  Future<Viaje> actualizar(Viaje viaje) async => viaje;

  @override
  Future<void> eliminar(String id) async {}
}

class _ActividadesFalsas implements FuenteActividades {
  _ActividadesFalsas(this.actividades);

  final List<ActividadViaje> actividades;

  @override
  Future<List<ActividadViaje>> listarPorViaje(String viajeId) async {
    return actividades
        .where((actividad) => actividad.viajeId == viajeId)
        .toList(growable: false);
  }

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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ActividadViaje> actualizar(ActividadViaje actividad) async {
    final index = actividades.indexWhere((item) => item.id == actividad.id);
    actividades[index] = actividad;
    return actividad;
  }

  @override
  Future<void> eliminar(String id) async {}
}

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

ActividadViaje _actividad({
  required String id,
  required String titulo,
  required DateTime fecha,
  String? hora,
  bool completada = false,
}) {
  return ActividadViaje(
    id: id,
    viajeId: 'viaje-1',
    titulo: titulo,
    fecha: fecha,
    horaInicio: hora,
    completada: completada,
    creadoEn: DateTime.utc(2026, 8, 31),
    actualizadoEn: DateTime.utc(2026, 8, 31),
  );
}

void main() {
  testWidgets('el itinerario agrupa actividades por día', (tester) async {
    final viaje = _viaje();
    final actividades = _ActividadesFalsas([
      _actividad(
        id: 'a1',
        titulo: 'Llegada',
        fecha: DateTime(2026, 9, 10),
        hora: '09:00',
      ),
      _actividad(
        id: 'a2',
        titulo: 'Cena',
        fecha: DateTime(2026, 9, 10),
        hora: '20:00',
      ),
      _actividad(id: 'a3', titulo: 'San Jacinto', fecha: DateTime(2026, 9, 11)),
    ]);

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

    expect(find.text('10 de septiembre de 2026'), findsOneWidget);
    expect(find.text('11 de septiembre de 2026'), findsOneWidget);
    expect(find.text('Llegada'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('San Jacinto'), findsOneWidget);
  });

  testWidgets('una actividad puede marcarse como completada', (tester) async {
    final viaje = _viaje();
    final actividad = _actividad(
      id: 'a1',
      titulo: 'Llegada',
      fecha: DateTime(2026, 9, 10),
    );
    final actividades = _ActividadesFalsas([actividad]);

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

    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);

    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(actividades.actividades.first.completada, isTrue);
  });
}
