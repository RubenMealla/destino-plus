import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../servicios/servicio_autenticacion.dart';

/// Estado global de la sesión del usuario.
///
/// Mantiene sincronizada la sesión de Supabase con la aplicación y notifica
/// a la navegación cuando el usuario inicia o cierra sesión.
class EstadoSesion extends ChangeNotifier {
  EstadoSesion._({
    ServicioAutenticacion? servicio,
  }) : _servicio = servicio ?? ServicioAutenticacion.instancia {
    _sesion = _servicio.sesionActual;
    _suscribirse();
  }

  static final EstadoSesion instancia = EstadoSesion._();

  final ServicioAutenticacion _servicio;

  Session? _sesion;
  StreamSubscription<AuthState>? _suscripcion;

  Session? get sesion => _sesion;

  User? get usuario => _sesion?.user;

  bool get autenticado => _sesion != null;

  Future<void> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    await _servicio.iniciarSesion(
      correo: correo,
      clave: clave,
    );

    _actualizarSesion(_servicio.sesionActual);
  }

  Future<ResultadoRegistro> registrar({
    required String nombre,
    required String correo,
    required String clave,
  }) async {
    final resultado = await _servicio.registrar(
      nombre: nombre,
      correo: correo,
      clave: clave,
    );

    _actualizarSesion(_servicio.sesionActual);

    return resultado;
  }

  Future<void> cerrarSesion() async {
    await _servicio.cerrarSesion();
    _actualizarSesion(null);
  }

  void _suscribirse() {
    _suscripcion = _servicio.cambiosDeAutenticacion.listen(
      (estado) => _actualizarSesion(estado.session),
    );
  }

  void _actualizarSesion(Session? nuevaSesion) {
    if (_sesion?.accessToken == nuevaSesion?.accessToken) {
      return;
    }

    _sesion = nuevaSesion;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
