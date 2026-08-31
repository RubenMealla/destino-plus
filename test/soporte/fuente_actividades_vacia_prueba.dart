import 'package:destino_plus/features/actividades/modelos/actividad_viaje.dart';
import 'package:destino_plus/features/actividades/servicios/repositorio_actividades.dart';

/// Fuente aislada para pruebas de pantallas de viaje que no evalúan
/// persistencia de actividades.
class FuenteActividadesVaciaPrueba implements FuenteActividades {
  const FuenteActividadesVaciaPrueba();

  @override
  Future<List<ActividadViaje>> listarPorViaje(String viajeId) async =>
      const <ActividadViaje>[];

  @override
  Future<ActividadViaje?> obtenerPorId(String id) async => null;

  @override
  Future<ActividadViaje> crear({
    required String viajeId,
    required String titulo,
    required DateTime fecha,
    String? horaInicio,
    String? lugar,
    String? notas,
  }) async {
    throw UnsupportedError(
      'Esta fuente de prueba no crea actividades.',
    );
  }

  @override
  Future<ActividadViaje> actualizar(ActividadViaje actividad) async =>
      actividad;

  @override
  Future<void> eliminar(String id) async {}
}
