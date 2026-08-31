import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';

/// Tarjeta genérica para presentar información destacada de manera uniforme.
class TarjetaInformativa extends StatelessWidget {
  const TarjetaInformativa({
    super.key,
    required this.child,
    this.icono,
    this.titulo,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final IconData? icono;
  final String? titulo;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final contenido = Padding(
      padding: padding ?? const EdgeInsets.all(DimensionesApp.espacio16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icono != null || titulo != null) ...[
            Row(
              children: [
                if (icono != null) ...[
                  Icon(icono, color: colorScheme.secondary),
                  const SizedBox(width: DimensionesApp.espacio8),
                ],
                if (titulo != null)
                  Expanded(
                    child: Text(
                      titulo!,
                      style: textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DimensionesApp.espacio12),
          ],
          child,
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? contenido
          : InkWell(
              onTap: onTap,
              child: contenido,
            ),
    );
  }
}
