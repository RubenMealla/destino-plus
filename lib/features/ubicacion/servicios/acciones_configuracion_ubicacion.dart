import 'package:geolocator/geolocator.dart';

/// Acciones externas que ayudan al usuario a corregir problemas de ubicación.
abstract interface class AccionesConfiguracionUbicacion {
  Future<bool> abrirConfiguracionAplicacion();

  Future<bool> abrirConfiguracionUbicacion();
}

/// Implementación real mediante las acciones proporcionadas por geolocator.
class AccionesConfiguracionUbicacionGeolocator
    implements AccionesConfiguracionUbicacion {
  const AccionesConfiguracionUbicacionGeolocator();

  @override
  Future<bool> abrirConfiguracionAplicacion() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> abrirConfiguracionUbicacion() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}
