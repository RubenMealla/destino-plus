/// Rutas centralizadas de Destino+.
abstract final class RutasApp {
  static const String raiz = '/';
  static const String presentacion = '/presentacion';
  static const String inicioSesion = '/inicio-sesion';
  static const String registro = '/registro';

  static const String inicio = '/inicio';
  static const String viajes = '/viajes';
  static const String nuevoViaje = '/viajes/nuevo';
  static const String explorar = '/explorar';
  static const String perfil = '/perfil';

  static String detalleDeViaje(String id) => '$viajes/$id';

  static String edicionDeViaje(String id) =>
      '${detalleDeViaje(id)}/editar';

  static String nuevaActividadDeViaje(String viajeId) =>
      '${detalleDeViaje(viajeId)}/actividades/nueva';

  static String edicionActividadDeViaje(
    String viajeId,
    String actividadId,
  ) =>
      '${detalleDeViaje(viajeId)}/actividades/$actividadId/editar';

  const RutasApp._();
}
