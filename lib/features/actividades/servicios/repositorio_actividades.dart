import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/config/configuracion_supabase.dart';
import '../modelos/actividad_viaje.dart';
import '../validacion/validadores_actividad.dart';

class ExcepcionActividades implements Exception {
  const ExcepcionActividades(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato de persistencia para las actividades de un viaje.
abstract interface class FuenteActividades {
  Future<List<ActividadViaje>> listarPorViaje(String viajeId);

  Future<ActividadViaje?> obtenerPorId(String id);

  Future<ActividadViaje> crear({
    required String viajeId,
    required String titulo,
    required DateTime fecha,
    String? horaInicio,
    String? lugar,
    String? notas,
  });

  Future<ActividadViaje> actualizar(ActividadViaje actividad);

  Future<void> eliminar(String id);
}

/// Persistencia de actividades mediante Supabase.
class RepositorioActividades implements FuenteActividades {
  const RepositorioActividades._();

  static const RepositorioActividades instancia =
      RepositorioActividades._();

  SupabaseClient get _cliente {
    if (!ConfiguracionSupabase.inicializado) {
      throw const ExcepcionActividades(
        'Supabase todavía no está configurado.',
      );
    }

    return Supabase.instance.client;
  }

  @override
  Future<List<ActividadViaje>> listarPorViaje(String viajeId) async {
    try {
      final respuesta = await _cliente
          .from('actividades_viaje')
          .select()
          .eq('viaje_id', viajeId)
          .order('fecha', ascending: true)
          .order('hora_inicio', ascending: true, nullsFirst: false)
          .order('creado_en', ascending: true);

      return respuesta
          .map((fila) => ActividadViaje.fromMap(fila))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw ExcepcionActividades(_traducirError(error));
    } catch (_) {
      throw const ExcepcionActividades(
        'No fue posible cargar las actividades del viaje.',
      );
    }
  }

  @override
  Future<ActividadViaje?> obtenerPorId(String id) async {
    try {
      final respuesta = await _cliente
          .from('actividades_viaje')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (respuesta == null) {
        return null;
      }

      return ActividadViaje.fromMap(respuesta);
    } on PostgrestException catch (error) {
      throw ExcepcionActividades(_traducirError(error));
    } catch (_) {
      throw const ExcepcionActividades(
        'No fue posible cargar la actividad solicitada.',
      );
    }
  }

  @override
  Future<ActividadViaje> crear({
    required String viajeId,
    required String titulo,
    required DateTime fecha,
    String? horaInicio,
    String? lugar,
    String? notas,
  }) async {
    _validarDatos(
      titulo: titulo,
      fecha: fecha,
      horaInicio: horaInicio,
      lugar: lugar,
      notas: notas,
    );

    try {
      final respuesta = await _cliente
          .from('actividades_viaje')
          .insert({
            'viaje_id': viajeId,
            'titulo': titulo.trim(),
            'fecha': ActividadViaje.fechaSql(fecha),
            'hora_inicio': _normalizarOpcional(horaInicio),
            'lugar': _normalizarOpcional(lugar),
            'notas': _normalizarOpcional(notas),
          })
          .select()
          .single();

      return ActividadViaje.fromMap(respuesta);
    } on PostgrestException catch (error) {
      throw ExcepcionActividades(_traducirError(error));
    } catch (_) {
      throw const ExcepcionActividades(
        'No fue posible crear la actividad.',
      );
    }
  }

  @override
  Future<ActividadViaje> actualizar(ActividadViaje actividad) async {
    _validarDatos(
      titulo: actividad.titulo,
      fecha: actividad.fecha,
      horaInicio: actividad.horaInicio,
      lugar: actividad.lugar,
      notas: actividad.notas,
    );

    try {
      final respuesta = await _cliente
          .from('actividades_viaje')
          .update(actividad.toUpdateMap())
          .eq('id', actividad.id)
          .select()
          .single();

      return ActividadViaje.fromMap(respuesta);
    } on PostgrestException catch (error) {
      throw ExcepcionActividades(_traducirError(error));
    } catch (_) {
      throw const ExcepcionActividades(
        'No fue posible actualizar la actividad.',
      );
    }
  }

  @override
  Future<void> eliminar(String id) async {
    try {
      await _cliente.from('actividades_viaje').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw ExcepcionActividades(_traducirError(error));
    } catch (_) {
      throw const ExcepcionActividades(
        'No fue posible eliminar la actividad.',
      );
    }
  }

  void _validarDatos({
    required String titulo,
    required DateTime fecha,
    String? horaInicio,
    String? lugar,
    String? notas,
  }) {
    final errores = <String?>[
      ValidadoresActividad.titulo(titulo),
      ValidadoresActividad.hora(horaInicio),
      ValidadoresActividad.lugar(lugar),
      ValidadoresActividad.notas(notas),
    ];

    if (fecha.year < 2000 || fecha.year > 2100) {
      throw const ExcepcionActividades(
        'La fecha de la actividad no es válida.',
      );
    }

    for (final error in errores) {
      if (error != null) {
        throw ExcepcionActividades(error);
      }
    }
  }

  String? _normalizarOpcional(String? valor) {
    final texto = valor?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }

  String _traducirError(PostgrestException error) {
    final mensaje = error.message.toLowerCase();

    if (mensaje.contains('actividad_fecha_fuera_viaje')) {
      return 'La fecha de la actividad debe estar dentro de las fechas '
          'del viaje.';
    }

    if (mensaje.contains('row-level security') ||
        mensaje.contains('violates row-level security')) {
      return 'No tienes permiso para modificar actividades de este viaje.';
    }

    if (mensaje.contains('foreign key') ||
        mensaje.contains('viaje_id') ||
        mensaje.contains('viaje_no_disponible')) {
      return 'El viaje asociado no existe o ya no está disponible.';
    }

    if (mensaje.contains('titulo')) {
      return 'Revisa el título de la actividad.';
    }

    return 'No fue posible completar la operación con la actividad.';
  }
}
