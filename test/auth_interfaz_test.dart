import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/auth/estado/estado_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _appDePrueba({String rutaInicial = RutasApp.inicioSesion}) {
  final router = RouterApp.crear(
    protegerRutas: false,
    ubicacionInicial: rutaInicial,
  );

  return ChangeNotifierProvider<EstadoSesion>.value(
    value: EstadoSesion.instancia,
    child: MaterialApp.router(theme: TemaApp.claro, routerConfig: router),
  );
}

void main() {
  group('Inicio de sesión', () {
    testWidgets('valida campos vacíos', (tester) async {
      await tester.pumpWidget(_appDePrueba());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Iniciar sesión').first);
      await tester.tap(find.text('Iniciar sesión').first);
      await tester.pump();

      expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    });

    testWidgets('valida formato de correo y longitud de contraseña', (
      tester,
    ) async {
      await tester.pumpWidget(_appDePrueba());
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      expect(campos, findsNWidgets(2));

      await tester.enterText(campos.at(0), 'correo-invalido');
      await tester.enterText(campos.at(1), '123');

      await tester.ensureVisible(find.text('Iniciar sesión').first);
      await tester.tap(find.text('Iniciar sesión').first);
      await tester.pump();

      expect(
        find.text('Ingresa un correo electrónico válido.'),
        findsOneWidget,
      );
      expect(
        find.text('La contraseña debe tener al menos 6 caracteres.'),
        findsOneWidget,
      );
    });

    testWidgets('permite mostrar y volver a ocultar la contraseña', (
      tester,
    ) async {
      await tester.pumpWidget(_appDePrueba());
      await tester.pumpAndSettle();

      var campoClave = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );
      expect(campoClave.obscureText, isTrue);
      expect(find.byTooltip('Mostrar contraseña'), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Mostrar contraseña'));
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();

      campoClave = tester.widget<EditableText>(find.byType(EditableText).at(1));
      expect(campoClave.obscureText, isFalse);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Ocultar contraseña'));
      await tester.tap(find.byTooltip('Ocultar contraseña'));
      await tester.pump();

      campoClave = tester.widget<EditableText>(find.byType(EditableText).at(1));
      expect(campoClave.obscureText, isTrue);
    });

    testWidgets('se puede navegar de acceso a registro', (tester) async {
      await tester.pumpWidget(_appDePrueba());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Crear cuenta'));
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Crea tu cuenta'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);
    });
  });

  group('Registro', () {
    testWidgets('valida todos los campos obligatorios vacíos', (tester) async {
      await tester.pumpWidget(_appDePrueba(rutaInicial: RutasApp.registro));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Crear cuenta').first);
      await tester.tap(find.text('Crear cuenta').first);
      await tester.pump();

      expect(find.text('Ingresa tu nombre.'), findsOneWidget);
      expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
      expect(find.text('Ingresa una contraseña.'), findsOneWidget);
      expect(find.text('Confirma tu contraseña.'), findsOneWidget);
    });

    testWidgets('valida nombre corto correo inválido y contraseña corta', (
      tester,
    ) async {
      await tester.pumpWidget(_appDePrueba(rutaInicial: RutasApp.registro));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      expect(campos, findsNWidgets(4));

      await tester.enterText(campos.at(0), 'A');
      await tester.enterText(campos.at(1), 'correo-invalido');
      await tester.enterText(campos.at(2), '123');
      await tester.enterText(campos.at(3), '123');

      await tester.ensureVisible(find.text('Crear cuenta').first);
      await tester.tap(find.text('Crear cuenta').first);
      await tester.pump();

      expect(
        find.text('El nombre debe tener al menos 2 caracteres.'),
        findsOneWidget,
      );
      expect(
        find.text('Ingresa un correo electrónico válido.'),
        findsOneWidget,
      );
      expect(
        find.text('La contraseña debe tener al menos 6 caracteres.'),
        findsOneWidget,
      );
    });

    testWidgets('detecta contraseñas diferentes', (tester) async {
      await tester.pumpWidget(_appDePrueba(rutaInicial: RutasApp.registro));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'Ana');
      await tester.enterText(campos.at(1), 'ana@ejemplo.com');
      await tester.enterText(campos.at(2), '123456');
      await tester.enterText(campos.at(3), '654321');

      await tester.ensureVisible(find.text('Crear cuenta').first);
      await tester.tap(find.text('Crear cuenta').first);
      await tester.pump();

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });

    testWidgets('puede volver desde registro al inicio de sesión', (
      tester,
    ) async {
      await tester.pumpWidget(_appDePrueba(rutaInicial: RutasApp.registro));
      await tester.pumpAndSettle();

      expect(find.text('Crea tu cuenta'), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Volver'));
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();

      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    });
  });
}
