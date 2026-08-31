import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    RouterApp.router.go(RutasApp.inicio);
  });

  testWidgets('la aplicación inicia con la navegación principal', (
    tester,
  ) async {
    RouterApp.router.go(RutasApp.inicio);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Viajes'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('la barra inferior permite cambiar entre secciones', (
    tester,
  ) async {
    RouterApp.router.go(RutasApp.inicio);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Viajes'));
    await tester.pumpAndSettle();

    expect(
      find.text('La gestión de viajes se implementará en la etapa del CRUD.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Esta sección reunirá información útil asociada a los destinos.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'El perfil y los ajustes se implementarán en su etapa funcional.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('una ruta anidada de viajes mantiene la navegación inferior', (
    tester,
  ) async {
    await tester.pumpWidget(const DestinoPlusApp());

    RouterApp.router.go(RutasApp.detalleDeViaje('42'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.text(
        'Detalle provisional del viaje 42. Su contenido real se '
        'implementará en la etapa del CRUD.',
      ),
      findsOneWidget,
    );
  });
}
