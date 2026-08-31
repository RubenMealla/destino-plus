import 'package:destino_plus/features/clima/presentacion/clima_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('traduce códigos meteorológicos conocidos', () {
    expect(ClimaVisual.descripcion(0), 'Despejado');
    expect(ClimaVisual.descripcion(3), 'Nublado');
    expect(ClimaVisual.descripcion(61), 'Lluvia');
    expect(ClimaVisual.descripcion(95), 'Tormenta');
  });

  test('usa texto seguro para un código desconocido', () {
    expect(
      ClimaVisual.descripcion(500),
      'Condiciones variables',
    );
  });

  test('el código despejado distingue día y noche', () {
    expect(
      ClimaVisual.icono(0, esDeDia: true),
      Icons.wb_sunny_outlined,
    );
    expect(
      ClimaVisual.icono(0, esDeDia: false),
      Icons.nightlight_outlined,
    );
  });
}
