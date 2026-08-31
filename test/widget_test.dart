import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Destino+ inicia en el acceso cuando no existe sesión', (
    tester,
  ) async {
    await tester.pumpWidget(const DestinoPlusApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
  });
}
