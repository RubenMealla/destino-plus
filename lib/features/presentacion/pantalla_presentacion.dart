import 'package:flutter/material.dart';

import '../../app/theme/colores_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/marca_destino_plus.dart';
import '../../shared/widgets/tarjeta_informativa.dart';

/// Pantalla temporal para validar la identidad visual base de Destino+.
///
/// No representa todavía la pantalla de inicio definitiva. Será reemplazada
/// cuando se implemente la navegación y el flujo funcional de la aplicación.
class PantallaPresentacion extends StatelessWidget {
  const PantallaPresentacion({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContenidoAdaptable(
            padding: const EdgeInsets.fromLTRB(
              DimensionesApp.espacio20,
              DimensionesApp.espacio24,
              DimensionesApp.espacio20,
              DimensionesApp.espacio32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MarcaDestinoPlus(),
                const SizedBox(height: DimensionesApp.espacio32),
                _BloquePrincipal(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: DimensionesApp.espacio32),
                const EncabezadoSeccion(
                  titulo: 'Una base pensada para viajar',
                  subtitulo:
                      'Destino+ reunirá en un solo lugar la información esencial de cada viaje.',
                ),
                const SizedBox(height: DimensionesApp.espacio16),
                const _ListaBeneficios(),
                const SizedBox(height: DimensionesApp.espacio24),
                TarjetaInformativa(
                  icono: Icons.info_outline_rounded,
                  titulo: 'Proyecto en desarrollo',
                  child: Text(
                    'Esta vista valida únicamente la identidad visual inicial. '
                    'Las funciones de autenticación, viajes, clima y ubicación '
                    'se incorporarán en las siguientes etapas.',
                    style: textTheme.bodyMedium,
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

class _BloquePrincipal extends StatelessWidget {
  const _BloquePrincipal({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DimensionesApp.espacio24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColoresApp.azulDestino,
            ColoresApp.turquesaRuta,
          ],
        ),
        borderRadius: BorderRadius.circular(DimensionesApp.radioGrande),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DimensionesApp.espacio12,
              vertical: DimensionesApp.espacio8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(
                DimensionesApp.radioPequeno,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.luggage_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: DimensionesApp.espacio8),
                Text(
                  'Planificación de viajes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DimensionesApp.espacio20),
          Text(
            'Tus viajes, más claros desde el primer paso.',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DimensionesApp.espacio12),
          Text(
            'Organiza destinos, fechas y actividades y consulta información '
            'útil para preparar cada experiencia.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          const SizedBox(height: DimensionesApp.espacio24),
          BotonAccion(
            texto: 'Comenzar próximamente',
            icono: Icons.arrow_forward_rounded,
            onPressed: null,
          ),
          const SizedBox(height: DimensionesApp.espacio8),
          Text(
            'El flujo funcional se habilitará en las siguientes etapas.',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaBeneficios extends StatelessWidget {
  const _ListaBeneficios();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Beneficio(
          icono: Icons.route_outlined,
          titulo: 'Organización clara',
          descripcion:
              'Destinos, fechas y actividades dentro de una misma experiencia.',
        ),
        SizedBox(height: DimensionesApp.espacio12),
        _Beneficio(
          icono: Icons.cloud_outlined,
          titulo: 'Información útil',
          descripcion:
              'El clima del destino formará parte de la planificación.',
        ),
        SizedBox(height: DimensionesApp.espacio12),
        _Beneficio(
          icono: Icons.my_location_outlined,
          titulo: 'Experiencia móvil',
          descripcion:
              'La aplicación está pensada desde el inicio para Android y uso táctil.',
        ),
      ],
    );
  }
}

class _Beneficio extends StatelessWidget {
  const _Beneficio({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TarjetaInformativa(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(
                DimensionesApp.radioPequeno,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icono,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: DimensionesApp.espacio12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: textTheme.titleMedium),
                const SizedBox(height: DimensionesApp.espacio4),
                Text(descripcion, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
