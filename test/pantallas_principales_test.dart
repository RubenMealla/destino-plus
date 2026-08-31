import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:destino_plus/app/router/router_app.dart';
import 'package:destino_plus/app/router/rutas_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    RouterApp.router.go(RutasApp.inicio);
  });

  testWidgets('Inicio muestra su estructura principal', (tester) async {
    RouterApp.router.go(RutasApp.inicio);

    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    expect(find.text('Planifica tu próximo viaje'), findsOneWidget);
    expect(find.text('Próximos viajes'), findsOneWidget);
    expect(find.text('Información del destino'), findsOneWidget);
  });

  testWidgets('Viajes muestra su estado inicial', (tester) async {
    await tester.pumpWidget(const DestinoPlusApp());

    RouterApp.router.go(RutasApp.viajes);
    await tester.pumpAndSettle();

    expect(find.text('Organiza tus viajes'), findsOneWidget);
    expect(find.text('Todavía no tienes viajes'), findsOneWidget);
    expect(find.text('Vista previa de nuevo viaje'), findsOneWidget);
  });

  testWidgets('Explorar muestra los servicios previstos', (tester) async {
    await tester.pumpWidget(const DestinoPlusApp());

    RouterApp.router.go(RutasApp.explorar);
    await tester.pumpAndSettle();

    expect(find.text('Explora antes de viajar'), findsOneWidget);
    expect(find.text('Clima del destino'), findsOneWidget);
    expect(find.text('Ubicación'), findsOneWidget);
  });

  testWidgets('Perfil muestra su estructura inicial', (tester) async {
    await tester.pumpWidget(const DestinoPlusApp());

    RouterApp.router.go(RutasApp.perfil);
    await tester.pumpAndSettle();

    expect(find.text('Usuario de Destino+'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Preferencias'), findsOneWidget);
  });
}
