import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/marca_destino_plus.dart';
import '../../shared/widgets/tarjeta_informativa.dart';

/// Estructura inicial del panel principal.
///
/// Los datos reales se incorporarán cuando existan autenticación, viajes y
/// servicios externos.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ContenidoAdaptable(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MarcaDestinoPlus(mostrarLema: false),
                const SizedBox(height: DimensionesApp.espacio24),
                Text(
                  'Planifica tu próximo viaje',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: DimensionesApp.espacio8),
                Text(
                  'Aquí encontrarás un resumen de tus viajes y la información '
                  'más útil para organizarlos.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: DimensionesApp.espacio32),
                const EncabezadoSeccion(
                  titulo: 'Próximos viajes',
                  subtitulo:
                      'Los viajes creados aparecerán aquí cuando se implemente su gestión.',
                ),
                const SizedBox(height: DimensionesApp.espacio16),
                const TarjetaInformativa(
                  icono: Icons.luggage_outlined,
                  titulo: 'Sin viajes registrados',
                  child: Text(
                    'La creación y administración de viajes se incorporará '
                    'en la etapa del CRUD.',
                  ),
                ),
                const SizedBox(height: DimensionesApp.espacio24),
                const EncabezadoSeccion(
                  titulo: 'Información del destino',
                  subtitulo:
                      'El clima y otros datos útiles se integrarán en etapas posteriores.',
                ),
                const SizedBox(height: DimensionesApp.espacio16),
                const TarjetaInformativa(
                  icono: Icons.cloud_outlined,
                  titulo: 'Clima',
                  child: Text(
                    'La consulta meteorológica se habilitará cuando se integre '
                    'la API pública del proyecto.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
