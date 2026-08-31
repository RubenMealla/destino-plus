import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    RouterApp.router.go(RutasApp.inicioSesion);
  });

  testWidgets('la aplicación inicia en la pantalla de acceso', (tester) async {
    RouterApp.router.go(RutasApp.inicioSesion);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
  });

  testWidgets('el acceso valida campos vacíos', (tester) async {
    RouterApp.router.go(RutasApp.inicioSesion);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión').first);
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('se puede navegar de acceso a registro', (tester) async {
    RouterApp.router.go(RutasApp.inicioSesion);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });

  testWidgets('registro detecta contraseñas diferentes', (tester) async {
    RouterApp.router.go(RutasApp.registro);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(
        find.byType(TextFormField),
        'Nombre',
      ),
      'Ana',
    );
    await tester.enterText(
      find.widgetWithText(
        find.byType(TextFormField),
        'Correo electrónico',
      ),
      'ana@ejemplo.com',
    );

    final camposClave = find.byType(TextFormField);
    await tester.enterText(camposClave.at(2), '123456');
    await tester.enterText(camposClave.at(3), '654321');

    await tester.tap(find.text('Crear cuenta').first);
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
  });
}
