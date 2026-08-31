import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';

/// Estructura inicial de la sección de viajes.
///
/// La lista real y sus operaciones se incorporarán durante la implementación
/// del CRUD.
class PantallaViajes extends StatelessWidget {
  const PantallaViajes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
      ),
      body: ContenidoAdaptable(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organiza tus viajes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DimensionesApp.espacio8),
            Text(
              'Crea y consulta tus destinos, fechas y actividades desde un '
              'solo lugar.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DimensionesApp.espacio24),
            EstadoVacio(
              icono: Icons.luggage_outlined,
              titulo: 'Todavía no tienes viajes',
              mensaje:
                  'Cuando se implemente la gestión de viajes, aquí podrás '
                  'crear y consultar tus planes.',
              accion: BotonAccion(
                texto: 'Vista previa de nuevo viaje',
                icono: Icons.add_rounded,
                onPressed: () => context.push(RutasApp.nuevoViaje),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
