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

import 'package:destino_plus/features/clima/estado/estado_climas_recientes.dart';

Widget _appConRouter(GoRouter router) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EstadoSesion>.value(value: EstadoSesion.instancia),
      ChangeNotifierProvider<EstadoApariencia>.value(
        value: EstadoApariencia.instancia,
      ),
      ChangeNotifierProvider<EstadoUnidades>.value(
        value: EstadoUnidades.instancia,
      ),
      ChangeNotifierProvider<EstadoClimasRecientes>(
        create: (_) => EstadoClimasRecientes(cargadoInicialmente: true),
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
  testWidgets('la barra principal navega entre las cuatro secciones', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: false,
      ubicacionInicial: RutasApp.inicio,
    );

    await tester.pumpWidget(_appConRouter(router));
    await tester.pumpAndSettle();

    expect(find.text('Planifica tu próximo viaje'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.ensureVisible(find.text('Viajes'));
    await tester.tap(find.text('Viajes'));
    await tester.pumpAndSettle();
    expect(find.text('Organiza tus viajes'), findsOneWidget);

    await tester.ensureVisible(find.text('Explorar'));
    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();
    expect(find.text('Clima del destino'), findsOneWidget);

    await tester.ensureVisible(find.text('Perfil'));
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsOneWidget);

    await tester.ensureVisible(find.text('Inicio'));
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Planifica tu próximo viaje'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('una ruta protegida redirige al acceso sin sesión', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: true,
      ubicacionInicial: RutasApp.viajes,
    );

    await tester.pumpWidget(_appConRouter(router));
    await tester.pumpAndSettle();

    expect(EstadoSesion.instancia.autenticado, isFalse);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('registro permanece accesible sin una sesión iniciada', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: true,
      ubicacionInicial: RutasApp.registro,
    );

    await tester.pumpWidget(_appConRouter(router));
    await tester.pumpAndSettle();

    expect(EstadoSesion.instancia.autenticado, isFalse);
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('una ruta desconocida presenta un error comprensible', (
    tester,
  ) async {
    final router = RouterApp.crear(
      protegerRutas: false,
      ubicacionInicial: '/ruta-que-no-existe',
    );

    await tester.pumpWidget(_appConRouter(router));
    await tester.pumpAndSettle();

    expect(find.text('Ruta no disponible'), findsOneWidget);
    expect(
      find.text('No se pudo encontrar la pantalla solicitada.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
