import '../../ubicacion/modelos/ubicacion_actual.dart';
import '../../ubicacion/servicios/servicio_geolocalizacion.dart';
import 'servicio_clima_destino.dart';

/// Clima obtenido a partir de una lectura real de la ubicación del dispositivo.
class ClimaUbicacionActual {
  const ClimaUbicacionActual({
    required this.ubicacion,
    required this.clima,
  });

  final UbicacionActual ubicacion;
  final ClimaDestino clima;
}

abstract interface class FuenteClimaUbicacionActual {
  Future<ClimaUbicacionActual> consultar();
}

/// Une geolocalización y Open-Meteo sin mezclar esa lógica con la pantalla.
class ServicioClimaUbicacionActual implements FuenteClimaUbicacionActual {
  ServicioClimaUbicacionActual({
    FuenteUbicacionActual? fuenteUbicacion,
    FuenteClimaCoordenadas? fuenteClima,
  })  : _fuenteUbicacion =
            fuenteUbicacion ?? ServicioGeolocalizacion(),
        _fuenteClima = fuenteClima ?? ServicioClimaDestino();

  final FuenteUbicacionActual _fuenteUbicacion;
  final FuenteClimaCoordenadas _fuenteClima;

  @override
  Future<ClimaUbicacionActual> consultar() async {
    final ubicacion = await _fuenteUbicacion.obtenerUbicacionActual();

    final clima = await _fuenteClima.consultarCoordenadas(
      latitud: ubicacion.latitud,
      longitud: ubicacion.longitud,
    );

    return ClimaUbicacionActual(
      ubicacion: ubicacion,
      clima: clima,
    );
  }
}
