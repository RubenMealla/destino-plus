import 'package:shared_preferences/shared_preferences.dart';

/// Contrato mínimo para almacenar preferencias simples del dispositivo.
///
/// Destino+ utiliza esta capa para evitar que la interfaz dependa directamente
/// de `shared_preferences`.
abstract interface class AlmacenPreferencias {
  Future<String?> leerTexto(String clave);

  Future<bool?> leerBooleano(String clave);

  Future<int?> leerEntero(String clave);

  Future<void> guardarTexto(String clave, String valor);

  Future<void> guardarBooleano(String clave, bool valor);

  Future<void> guardarEntero(String clave, int valor);

  Future<void> eliminar(String clave);
}

/// Implementación real mediante `shared_preferences`.
class AlmacenPreferenciasSharedPreferences implements AlmacenPreferencias {
  factory AlmacenPreferenciasSharedPreferences({
    SharedPreferencesAsync? preferencias,
  }) {
    return AlmacenPreferenciasSharedPreferences._(preferencias);
  }

  AlmacenPreferenciasSharedPreferences._(this._preferencias);

  SharedPreferencesAsync? _preferencias;

  SharedPreferencesAsync get _instancia =>
      _preferencias ??= SharedPreferencesAsync();

  @override
  Future<String?> leerTexto(String clave) {
    return _instancia.getString(clave);
  }

  @override
  Future<bool?> leerBooleano(String clave) {
    return _instancia.getBool(clave);
  }

  @override
  Future<int?> leerEntero(String clave) {
    return _instancia.getInt(clave);
  }

  @override
  Future<void> guardarTexto(String clave, String valor) async {
    await _instancia.setString(clave, valor);
  }

  @override
  Future<void> guardarBooleano(String clave, bool valor) async {
    await _instancia.setBool(clave, valor);
  }

  @override
  Future<void> guardarEntero(String clave, int valor) async {
    await _instancia.setInt(clave, valor);
  }

  @override
  Future<void> eliminar(String clave) async {
    await _instancia.remove(clave);
  }
}

/// Punto único de acceso a las preferencias locales de Destino+.
///
/// Las claves concretas se mantienen aquí para evitar literales dispersos por
/// las pantallas.
class ServicioPreferenciasLocales {
  ServicioPreferenciasLocales({AlmacenPreferencias? almacen})
    : _almacen = almacen ?? AlmacenPreferenciasSharedPreferences();

  final AlmacenPreferencias _almacen;

  static const String _claveModoApariencia = 'preferencias.modo_apariencia';
  static const String _claveUnidadTemperatura =
      'preferencias.unidad_temperatura';

  Future<String?> leerModoApariencia() {
    return _almacen.leerTexto(_claveModoApariencia);
  }

  Future<void> guardarModoApariencia(String valor) {
    return _almacen.guardarTexto(_claveModoApariencia, valor);
  }

  Future<void> eliminarModoApariencia() {
    return _almacen.eliminar(_claveModoApariencia);
  }

  Future<String?> leerUnidadTemperatura() {
    return _almacen.leerTexto(_claveUnidadTemperatura);
  }

  Future<void> guardarUnidadTemperatura(String valor) {
    return _almacen.guardarTexto(_claveUnidadTemperatura, valor);
  }

  Future<void> eliminarUnidadTemperatura() {
    return _almacen.eliminar(_claveUnidadTemperatura);
  }
}
