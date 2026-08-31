import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/tarjeta_informativa.dart';

/// Estructura inicial del perfil y los ajustes.
///
/// La información del usuario y sus preferencias se incorporarán cuando se
/// implementen autenticación y persistencia local.
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: ContenidoAdaptable(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 38,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: DimensionesApp.espacio12),
                    Text(
                      'Usuario de Destino+',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: DimensionesApp.espacio4),
                    Text(
                      'Perfil pendiente de autenticación',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio32),
              const EncabezadoSeccion(
                titulo: 'Ajustes',
                subtitulo:
                    'Las preferencias se habilitarán cuando exista persistencia local.',
              ),
              const SizedBox(height: DimensionesApp.espacio16),
              const TarjetaInformativa(
                icono: Icons.palette_outlined,
                titulo: 'Apariencia',
                child: Text(
                  'El tema de la aplicación utiliza actualmente la configuración '
                  'del sistema.',
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio12),
              const TarjetaInformativa(
                icono: Icons.settings_outlined,
                titulo: 'Preferencias',
                child: Text(
                  'Las preferencias del usuario se incorporarán en una etapa posterior.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
