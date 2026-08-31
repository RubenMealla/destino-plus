import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    RouterApp.router.go(RutasApp.presentacion);
  });

  test('las rutas dinámicas construyen direcciones válidas', () {
    expect(RutasApp.detalleDeViaje('42'), '/viajes/42');
    expect(RutasApp.edicionDeViaje('42'), '/viajes/42/editar');
  });

  testWidgets('la aplicación inicia en la presentación', (tester) async {
    RouterApp.router.go(RutasApp.presentacion);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    expect(find.text('Destino+'), findsOneWidget);
  });

  testWidgets('la ruta de viajes está registrada', (tester) async {
    await tester.pumpWidget(const DestinoPlusApp());

    RouterApp.router.go(RutasApp.viajes);
    await tester.pumpAndSettle();

    expect(find.text('Viajes'), findsOneWidget);
    expect(
      find.text('La gestión de viajes se implementará en la etapa del CRUD.'),
      findsOneWidget,
    );
  });
}
