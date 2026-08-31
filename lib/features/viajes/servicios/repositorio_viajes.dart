import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/config/configuracion_supabase.dart';
import '../modelos/viaje.dart';

class ExcepcionViajes implements Exception {
  const ExcepcionViajes(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato utilizado por las pantallas de viajes.
///
/// Permite desacoplar la interfaz de Supabase y facilita las pruebas.
abstract interface class FuenteViajes {
  Future<List<Viaje>> listar();

  Future<Viaje?> obtenerPorId(String id);

  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  });

  Future<Viaje> actualizar(Viaje viaje);

  Future<void> eliminar(String id);
}

/// Acceso centralizado a la persistencia de viajes en Supabase.
class RepositorioViajes implements FuenteViajes {
  const RepositorioViajes._();

  static const RepositorioViajes instancia = RepositorioViajes._();

  SupabaseClient get _cliente {
    if (!ConfiguracionSupabase.inicializado) {
      throw const ExcepcionViajes('Supabase todavía no está configurado.');
    }
    return Supabase.instance.client;
  }

  User get _usuarioActual {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) {
      throw const ExcepcionViajes(
        'Debes iniciar sesión para administrar tus viajes.',
      );
    }
    return usuario;
  }

  @override
  Future<List<Viaje>> listar() async {
    try {
      final respuesta = await _cliente
          .from('viajes')
          .select()
          .order('fecha_inicio', ascending: true)
          .order('creado_en', ascending: false);

      return respuesta
          .map((fila) => Viaje.fromMap(fila))
          .toList(growable: false);
    } on ExcepcionViajes {
      rethrow;
    } on PostgrestException catch (error) {
      throw ExcepcionViajes(_traducirError(error));
    } catch (_) {
      throw const ExcepcionViajes(
        'No fue posible cargar los viajes. Verifica tu conexión.',
      );
    }
  }

  @override
  Future<Viaje?> obtenerPorId(String id) async {
    try {
      final respuesta = await _cliente
          .from('viajes')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (respuesta == null) return null;
      return Viaje.fromMap(respuesta);
    } on ExcepcionViajes {
      rethrow;
    } on PostgrestException catch (error) {
      throw ExcepcionViajes(_traducirError(error));
    } catch (_) {
      throw const ExcepcionViajes(
        'No fue posible cargar el viaje solicitado.',
      );
    }
  }

  @override
  Future<Viaje> crear({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) async {
    _validarDatos(
      titulo: titulo,
      destino: destino,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      descripcion: descripcion,
    );

    try {
      final respuesta = await _cliente
          .from('viajes')
          .insert({
            'usuario_id': _usuarioActual.id,
            'titulo': titulo.trim(),
            'destino': destino.trim(),
            'fecha_inicio': Viaje.fechaSql(fechaInicio),
            'fecha_fin': Viaje.fechaSql(fechaFin),
            'descripcion': _normalizarDescripcion(descripcion),
          })
          .select()
          .single();

      return Viaje.fromMap(respuesta);
    } on ExcepcionViajes {
      rethrow;
    } on PostgrestException catch (error) {
      throw ExcepcionViajes(_traducirError(error));
    } catch (_) {
      throw const ExcepcionViajes(
        'No fue posible crear el viaje. Verifica tu conexión.',
      );
    }
  }

  @override
  Future<Viaje> actualizar(Viaje viaje) async {
    _validarDatos(
      titulo: viaje.titulo,
      destino: viaje.destino,
      fechaInicio: viaje.fechaInicio,
      fechaFin: viaje.fechaFin,
      descripcion: viaje.descripcion,
    );

    try {
      final respuesta = await _cliente
          .from('viajes')
          .update(viaje.toUpdateMap())
          .eq('id', viaje.id)
          .select()
          .single();

      return Viaje.fromMap(respuesta);
    } on ExcepcionViajes {
      rethrow;
    } on PostgrestException catch (error) {
      throw ExcepcionViajes(_traducirError(error));
    } catch (_) {
      throw const ExcepcionViajes('No fue posible actualizar el viaje.');
    }
  }

  @override
  Future<void> eliminar(String id) async {
    try {
      await _cliente.from('viajes').delete().eq('id', id);
    } on ExcepcionViajes {
      rethrow;
    } on PostgrestException catch (error) {
      throw ExcepcionViajes(_traducirError(error));
    } catch (_) {
      throw const ExcepcionViajes('No fue posible eliminar el viaje.');
    }
  }

  void _validarDatos({
    required String titulo,
    required String destino,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
  }) {
    if (titulo.trim().length < 2) {
      throw const ExcepcionViajes(
        'El título debe tener al menos 2 caracteres.',
      );
    }

    if (destino.trim().length < 2) {
      throw const ExcepcionViajes(
        'El destino debe tener al menos 2 caracteres.',
      );
    }

    final inicio = DateTime(
      fechaInicio.year,
      fechaInicio.month,
      fechaInicio.day,
    );
    final fin = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);

    if (fin.isBefore(inicio)) {
      throw const ExcepcionViajes(
        'La fecha de fin no puede ser anterior a la fecha de inicio.',
      );
    }

    if ((descripcion?.trim().length ?? 0) > 1000) {
      throw const ExcepcionViajes(
        'La descripción no puede superar los 1000 caracteres.',
      );
    }
  }

  String? _normalizarDescripcion(String? valor) {
    final descripcion = valor?.trim();
    if (descripcion == null || descripcion.isEmpty) return null;
    return descripcion;
  }

  String _traducirError(PostgrestException error) {
    final mensaje = error.message.toLowerCase();

    if (mensaje.contains('row-level security') ||
        mensaje.contains('violates row-level security')) {
      return 'No tienes permiso para realizar esta operación.';
    }

    if (mensaje.contains('fecha_fin') ||
        mensaje.contains('viajes_fechas_validas')) {
      return 'La fecha de fin no puede ser anterior a la fecha de inicio.';
    }

    if (mensaje.contains('titulo') || mensaje.contains('destino')) {
      return 'Revisa los datos obligatorios del viaje.';
    }

    return 'No fue posible completar la operación con el viaje.';
  }
}
