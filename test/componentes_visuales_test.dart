import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/shared/widgets/boton_accion.dart';
import 'package:destino_plus/shared/widgets/contenido_adaptable.dart';
import 'package:destino_plus/shared/widgets/encabezado_seccion.dart';
import 'package:destino_plus/shared/widgets/estado_vacio.dart';
import 'package:destino_plus/shared/widgets/tarjeta_informativa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envolver(Widget child) {
  return MaterialApp(
    theme: TemaApp.claro,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('los componentes base muestran su contenido', (tester) async {
    await tester.pumpWidget(
      _envolver(
        const ContenidoAdaptable(
          child: Column(
            children: [
              EncabezadoSeccion(
                titulo: 'Próximos viajes',
                subtitulo: 'Organiza tus siguientes destinos',
              ),
              TarjetaInformativa(
                titulo: 'Viaje de prueba',
                icono: Icons.flight_takeoff,
                child: Text('Contenido de prueba'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Próximos viajes'), findsOneWidget);
    expect(find.text('Organiza tus siguientes destinos'), findsOneWidget);
    expect(find.text('Viaje de prueba'), findsOneWidget);
    expect(find.text('Contenido de prueba'), findsOneWidget);
  });

  testWidgets('el botón de acción ejecuta su callback', (tester) async {
    var pulsado = false;

    await tester.pumpWidget(
      _envolver(
        BotonAccion(
          texto: 'Crear viaje',
          icono: Icons.add,
          onPressed: () => pulsado = true,
        ),
      ),
    );

    await tester.tap(find.text('Crear viaje'));
    await tester.pump();

    expect(pulsado, isTrue);
  });

  testWidgets('el estado vacío presenta mensaje y acción', (tester) async {
    await tester.pumpWidget(
      _envolver(
        EstadoVacio(
          icono: Icons.luggage_outlined,
          titulo: 'Todavía no tienes viajes',
          mensaje: 'Crea tu primer viaje para comenzar.',
          accion: BotonAccion(
            texto: 'Nuevo viaje',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Todavía no tienes viajes'), findsOneWidget);
    expect(find.text('Crea tu primer viaje para comenzar.'), findsOneWidget);
    expect(find.text('Nuevo viaje'), findsOneWidget);
  });
}
