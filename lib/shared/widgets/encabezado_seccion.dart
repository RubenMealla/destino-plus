import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';

/// Encabezado reutilizable para separar visualmente secciones de contenido.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.accion,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: textTheme.titleLarge),
              if (subtitulo != null) ...[
                const SizedBox(height: DimensionesApp.espacio4),
                Text(subtitulo!, style: textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (accion != null) ...[
          const SizedBox(width: DimensionesApp.espacio12),
          accion!,
        ],
      ],
    );
  }
}
