import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la barra inferior permite cambiar entre secciones', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: false,
      ubicacionInicial: RutasApp.inicio,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: TemaApp.claro,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Viajes'));
    await tester.pumpAndSettle();
    expect(find.text('Organiza tus viajes'), findsOneWidget);

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();
    expect(find.text('Explora antes de viajar'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsWidgets);

    router.dispose();
  });

  testWidgets('una ruta anidada mantiene la navegación inferior', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: false,
      ubicacionInicial: RutasApp.detalleDeViaje('42'),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: TemaApp.claro,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Detalle del viaje'), findsOneWidget);

    router.dispose();
  });
}
