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
class EstadoApariencia extends ChangeNotifier {
  EstadoApariencia({
    ServicioPreferenciasLocales? servicio,
  }) : _servicio = servicio ?? ServicioPreferenciasLocales();

  static final EstadoApariencia instancia = EstadoApariencia();

  final ServicioPreferenciasLocales _servicio;

  ModoApariencia _modo = ModoApariencia.sistema;
  bool _cargado = false;

  ModoApariencia get modo => _modo;

  ThemeMode get themeMode => _modo.themeMode;

  bool get cargado => _cargado;

  /// Recupera la preferencia guardada.
  ///
  /// Si el almacenamiento local no está disponible, la aplicación puede
  /// continuar usando la apariencia del sistema.
  Future<void> cargar() async {
    try {
      final valor = await _servicio.leerModoApariencia();
      _modo = ModoAparienciaX.desdeValorPersistido(valor);
    } catch (_) {
      _modo = ModoApariencia.sistema;
    } finally {
      _cargado = true;
      notifyListeners();
    }
  }

  /// Persiste un nuevo modo y actualiza la interfaz después de guardarlo.
  Future<void> cambiarModo(ModoApariencia nuevoModo) async {
    if (_modo == nuevoModo && _cargado) {
      return;
    }

    if (nuevoModo == ModoApariencia.sistema) {
      await _servicio.eliminarModoApariencia();
    } else {
      await _servicio.guardarModoApariencia(
        nuevoModo.valorPersistido,
      );
    }

    _modo = nuevoModo;
    _cargado = true;
    notifyListeners();
  }
}
