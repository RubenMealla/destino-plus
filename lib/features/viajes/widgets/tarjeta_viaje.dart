import 'package:flutter/material.dart';

import '../../../app/theme/dimensiones_app.dart';
import '../modelos/viaje.dart';

class TarjetaViaje extends StatelessWidget {
  const TarjetaViaje({
    super.key,
    required this.viaje,
    required this.onTap,
  });

  final Viaje viaje;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DimensionesApp.espacio16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(
                    DimensionesApp.radioPequeno,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: DimensionesApp.espacio12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(viaje.titulo, style: textTheme.titleMedium),
                    const SizedBox(height: DimensionesApp.espacio4),
                    Text(
                      viaje.destino,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: DimensionesApp.espacio8),
                    Text(
                      '${_formatearFecha(viaje.fechaInicio)} - '
                      '${_formatearFecha(viaje.fechaFin)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DimensionesApp.espacio8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}
