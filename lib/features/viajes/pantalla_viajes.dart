import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import 'modelos/viaje.dart';
import 'servicios/repositorio_viajes.dart';
import 'widgets/tarjeta_viaje.dart';

/// Lista los viajes del usuario autenticado.
class PantallaViajes extends StatefulWidget {
  const PantallaViajes({
    super.key,
    this.repositorio,
  });

  final FuenteViajes? repositorio;

  @override
  State<PantallaViajes> createState() => _PantallaViajesState();
}

class _PantallaViajesState extends State<PantallaViajes> {
  late Future<List<Viaje>> _carga;

  FuenteViajes get _repositorio =>
      widget.repositorio ?? RepositorioViajes.instancia;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _carga = _repositorio.listar();
  }

  Future<void> _recargar() async {
    setState(_cargar);
    await _carga;
  }

  Future<void> _crearViaje() async {
    final creado = await context.push<bool>(RutasApp.nuevoViaje);

    if (creado == true && mounted) {
      await _recargar();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje creado correctamente.')),
      );
    }
  }

  Future<void> _abrirDetalle(Viaje viaje) async {
    final huboCambios = await context.push<bool>(
      RutasApp.detalleDeViaje(viaje.id),
    );

    if (huboCambios == true && mounted) {
      await _recargar();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista de viajes actualizada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearViaje,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo viaje'),
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
            Expanded(
              child: FutureBuilder<List<Viaje>>(
                future: _carga,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    final mensaje = snapshot.error is ExcepcionViajes
                        ? (snapshot.error! as ExcepcionViajes).mensaje
                        : 'No fue posible cargar tus viajes.';

                    return _EstadoErrorViajes(
                      mensaje: mensaje,
                      onReintentar: _recargar,
                    );
                  }

                  final viajes = snapshot.data ?? const <Viaje>[];

                  if (viajes.isEmpty) {
                    return EstadoVacio(
                      icono: Icons.luggage_outlined,
                      titulo: 'Todavía no tienes viajes',
                      mensaje:
                          'Crea tu primer viaje para comenzar a organizar '
                          'destinos, fechas y actividades.',
                      accion: BotonAccion(
                        texto: 'Crear mi primer viaje',
                        icono: Icons.add_rounded,
                        onPressed: _crearViaje,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _recargar,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: DimensionesApp.espacio32 + 72,
                      ),
                      itemCount: viajes.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        height: DimensionesApp.espacio12,
                      ),
                      itemBuilder: (context, index) {
                        final viaje = viajes[index];

                        return TarjetaViaje(
                          viaje: viaje,
                          onTap: () => _abrirDetalle(viaje),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoErrorViajes extends StatelessWidget {
  const _EstadoErrorViajes({
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final Future<void> Function() onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EstadoVacio(
        icono: Icons.cloud_off_outlined,
        titulo: 'No pudimos cargar tus viajes',
        mensaje: mensaje,
        accion: BotonAccion(
          texto: 'Reintentar',
          icono: Icons.refresh_rounded,
          onPressed: onReintentar,
        ),
      ),
    );
  }
}
