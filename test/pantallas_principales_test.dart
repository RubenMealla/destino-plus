import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _probarRuta(
  WidgetTester tester, {
  required String ruta,
  required String textoEsperado,
}) async {
  final router = RouterApp.crear(
    protegerRutas: false,
    ubicacionInicial: ruta,
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: TemaApp.claro,
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text(textoEsperado), findsOneWidget);

  router.dispose();
}

void main() {
  testWidgets('Inicio muestra su estructura principal', (tester) async {
    await _probarRuta(
      tester,
      ruta: RutasApp.inicio,
      textoEsperado: 'Planifica tu próximo viaje',
    );
  });

  testWidgets('Viajes conserva su encabezado aunque no haya Supabase', (
    tester,
  ) async {
    await _probarRuta(
      tester,
      ruta: RutasApp.viajes,
      textoEsperado: 'Organiza tus viajes',
    );
  });

  testWidgets('Explorar muestra los servicios previstos', (tester) async {
    await _probarRuta(
      tester,
      ruta: RutasApp.explorar,
      textoEsperado: 'Clima del destino',
    );
  });

  testWidgets('Perfil muestra su estructura inicial', (tester) async {
    await _probarRuta(
      tester,
      ruta: RutasApp.perfil,
      textoEsperado: 'Ajustes',
    );
  });
}
