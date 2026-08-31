import 'package:destino_plus/app/preferencias/estado_apariencia.dart';
import 'package:destino_plus/app/preferencias/estado_unidades.dart';
import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _AlmacenPreferenciasPersistente implements AlmacenPreferencias {
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
  group('Persistencia entre reinicios simulados', () {
    test('apariencia oscura se recupera en una nueva instancia', () async {
      final almacen = _AlmacenPreferenciasPersistente();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);

      final primeraSesion = EstadoApariencia(servicio: servicio);
      await primeraSesion.cargar();
      await primeraSesion.cambiarModo(ModoApariencia.oscuro);

      expect(primeraSesion.themeMode, ThemeMode.dark);
      expect(await servicio.leerModoApariencia(), 'oscuro');

      final segundaSesion = EstadoApariencia(servicio: servicio);
      await segundaSesion.cargar();

      expect(segundaSesion.modo, ModoApariencia.oscuro);
      expect(segundaSesion.themeMode, ThemeMode.dark);
      expect(segundaSesion.cargado, isTrue);
    });

    test('Fahrenheit se recupera en una nueva instancia', () async {
      final almacen = _AlmacenPreferenciasPersistente();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);

      final primeraSesion = EstadoUnidades(servicio: servicio);
      await primeraSesion.cargar();
      await primeraSesion.cambiarTemperatura(
        UnidadTemperatura.fahrenheit,
      );

      expect(
        primeraSesion.temperatura,
        UnidadTemperatura.fahrenheit,
      );
      expect(
        await servicio.leerUnidadTemperatura(),
        'fahrenheit',
      );

      final segundaSesion = EstadoUnidades(servicio: servicio);
      await segundaSesion.cargar();

      expect(
        segundaSesion.temperatura,
        UnidadTemperatura.fahrenheit,
      );
      expect(segundaSesion.cargado, isTrue);
    });

    test('volver a valores predeterminados elimina persistencia explícita',
        () async {
      final almacen = _AlmacenPreferenciasPersistente();
      final servicio = ServicioPreferenciasLocales(almacen: almacen);

      final apariencia = EstadoApariencia(servicio: servicio);
      final unidades = EstadoUnidades(servicio: servicio);

      await apariencia.cargar();
      await unidades.cargar();

      await apariencia.cambiarModo(ModoApariencia.oscuro);
      await unidades.cambiarTemperatura(
        UnidadTemperatura.fahrenheit,
      );

      expect(await servicio.leerModoApariencia(), 'oscuro');
      expect(
        await servicio.leerUnidadTemperatura(),
        'fahrenheit',
      );

      await apariencia.cambiarModo(ModoApariencia.sistema);
      await unidades.cambiarTemperatura(
        UnidadTemperatura.celsius,
      );

      expect(await servicio.leerModoApariencia(), isNull);
      expect(await servicio.leerUnidadTemperatura(), isNull);

      final aparienciaNueva = EstadoApariencia(servicio: servicio);
      final unidadesNuevas = EstadoUnidades(servicio: servicio);

      await aparienciaNueva.cargar();
      await unidadesNuevas.cargar();

      expect(aparienciaNueva.modo, ModoApariencia.sistema);
      expect(
        unidadesNuevas.temperatura,
        UnidadTemperatura.celsius,
      );
    });
  });
}
