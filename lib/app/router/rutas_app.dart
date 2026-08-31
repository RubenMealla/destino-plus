/// Rutas centralizadas de Destino+.
///
/// Los nombres y paths viven en un único lugar para evitar cadenas repetidas
/// y facilitar cambios futuros en la navegación.
abstract final class RutasApp {
  static const String raiz = '/';
  static const String presentacion = '/presentacion';

  static const String inicioSesion = '/inicio-sesion';
  static const String registro = '/registro';

  static const String inicio = '/inicio';
  static const String viajes = '/viajes';
  static const String nuevoViaje = '/viajes/nuevo';
  static const String detalleViaje = '/viajes/:id';
  static const String editarViaje = '/viajes/:id/editar';

  static const String explorar = '/explorar';
  static const String perfil = '/perfil';

  const RutasApp._();

  static String detalleDeViaje(String id) => '/viajes/$id';

  static String edicionDeViaje(String id) => '/viajes/$id/editar';
}
