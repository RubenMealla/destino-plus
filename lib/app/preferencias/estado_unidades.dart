import 'package:flutter/foundation.dart';

import 'servicio_preferencias_locales.dart';

/// Unidad utilizada para presentar temperaturas meteorológicas.
enum UnidadTemperatura {
  celsius,
  fahrenheit,
}

extension UnidadTemperaturaX on UnidadTemperatura {
  String get valorPersistido => name;

  String get etiqueta {
    return switch (this) {
      UnidadTemperatura.celsius => 'Celsius',
      UnidadTemperatura.fahrenheit => 'Fahrenheit',
    };
  }

  String get simbolo {
    return switch (this) {
      UnidadTemperatura.celsius => '°C',
      UnidadTemperatura.fahrenheit => '°F',
    };
  }

  /// Open-Meteo se consulta actualmente en Celsius.
  ///
  /// Esta función convierte únicamente la presentación de los datos y evita
  /// repetir fórmulas de conversión en las pantallas.
  double convertirDesdeCelsius(double valor) {
    return switch (this) {
      UnidadTemperatura.celsius => valor,
      UnidadTemperatura.fahrenheit => (valor * 9 / 5) + 32,
    };
  }

  static UnidadTemperatura desdeValorPersistido(String? valor) {
    return UnidadTemperatura.values.firstWhere(
      (unidad) => unidad.valorPersistido == valor,
      orElse: () => UnidadTemperatura.celsius,
    );
  }
}

/// Estado global de las preferencias de unidades de Destino+.
class EstadoUnidades extends ChangeNotifier {
  EstadoUnidades({
    ServicioPreferenciasLocales? servicio,
  }) : _servicio = servicio ?? ServicioPreferenciasLocales();

  static final EstadoUnidades instancia = EstadoUnidades();

  final ServicioPreferenciasLocales _servicio;

  UnidadTemperatura _temperatura = UnidadTemperatura.celsius;
  bool _cargado = false;

  UnidadTemperatura get temperatura => _temperatura;

  bool get cargado => _cargado;

  Future<void> cargar() async {
    try {
      final valor = await _servicio.leerUnidadTemperatura();
      _temperatura =
          UnidadTemperaturaX.desdeValorPersistido(valor);
    } catch (_) {
      _temperatura = UnidadTemperatura.celsius;
    } finally {
      _cargado = true;
      notifyListeners();
    }
  }

  Future<void> cambiarTemperatura(
    UnidadTemperatura nuevaUnidad,
  ) async {
    if (_temperatura == nuevaUnidad && _cargado) {
      return;
    }

    // Celsius es el valor predeterminado. No hace falta ocupar
    // almacenamiento cuando el usuario vuelve a esa opción.
    if (nuevaUnidad == UnidadTemperatura.celsius) {
      await _servicio.eliminarUnidadTemperatura();
    } else {
      await _servicio.guardarUnidadTemperatura(
        nuevaUnidad.valorPersistido,
      );
    }

    _temperatura = nuevaUnidad;
    _cargado = true;
    notifyListeners();
  }
}
