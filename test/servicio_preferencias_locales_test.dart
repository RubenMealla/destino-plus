import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
import 'package:flutter_test/flutter_test.dart';

class _AlmacenPreferenciasFalso implements AlmacenPreferencias {
  final Map<String, Object> _datos = {};

  @override
  Future<String?> leerTexto(String clave) async {
    final valor = _datos[clave];
    return valor is String ? valor : null;
  }

  @override
  Future<bool?> leerBooleano(String clave) async {
    final valor = _datos[clave];
    return valor is bool ? valor : null;
  }

  @override
  Future<int?> leerEntero(String clave) async {
    final valor = _datos[clave];
    return valor is int ? valor : null;
  }

  @override
  Future<void> guardarTexto(String clave, String valor) async {
    _datos[clave] = valor;
  }

  @override
  Future<void> guardarBooleano(String clave, bool valor) async {
    _datos[clave] = valor;
  }

  @override
  Future<void> guardarEntero(String clave, int valor) async {
    _datos[clave] = valor;
  }

  @override
  Future<void> eliminar(String clave) async {
    _datos.remove(clave);
  }
}

void main() {
  group('ServicioPreferenciasLocales', () {
    test('sin valor guardado devuelve null', () async {
      final servicio = ServicioPreferenciasLocales(
        almacen: _AlmacenPreferenciasFalso(),
      );

      expect(await servicio.leerModoApariencia(), isNull);
    });

    test('guarda y recupera el modo de apariencia', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(
        almacen: almacen,
      );

      await servicio.guardarModoApariencia('oscuro');

      expect(await servicio.leerModoApariencia(), 'oscuro');
    });

    test('puede eliminar el modo de apariencia guardado', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(
        almacen: almacen,
      );

      await servicio.guardarModoApariencia('claro');
      await servicio.eliminarModoApariencia();

      expect(await servicio.leerModoApariencia(), isNull);
    });
  });
}
