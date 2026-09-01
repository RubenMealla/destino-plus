import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/clima_reciente.dart';
import '../servicios/servicio_clima_destino.dart';

/// Mantiene las últimas consultas de clima y las persiste en el dispositivo.
class EstadoClimasRecientes extends ChangeNotifier {
  EstadoClimasRecientes({bool cargadoInicialmente = false})
    : _cargado = cargadoInicialmente;

  static final EstadoClimasRecientes instancia = EstadoClimasRecientes();

  static const _clave = 'clima.consultas_recientes.v1';
  static const int maximoConsultas = 3;

  List<ClimaReciente> _consultas = const [];
  bool _cargado;

  List<ClimaReciente> get consultas => List.unmodifiable(_consultas);
  bool get cargado => _cargado;

  Future<void> cargar() async {
    if (_cargado) {
      return;
    }

    try {
      final preferencias = SharedPreferencesAsync();
      final texto = await preferencias.getString(_clave);
      if (texto == null || texto.trim().isEmpty) {
        _consultas = const [];
      } else {
        final datos = jsonDecode(texto);
        if (datos is! List) {
          _consultas = const [];
        } else {
          final consultas =
              datos
                  .whereType<Map>()
                  .map(
                    (item) =>
                        ClimaReciente.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList()
                ..sort((a, b) => b.consultadoEn.compareTo(a.consultadoEn));
          _consultas = consultas.take(maximoConsultas).toList(growable: false);
        }
      }
    } catch (_) {
      // Una caché dañada o una plataforma de preferencias no disponible
      // nunca debe impedir que la aplicación pueda iniciar.
      _consultas = const [];
    } finally {
      _cargado = true;
      notifyListeners();
    }
  }

  Future<void> registrar(ClimaDestino resultado) async {
    final nuevo = ClimaReciente.desdeResultado(resultado);
    final claveNueva = _normalizar(nuevo.ubicacion);

    final actualizadas = <ClimaReciente>[
      nuevo,
      for (final consulta in _consultas)
        if (_normalizar(consulta.ubicacion) != claveNueva) consulta,
    ];

    _consultas = actualizadas.take(maximoConsultas).toList(growable: false);
    _cargado = true;
    notifyListeners();

    await _persistirSinInterrumpirLaInterfaz();
  }

  Future<void> limpiar() async {
    _consultas = const [];
    _cargado = true;
    notifyListeners();

    try {
      final preferencias = SharedPreferencesAsync();
      await preferencias.remove(_clave);
    } catch (_) {
      // La limpieza visual ya se realizó; la persistencia se reintentará
      // naturalmente en una ejecución con almacenamiento disponible.
    }
  }

  Future<void> _persistirSinInterrumpirLaInterfaz() async {
    try {
      final preferencias = SharedPreferencesAsync();
      await preferencias.setString(
        _clave,
        jsonEncode(_consultas.map((consulta) => consulta.toJson()).toList()),
      );
    } catch (_) {
      // El clima obtenido sigue siendo válido en memoria aunque falle la caché.
    }
  }

  String _normalizar(String valor) => valor.trim().toLowerCase();
}
