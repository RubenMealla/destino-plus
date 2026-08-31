import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';

/// Contenedor base que limita el ancho del contenido y aplica márgenes
/// consistentes, priorizando la experiencia en pantallas móviles.
class ContenidoAdaptable extends StatelessWidget {
  const ContenidoAdaptable({
    super.key,
    required this.child,
    this.padding,
    this.alineacion = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alineacion;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alineacion,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DimensionesApp.anchoContenidoMovil,
        ),
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: DimensionesApp.espacio20,
                vertical: DimensionesApp.espacio16,
              ),
          child: child,
        ),
      ),
    );
  }
}
