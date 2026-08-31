import 'package:destino_plus/app/preferencias/estado_apariencia.dart';
import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  group('EstadoApariencia', () {
    test('inicia usando la apariencia del sistema', () {
      final estado = EstadoApariencia(
        servicio: ServicioPreferenciasLocales(
          almacen: _AlmacenPreferenciasFalso(),
        ),
      );

      expect(estado.modo, ModoApariencia.sistema);
      expect(estado.themeMode, ThemeMode.system);
      expect(estado.cargado, isFalse);
    });

    test('carga el modo oscuro guardado', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);
      await servicio.guardarModoApariencia('oscuro');

      final estado = EstadoApariencia(servicio: servicio);
      await estado.cargar();

      expect(estado.modo, ModoApariencia.oscuro);
      expect(estado.themeMode, ThemeMode.dark);
      expect(estado.cargado, isTrue);
    });

    test('valor desconocido vuelve al modo sistema', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);
      await servicio.guardarModoApariencia('valor-invalido');

      final estado = EstadoApariencia(servicio: servicio);
      await estado.cargar();

      expect(estado.modo, ModoApariencia.sistema);
      expect(estado.themeMode, ThemeMode.system);
    });

    test('cambiar a claro persiste la selección', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);
      final estado = EstadoApariencia(servicio: servicio);

      await estado.cargar();
      await estado.cambiarModo(ModoApariencia.claro);

      expect(estado.modo, ModoApariencia.claro);
      expect(estado.themeMode, ThemeMode.light);
      expect(await servicio.leerModoApariencia(), 'claro');
    });

    test('volver a sistema elimina la preferencia persistida', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);
      final estado = EstadoApariencia(servicio: servicio);

      await estado.cargar();
      await estado.cambiarModo(ModoApariencia.oscuro);
      expect(await servicio.leerModoApariencia(), 'oscuro');

      await estado.cambiarModo(ModoApariencia.sistema);

      expect(estado.modo, ModoApariencia.sistema);
      expect(estado.themeMode, ThemeMode.system);
      expect(await servicio.leerModoApariencia(), isNull);
    });

    test('las etiquetas visibles permanecen en español', () {
      expect(ModoApariencia.sistema.etiqueta, 'Sistema');
      expect(ModoApariencia.claro.etiqueta, 'Claro');
      expect(ModoApariencia.oscuro.etiqueta, 'Oscuro');
    });
  });
}
