import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/tarjeta_informativa.dart';

/// Estructura inicial para descubrir información útil de los destinos.
class PantallaExplorar extends StatelessWidget {
  const PantallaExplorar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
      ),
      body: SingleChildScrollView(
        child: ContenidoAdaptable(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explora antes de viajar',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: DimensionesApp.espacio8),
              Text(
                'Esta sección reunirá información externa relacionada con '
                'los destinos de tus viajes.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: DimensionesApp.espacio32),
              const EncabezadoSeccion(
                titulo: 'Servicios previstos',
                subtitulo:
                    'Se habilitarán progresivamente durante el desarrollo.',
              ),
              const SizedBox(height: DimensionesApp.espacio16),
              const TarjetaInformativa(
                icono: Icons.cloud_outlined,
                titulo: 'Clima del destino',
                child: Text(
                  'Consulta meteorológica mediante una API pública.',
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio12),
              const TarjetaInformativa(
                icono: Icons.my_location_outlined,
                titulo: 'Ubicación',
                child: Text(
                  'Funciones relacionadas con la ubicación del dispositivo.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
