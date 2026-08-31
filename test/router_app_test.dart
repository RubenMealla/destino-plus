import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las rutas dinámicas construyen direcciones válidas', () {
    expect(RutasApp.detalleDeViaje('42'), '/viajes/42');
    expect(RutasApp.edicionDeViaje('42'), '/viajes/42/editar');
  });

  testWidgets('una ruta protegida redirige al acceso sin sesión', (
    tester,
  ) async {
    final router = RouterApp.crear(
      ubicacionInicial: RutasApp.viajes,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: TemaApp.claro,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    router.dispose();
  });
}
