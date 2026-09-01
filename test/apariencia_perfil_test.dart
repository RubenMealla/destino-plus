import 'package:destino_plus/app/preferencias/estado_apariencia.dart';
import 'package:destino_plus/app/preferencias/estado_unidades.dart';
import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/auth/estado/estado_sesion.dart';
import 'package:destino_plus/features/perfil/pantalla_perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _AlmacenPreferenciasFalso implements AlmacenPreferencias {
  final Map<String, Object> datos = {};

  @override
  Future<String?> leerTexto(String clave) async {
    final valor = datos[clave];
    return valor is String ? valor : null;
  }

  @override
  Future<bool?> leerBooleano(String clave) async {
    final valor = datos[clave];
    return valor is bool ? valor : null;
  }

  @override
  Future<int?> leerEntero(String clave) async {
    final valor = datos[clave];
    return valor is int ? valor : null;
  }

  @override
  Future<void> guardarTexto(String clave, String valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> guardarBooleano(String clave, bool valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> guardarEntero(String clave, int valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> eliminar(String clave) async {
    datos.remove(clave);
  }
}

Widget _appDePrueba(EstadoApariencia apariencia, EstadoUnidades unidades) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EstadoSesion>.value(value: EstadoSesion.instancia),
      ChangeNotifierProvider<EstadoApariencia>.value(value: apariencia),
      ChangeNotifierProvider<EstadoUnidades>.value(value: unidades),
    ],
    child: Consumer<EstadoApariencia>(
      builder: (context, estado, child) {
        return MaterialApp(
          theme: TemaApp.claro,
          darkTheme: TemaApp.oscuro,
          themeMode: estado.themeMode,
          home: const PantallaPerfil(),
        );
      },
    ),
  );
}

void main() {
  testWidgets('Perfil permite cambiar y persistir el modo oscuro', (
    tester,
  ) async {
    final almacen = _AlmacenPreferenciasFalso();
    final servicio = ServicioPreferenciasLocales(almacen: almacen);
    final apariencia = EstadoApariencia(servicio: servicio);
    final unidades = EstadoUnidades(servicio: servicio);
    await apariencia.cargar();
    await unidades.cargar();

    await tester.pumpWidget(_appDePrueba(apariencia, unidades));
    await tester.pumpAndSettle();

    expect(find.text('Sistema'), findsWidgets);
    expect(apariencia.themeMode, ThemeMode.system);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Oscuro'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Oscuro'));
    await tester.pumpAndSettle();

    expect(apariencia.modo, ModoApariencia.oscuro);
    expect(apariencia.themeMode, ThemeMode.dark);
    expect(await servicio.leerModoApariencia(), 'oscuro');

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('Perfil puede volver al modo del sistema', (tester) async {
    final almacen = _AlmacenPreferenciasFalso();
    final servicio = ServicioPreferenciasLocales(almacen: almacen);
    final apariencia = EstadoApariencia(servicio: servicio);
    final unidades = EstadoUnidades(servicio: servicio);

    await apariencia.cargar();
    await unidades.cargar();
    await apariencia.cambiarModo(ModoApariencia.oscuro);

    await tester.pumpWidget(_appDePrueba(apariencia, unidades));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Sistema'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sistema'));
    await tester.pumpAndSettle();

    expect(apariencia.modo, ModoApariencia.sistema);
    expect(apariencia.themeMode, ThemeMode.system);
    expect(await servicio.leerModoApariencia(), isNull);
  });

  testWidgets('Perfil permite seleccionar Fahrenheit y persistirlo', (
    tester,
  ) async {
    final almacen = _AlmacenPreferenciasFalso();
    final servicio = ServicioPreferenciasLocales(almacen: almacen);
    final apariencia = EstadoApariencia(servicio: servicio);
    final unidades = EstadoUnidades(servicio: servicio);

    await apariencia.cargar();
    await unidades.cargar();

    await tester.pumpWidget(_appDePrueba(apariencia, unidades));
    await tester.pumpAndSettle();

    expect(find.text('Celsius (°C)'), findsOneWidget);
    expect(find.text('Fahrenheit (°F)'), findsOneWidget);

    await tester.ensureVisible(
      find.widgetWithText(ChoiceChip, 'Fahrenheit (°F)'),
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Fahrenheit (°F)'));
    await tester.pumpAndSettle();

    expect(unidades.temperatura, UnidadTemperatura.fahrenheit);
    expect(await servicio.leerUnidadTemperatura(), 'fahrenheit');
  });
}
