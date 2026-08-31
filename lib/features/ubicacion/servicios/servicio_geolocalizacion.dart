import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../modelos/ubicacion_actual.dart';

/// Lectura mínima devuelta por la capa que conversa con la plataforma.
class LecturaGeolocalizacion {
  const LecturaGeolocalizacion({
    required this.latitud,
    required this.longitud,
    required this.precisionMetros,
    required this.fechaHora,
  });

  final double latitud;
  final double longitud;
  final double precisionMetros;
  final DateTime fechaHora;
}

/// Contrato consumido por otras funciones de Destino+ que necesitan la
/// posición actual, sin conocer el plugin utilizado para obtenerla.
abstract interface class FuenteUbicacionActual {
  Future<UbicacionActual> obtenerUbicacionActual();
}

/// Contrato para desacoplar la lógica de Destino+ del plugin `geolocator`.
abstract interface class FuenteGeolocalizacion {
  Future<bool> servicioHabilitado();

  Future<PermisoUbicacion> verificarPermiso();

  Future<PermisoUbicacion> solicitarPermiso();

  Future<LecturaGeolocalizacion> obtenerPosicionActual();
}

/// Implementación real utilizando el plugin `geolocator`.
class FuenteGeolocalizacionGeolocator implements FuenteGeolocalizacion {
  const FuenteGeolocalizacionGeolocator();

  @override
  Future<bool> servicioHabilitado() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<PermisoUbicacion> verificarPermiso() async {
    final permiso = await Geolocator.checkPermission();
    return _convertirPermiso(permiso);
  }

  @override
  Future<PermisoUbicacion> solicitarPermiso() async {
    final permiso = await Geolocator.requestPermission();
    return _convertirPermiso(permiso);
  }

  @override
  Future<LecturaGeolocalizacion> obtenerPosicionActual() async {
    final posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return LecturaGeolocalizacion(
      latitud: posicion.latitude,
      longitud: posicion.longitude,
      precisionMetros: posicion.accuracy,
      fechaHora: posicion.timestamp,
    );
  }

  static PermisoUbicacion _convertirPermiso(
    LocationPermission permiso,
  ) {
    return switch (permiso) {
      LocationPermission.denied => PermisoUbicacion.denegado,
      LocationPermission.deniedForever =>
        PermisoUbicacion.denegadoPermanentemente,
      LocationPermission.whileInUse => PermisoUbicacion.mientrasUso,
      LocationPermission.always => PermisoUbicacion.siempre,
      _ => PermisoUbicacion.denegado,
    };
  }
}

/// Orquesta la comprobación del servicio, permisos y lectura de coordenadas.
class ServicioGeolocalizacion implements FuenteUbicacionActual {
  ServicioGeolocalizacion({
    FuenteGeolocalizacion? fuente,
  }) : _fuente = fuente ?? const FuenteGeolocalizacionGeolocator();

  final FuenteGeolocalizacion _fuente;

  @override
  Future<UbicacionActual> obtenerUbicacionActual() async {
    bool servicioActivo;

    try {
      servicioActivo = await _fuente.servicioHabilitado();
    } catch (_) {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.noDisponible,
        mensaje:
            'No fue posible comprobar el servicio de ubicación del dispositivo.',
      );
    }

    if (!servicioActivo) {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.servicioDeshabilitado,
        mensaje:
            'La ubicación del dispositivo está desactivada. Actívala para continuar.',
      );
    }

    PermisoUbicacion permiso;

    try {
      permiso = await _fuente.verificarPermiso();

      if (permiso == PermisoUbicacion.denegado) {
        permiso = await _fuente.solicitarPermiso();
      }
    } catch (_) {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.noDisponible,
        mensaje:
            'No fue posible comprobar el permiso de ubicación.',
      );
    }

    if (permiso == PermisoUbicacion.denegadoPermanentemente) {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.permisoDenegadoPermanentemente,
        mensaje:
            'El permiso de ubicación está bloqueado. Debes habilitarlo desde la configuración de la aplicación.',
      );
    }

    if (permiso == PermisoUbicacion.denegado) {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.permisoDenegado,
        mensaje:
            'Necesitamos permiso de ubicación para usar tu posición actual.',
      );
    }

    try {
      final lectura = await _fuente.obtenerPosicionActual();

      return UbicacionActual(
        latitud: lectura.latitud,
        longitud: lectura.longitud,
        precisionMetros: lectura.precisionMetros,
        fechaHora: lectura.fechaHora,
      );
    } on TimeoutException {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.tiempoAgotado,
        mensaje:
            'La ubicación tardó demasiado en responder. Inténtalo nuevamente.',
      );
    } catch (_) {
      throw const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.noDisponible,
        mensaje:
            'No fue posible obtener la ubicación actual del dispositivo.',
      );
    }
  }
}
