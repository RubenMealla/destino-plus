import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Destino+ inicia con su identidad base', (tester) async {
    await tester.pumpWidget(const DestinoPlusApp());

    expect(find.text('Destino+'), findsOneWidget);
  });
}
