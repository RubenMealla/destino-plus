import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';

/// Estado vacío reutilizable para listas o secciones sin contenido.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DimensionesApp.espacio32,
        horizontal: DimensionesApp.espacio20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icono,
              size: 32,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: DimensionesApp.espacio16),
          Text(
            titulo,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DimensionesApp.espacio8),
          Text(
            mensaje,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (accion != null) ...[
            const SizedBox(height: DimensionesApp.espacio20),
            accion!,
          ],
        ],
      ),
    );
  }
}
