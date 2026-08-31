import 'package:destino_plus/app/destino_plus_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la presentación muestra la identidad base de Destino+', (
    tester,
  ) async {
    await tester.pumpWidget(const DestinoPlusApp());

    expect(find.text('Destino+'), findsOneWidget);
    expect(
      find.text('Organiza tu destino. Disfruta el camino.'),
      findsOneWidget,
    );
    expect(
      find.text('Tus viajes, más claros desde el primer paso.'),
      findsOneWidget,
    );
    expect(find.text('Proyecto en desarrollo'), findsOneWidget);
  });
}
