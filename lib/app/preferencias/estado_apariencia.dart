import 'package:flutter/material.dart';

import 'servicio_preferencias_locales.dart';

/// Modos de apariencia disponibles en Destino+.
enum ModoApariencia {
  sistema,
  claro,
  oscuro,
}

extension ModoAparienciaX on ModoApariencia {
  String get valorPersistido => name;

  String get etiqueta {
    return switch (this) {
      ModoApariencia.sistema => 'Sistema',
      ModoApariencia.claro => 'Claro',
      ModoApariencia.oscuro => 'Oscuro',
    };
  }

  ThemeMode get themeMode {
    return switch (this) {
      ModoApariencia.sistema => ThemeMode.system,
      ModoApariencia.claro => ThemeMode.light,
      ModoApariencia.oscuro => ThemeMode.dark,
    };
  }

  static ModoApariencia desdeValorPersistido(String? valor) {
    return ModoApariencia.values.firstWhere(
      (modo) => modo.valorPersistido == valor,
      orElse: () => ModoApariencia.sistema,
    );
  }
}

/// Estado global encargado de la apariencia persistente de Destino+.
///
/// La interfaz se integrará con este estado en el siguiente commit. Esta clase
/// concentra la carga, el cambio y la persistencia del modo seleccionado.
class EstadoApariencia extends ChangeNotifier {
  EstadoApariencia({
    ServicioPreferenciasLocales? servicio,
  }) : _servicio = servicio ?? ServicioPreferenciasLocales();

  final ServicioPreferenciasLocales _servicio;

  ModoApariencia _modo = ModoApariencia.sistema;
  bool _cargado = false;

  ModoApariencia get modo => _modo;

  ThemeMode get themeMode => _modo.themeMode;

  bool get cargado => _cargado;

  Future<void> cargar() async {
    final valor = await _servicio.leerModoApariencia();
    _modo = ModoAparienciaX.desdeValorPersistido(valor);
    _cargado = true;
    notifyListeners();
  }

  Future<void> cambiarModo(ModoApariencia nuevoModo) async {
    if (_modo == nuevoModo && _cargado) {
      return;
    }

    _modo = nuevoModo;
    _cargado = true;
    notifyListeners();

    if (nuevoModo == ModoApariencia.sistema) {
      await _servicio.eliminarModoApariencia();
      return;
    }

    await _servicio.guardarModoApariencia(
      nuevoModo.valorPersistido,
    );
  }
}
