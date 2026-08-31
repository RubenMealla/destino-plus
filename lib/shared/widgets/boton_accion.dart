import 'package:flutter/material.dart';

/// Botón de acción principal reutilizable.
///
/// Permite mostrar texto e icono manteniendo el estilo definido por el tema
/// global de Destino+.
class BotonAccion extends StatelessWidget {
  const BotonAccion({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.expandido = true,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final boton = icono == null
        ? FilledButton(
            onPressed: onPressed,
            child: Text(texto),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icono),
            label: Text(texto),
          );

    if (!expandido) {
      return boton;
    }

    return SizedBox(
      width: double.infinity,
      child: boton,
    );
  }
}
