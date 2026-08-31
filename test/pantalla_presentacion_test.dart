import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/presentacion/pantalla_presentacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la presentación conserva la identidad visual de Destino+', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: const PantallaPresentacion(),
      ),
    );

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
