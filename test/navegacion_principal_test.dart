import 'package:destino_plus/app/preferencias/estado_apariencia.dart';
import 'package:destino_plus/app/preferencias/estado_unidades.dart';
import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/auth/estado/estado_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Widget _appConRouter(GoRouter router) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EstadoSesion>.value(
        value: EstadoSesion.instancia,
      ),
      ChangeNotifierProvider<EstadoApariencia>.value(
        value: EstadoApariencia.instancia,
      ),
      ChangeNotifierProvider<EstadoUnidades>.value(
        value: EstadoUnidades.instancia,
      ),
    ],
    child: MaterialApp.router(
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('la barra inferior permite cambiar entre secciones', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: false,
      ubicacionInicial: RutasApp.inicio,
    );

    await tester.pumpWidget(_appConRouter(router));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Viajes'));
    await tester.pumpAndSettle();
    expect(find.text('Organiza tus viajes'), findsOneWidget);

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();
    expect(find.text('Clima del destino'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('una ruta anidada mantiene la navegación inferior', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: false,
      ubicacionInicial: RutasApp.nuevoViaje,
    );

    await tester.pumpWidget(_appConRouter(router));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Nuevo viaje'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
