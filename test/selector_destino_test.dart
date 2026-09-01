import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/cliente_open_meteo.dart';
import 'package:destino_plus/features/clima/widgets/selector_destino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _BusquedaFalsa implements FuenteBusquedaUbicaciones {
  int llamadas = 0;

  @override
  Future<List<UbicacionClima>> buscarUbicaciones(
    String consulta, {
    int limite = 5,
  }) async {
    llamadas += 1;

    return const [
      UbicacionClima(
        id: 1,
        nombre: 'Tarija, Bolivia',
        latitud: -21.535,
        longitud: -64.729,
        zonaHoraria: 'America/La_Paz',
      ),
    ];
  }
}

void main() {
  testWidgets('busca con debounce y selecciona un destino canónico', (
    tester,
  ) async {
    final controller = TextEditingController();
    final fuente = _BusquedaFalsa();
    UbicacionClima? seleccionada;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectorDestino(
            controller: controller,
            fuente: fuente,
            onSeleccionado: (valor) => seleccionada = valor,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('selector-destino-campo')),
      'Tarija',
    );

    await tester.pump(const Duration(milliseconds: 349));
    expect(fuente.llamadas, 0);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(fuente.llamadas, 1);
    expect(find.text('Tarija, Bolivia'), findsOneWidget);

    await tester.tap(find.text('Tarija, Bolivia'));
    await tester.pump();

    expect(controller.text, 'Tarija, Bolivia');
    expect(seleccionada, isNotNull);
    expect(seleccionada!.latitud, -21.535);
    expect(seleccionada!.longitud, -64.729);
  });
}
