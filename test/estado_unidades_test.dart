import 'package:destino_plus/app/preferencias/estado_unidades.dart';
import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
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
  group('EstadoUnidades', () {
    test('Celsius es la unidad predeterminada', () {
      final estado = EstadoUnidades(
        servicio: ServicioPreferenciasLocales(
          almacen: _AlmacenPreferenciasFalso(),
        ),
      );

      expect(estado.temperatura, UnidadTemperatura.celsius);
      expect(estado.cargado, isFalse);
    });

    test('carga Fahrenheit cuando estaba guardado', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(
        almacen: almacen,
      );
      await servicio.guardarUnidadTemperatura('fahrenheit');

      final estado = EstadoUnidades(servicio: servicio);
      await estado.cargar();

      expect(estado.temperatura, UnidadTemperatura.fahrenheit);
      expect(estado.cargado, isTrue);
    });

    test('valor desconocido vuelve a Celsius', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(
        almacen: almacen,
      );
      await servicio.guardarUnidadTemperatura('kelvin');

      final estado = EstadoUnidades(servicio: servicio);
      await estado.cargar();

      expect(estado.temperatura, UnidadTemperatura.celsius);
    });

    test('Fahrenheit se persiste y Celsius elimina la preferencia', () async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicio = ServicioPreferenciasLocales(
        almacen: almacen,
      );
      final estado = EstadoUnidades(servicio: servicio);

      await estado.cargar();
      await estado.cambiarTemperatura(
        UnidadTemperatura.fahrenheit,
      );

      expect(estado.temperatura, UnidadTemperatura.fahrenheit);
      expect(
        await servicio.leerUnidadTemperatura(),
        'fahrenheit',
      );

      await estado.cambiarTemperatura(
        UnidadTemperatura.celsius,
      );

      expect(estado.temperatura, UnidadTemperatura.celsius);
      expect(await servicio.leerUnidadTemperatura(), isNull);
    });

    test('convierte Celsius a Fahrenheit para presentación', () {
      expect(
        UnidadTemperatura.celsius.convertirDesdeCelsius(20),
        20,
      );
      expect(
        UnidadTemperatura.fahrenheit.convertirDesdeCelsius(20),
        68,
      );
      expect(UnidadTemperatura.celsius.simbolo, '°C');
      expect(UnidadTemperatura.fahrenheit.simbolo, '°F');
    });
  });
}
