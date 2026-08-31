import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/auth/estado/estado_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _appDePrueba({
  String rutaInicial = RutasApp.inicioSesion,
}) {
  final router = RouterApp.crear(
    protegerRutas: false,
    ubicacionInicial: rutaInicial,
  );

  return ChangeNotifierProvider<EstadoSesion>.value(
    value: EstadoSesion.instancia,
    child: MaterialApp.router(
      theme: TemaApp.claro,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('el acceso valida campos vacíos', (tester) async {
    await tester.pumpWidget(_appDePrueba());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión').first);
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('se puede navegar de acceso a registro', (tester) async {
    await tester.pumpWidget(_appDePrueba());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });

  testWidgets('registro detecta contraseñas diferentes', (tester) async {
    await tester.pumpWidget(
      _appDePrueba(rutaInicial: RutasApp.registro),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);

    await tester.enterText(campos.at(0), 'Ana');
    await tester.enterText(campos.at(1), 'ana@ejemplo.com');
    await tester.enterText(campos.at(2), '123456');
    await tester.enterText(campos.at(3), '654321');

    await tester.tap(find.text('Crear cuenta').first);
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
  });
}
