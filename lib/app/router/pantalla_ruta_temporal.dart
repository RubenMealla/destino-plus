import 'package:flutter/material.dart';

import '../../shared/widgets/contenido_adaptable.dart';

/// Vista técnica provisional utilizada mientras se incorporan las pantallas
/// reales de cada ruta.
///
/// Se eliminará progresivamente durante esta misma rama de navegación.
class PantallaRutaTemporal extends StatelessWidget {
  const PantallaRutaTemporal({
    super.key,
    required this.titulo,
    required this.descripcion,
  });

  final String titulo;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ContenidoAdaptable(
        child: Center(
          child: Text(
            descripcion,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
