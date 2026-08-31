import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/config/configuracion_supabase.dart';

/// Error de autenticación listo para ser mostrado al usuario.
class ExcepcionAutenticacion implements Exception {
  const ExcepcionAutenticacion(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Resultado del registro de una cuenta.
class ResultadoRegistro {
  const ResultadoRegistro({
    required this.requiereConfirmacionCorreo,
  });

  final bool requiereConfirmacionCorreo;
}

/// Acceso centralizado a las operaciones de autenticación de Supabase.
///
/// La capa mantiene a las pantallas desacopladas de los detalles de la API.
/// En el siguiente commit será utilizada por el estado global de sesión.
class ServicioAutenticacion {
  const ServicioAutenticacion._();

  static const ServicioAutenticacion instancia = ServicioAutenticacion._();

  SupabaseClient get _cliente {
    if (!ConfiguracionSupabase.inicializado) {
      throw const ExcepcionAutenticacion(
        'Supabase todavía no está configurado. '
        'Inicia la aplicación con la URL y la clave pública del proyecto.',
      );
    }

    return Supabase.instance.client;
  }

  Session? get sesionActual {
    if (!ConfiguracionSupabase.inicializado) {
      return null;
    }

    return Supabase.instance.client.auth.currentSession;
  }

  Stream<AuthState> get cambiosDeAutenticacion {
    if (!ConfiguracionSupabase.inicializado) {
      return const Stream<AuthState>.empty();
    }

    return Supabase.instance.client.auth.onAuthStateChange;
  }

  Future<void> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    try {
      await _cliente.auth.signInWithPassword(
        email: correo.trim(),
        password: clave,
      );
    } on AuthException catch (error) {
      throw ExcepcionAutenticacion(_traducirError(error.message));
    } on ExcepcionAutenticacion {
      rethrow;
    } catch (_) {
      throw const ExcepcionAutenticacion(
        'No fue posible iniciar sesión. Verifica tu conexión e inténtalo de nuevo.',
      );
    }
  }

  Future<ResultadoRegistro> registrar({
    required String nombre,
    required String correo,
    required String clave,
  }) async {
    try {
      final respuesta = await _cliente.auth.signUp(
        email: correo.trim(),
        password: clave,
        data: {
          'nombre': nombre.trim(),
        },
      );

      return ResultadoRegistro(
        requiereConfirmacionCorreo: respuesta.session == null,
      );
    } on AuthException catch (error) {
      throw ExcepcionAutenticacion(_traducirError(error.message));
    } on ExcepcionAutenticacion {
      rethrow;
    } catch (_) {
      throw const ExcepcionAutenticacion(
        'No fue posible crear la cuenta. Verifica tu conexión e inténtalo de nuevo.',
      );
    }
  }

  Future<void> cerrarSesion() async {
    if (!ConfiguracionSupabase.inicializado) {
      return;
    }

    try {
      await _cliente.auth.signOut();
    } on AuthException catch (error) {
      throw ExcepcionAutenticacion(_traducirError(error.message));
    } catch (_) {
      throw const ExcepcionAutenticacion(
        'No fue posible cerrar la sesión. Inténtalo nuevamente.',
      );
    }
  }

  String _traducirError(String mensajeOriginal) {
    final mensaje = mensajeOriginal.toLowerCase();

    if (mensaje.contains('invalid login credentials')) {
      return 'El correo o la contraseña son incorrectos.';
    }

    if (mensaje.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
    }

    if (mensaje.contains('user already registered')) {
      return 'Ya existe una cuenta registrada con ese correo electrónico.';
    }

    if (mensaje.contains('password should be at least') ||
        mensaje.contains('weak password')) {
      return 'La contraseña no cumple los requisitos de seguridad.';
    }

    if (mensaje.contains('unable to validate email') ||
        mensaje.contains('invalid email')) {
      return 'El correo electrónico ingresado no es válido.';
    }

    if (mensaje.contains('rate limit') || mensaje.contains('too many')) {
      return 'Se realizaron demasiados intentos. Espera un momento y vuelve a intentarlo.';
    }

    return 'No fue posible completar la autenticación. Inténtalo nuevamente.';
  }
}
