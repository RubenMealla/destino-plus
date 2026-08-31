import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import '../../shared/widgets/tarjeta_informativa.dart';
import 'modelos/viaje.dart';
import 'servicios/repositorio_viajes.dart';

/// Muestra la información completa de un viaje.
class PantallaDetalleViaje extends StatefulWidget {
  const PantallaDetalleViaje({
    super.key,
    required this.viajeId,
    this.repositorio,
  });

  final String viajeId;
  final FuenteViajes? repositorio;

  @override
  State<PantallaDetalleViaje> createState() => _PantallaDetalleViajeState();
}

class _PantallaDetalleViajeState extends State<PantallaDetalleViaje> {
  late Future<Viaje?> _carga;

  FuenteViajes get _repositorio =>
      widget.repositorio ?? RepositorioViajes.instancia;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _carga = _repositorio.obtenerPorId(widget.viajeId);
  }

  Future<void> _editar() async {
    final actualizado = await context.push<bool>(
      RutasApp.edicionDeViaje(widget.viajeId),
    );

    if (actualizado == true && mounted) {
      setState(_cargar);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje actualizado correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del viaje'),
        actions: [
          IconButton(
            tooltip: 'Editar viaje',
            onPressed: _editar,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: FutureBuilder<Viaje?>(
        future: _carga,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final mensaje = snapshot.error is ExcepcionViajes
                ? (snapshot.error! as ExcepcionViajes).mensaje
                : 'No fue posible cargar el viaje.';

            return Center(
              child: EstadoVacio(
                icono: Icons.cloud_off_outlined,
                titulo: 'No pudimos cargar el viaje',
                mensaje: mensaje,
                accion: BotonAccion(
                  texto: 'Reintentar',
                  icono: Icons.refresh_rounded,
                  onPressed: () => setState(_cargar),
                ),
              ),
            );
          }

          final viaje = snapshot.data;

          if (viaje == null) {
            return const Center(
              child: EstadoVacio(
                icono: Icons.search_off_rounded,
                titulo: 'Viaje no encontrado',
                mensaje:
                    'El viaje solicitado no existe o ya no está disponible.',
              ),
            );
          }

          return SingleChildScrollView(
            child: ContenidoAdaptable(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viaje.titulo,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: DimensionesApp.espacio8),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 20),
                      const SizedBox(width: DimensionesApp.espacio8),
                      Expanded(
                        child: Text(
                          viaje.destino,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DimensionesApp.espacio24),
                  TarjetaInformativa(
                    icono: Icons.calendar_month_outlined,
                    titulo: 'Fechas del viaje',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DatoDetalle(
                          etiqueta: 'Inicio',
                          valor: _formatearFecha(viaje.fechaInicio),
                        ),
                        const SizedBox(height: DimensionesApp.espacio8),
                        _DatoDetalle(
                          etiqueta: 'Fin',
                          valor: _formatearFecha(viaje.fechaFin),
                        ),
                        const SizedBox(height: DimensionesApp.espacio8),
                        _DatoDetalle(
                          etiqueta: 'Duración',
                          valor: _duracion(viaje),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionesApp.espacio12),
                  TarjetaInformativa(
                    icono: Icons.notes_rounded,
                    titulo: 'Descripción',
                    child: Text(
                      viaje.descripcion?.trim().isNotEmpty == true
                          ? viaje.descripcion!.trim()
                          : 'Sin descripción.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: DimensionesApp.espacio24),
                  BotonAccion(
                    texto: 'Editar viaje',
                    icono: Icons.edit_outlined,
                    onPressed: _editar,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  static String _duracion(Viaje viaje) {
    final inicio = DateTime(
      viaje.fechaInicio.year,
      viaje.fechaInicio.month,
      viaje.fechaInicio.day,
    );
    final fin = DateTime(
      viaje.fechaFin.year,
      viaje.fechaFin.month,
      viaje.fechaFin.day,
    );

    final dias = fin.difference(inicio).inDays + 1;
    return dias == 1 ? '1 día' : '$dias días';
  }
}

class _DatoDetalle extends StatelessWidget {
  const _DatoDetalle({
    required this.etiqueta,
    required this.valor,
  });

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            etiqueta,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
