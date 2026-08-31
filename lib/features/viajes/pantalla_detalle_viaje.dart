import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import '../../shared/widgets/tarjeta_informativa.dart';
import '../actividades/modelos/actividad_viaje.dart';
import '../actividades/servicios/repositorio_actividades.dart';
import 'modelos/viaje.dart';
import 'servicios/repositorio_viajes.dart';

/// Muestra la información completa de un viaje y su itinerario.
class PantallaDetalleViaje extends StatefulWidget {
  const PantallaDetalleViaje({
    super.key,
    required this.viajeId,
    this.repositorio,
    this.repositorioActividades,
  });

  final String viajeId;
  final FuenteViajes? repositorio;
  final FuenteActividades? repositorioActividades;

  @override
  State<PantallaDetalleViaje> createState() => _PantallaDetalleViajeState();
}

class _PantallaDetalleViajeState extends State<PantallaDetalleViaje> {
  late Future<Viaje?> _carga;
  late Future<List<ActividadViaje>> _cargaActividades;
  bool _eliminando = false;

  FuenteViajes get _repositorio =>
      widget.repositorio ?? RepositorioViajes.instancia;

  FuenteActividades get _repositorioActividades =>
      widget.repositorioActividades ?? RepositorioActividades.instancia;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _carga = _repositorio.obtenerPorId(widget.viajeId);
    _cargaActividades =
        _repositorioActividades.listarPorViaje(widget.viajeId);
  }

  Future<void> _recargarActividades() async {
    setState(() {
      _cargaActividades =
          _repositorioActividades.listarPorViaje(widget.viajeId);
    });

    await _cargaActividades;
  }

  Future<void> _editar() async {
    if (_eliminando) {
      return;
    }

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

  Future<void> _crearActividad(Viaje viaje) async {
    final creada = await context.push<bool>(
      RutasApp.nuevaActividadDeViaje(widget.viajeId),
      extra: viaje,
    );

    if (creada == true && mounted) {
      await _recargarActividades();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad creada correctamente.')),
      );
    }
  }

  Future<void> _editarActividad(
    Viaje viaje,
    ActividadViaje actividad,
  ) async {
    final actualizada = await context.push<bool>(
      RutasApp.edicionActividadDeViaje(
        widget.viajeId,
        actividad.id,
      ),
      extra: viaje,
    );

    if (actualizada == true && mounted) {
      await _recargarActividades();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actividad actualizada correctamente.'),
        ),
      );
    }
  }

  Future<void> _cambiarCompletada(ActividadViaje actividad) async {
    try {
      await _repositorioActividades.actualizar(
        actividad.copyWith(
          completada: !actividad.completada,
        ),
      );

      if (!mounted) {
        return;
      }

      await _recargarActividades();
    } on ExcepcionActividades catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.mensaje)),
      );
    }
  }

  Future<void> _eliminarActividad(ActividadViaje actividad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar actividad'),
          content: Text(
            '¿Seguro que deseas eliminar "${actividad.titulo}" del itinerario?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    try {
      await _repositorioActividades.eliminar(actividad.id);

      if (!mounted) {
        return;
      }

      await _recargarActividades();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad eliminada.')),
      );
    } on ExcepcionActividades catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.mensaje)),
      );
    }
  }

  Future<void> _eliminar(Viaje viaje) async {
    if (_eliminando) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar viaje'),
          content: Text(
            '¿Seguro que deseas eliminar "${viaje.titulo}"? '
            'Esta acción no se puede deshacer y también eliminará '
            'sus actividades.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _eliminando = true;
    });

    try {
      await _repositorio.eliminar(viaje.id);

      if (!mounted) {
        return;
      }

      context.pop(true);
    } on ExcepcionViajes catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.mensaje)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _eliminando = false;
        });
      }
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
            onPressed: _eliminando ? null : _editar,
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
                    ),
                  ),
                  const SizedBox(height: DimensionesApp.espacio24),
                  _SeccionActividades(
                    viaje: viaje,
                    carga: _cargaActividades,
                    onCrear: () => _crearActividad(viaje),
                    onEditar: (actividad) =>
                        _editarActividad(viaje, actividad),
                    onCambiarCompletada: _cambiarCompletada,
                    onEliminar: _eliminarActividad,
                    onReintentar: _recargarActividades,
                  ),
                  const SizedBox(height: DimensionesApp.espacio24),
                  BotonAccion(
                    texto: 'Editar viaje',
                    icono: Icons.edit_outlined,
                    onPressed: _eliminando ? null : _editar,
                  ),
                  const SizedBox(height: DimensionesApp.espacio12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _eliminando ? null : () => _eliminar(viaje),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        _eliminando ? 'Eliminando...' : 'Eliminar viaje',
                      ),
                    ),
                  ),
                  if (_eliminando) ...[
                    const SizedBox(height: DimensionesApp.espacio12),
                    const Center(child: CircularProgressIndicator()),
                  ],
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

class _SeccionActividades extends StatelessWidget {
  const _SeccionActividades({
    required this.viaje,
    required this.carga,
    required this.onCrear,
    required this.onEditar,
    required this.onCambiarCompletada,
    required this.onEliminar,
    required this.onReintentar,
  });

  final Viaje viaje;
  final Future<List<ActividadViaje>> carga;
  final VoidCallback onCrear;
  final ValueChanged<ActividadViaje> onEditar;
  final ValueChanged<ActividadViaje> onCambiarCompletada;
  final ValueChanged<ActividadViaje> onEliminar;
  final Future<void> Function() onReintentar;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActividadViaje>>(
      future: carga,
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Itinerario',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Agregar actividad',
                  onPressed: onCrear,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: DimensionesApp.espacio4),
            Text(
              'Del ${_formatearFecha(viaje.fechaInicio)} al '
              '${_formatearFecha(viaje.fechaFin)}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DimensionesApp.espacio16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              EstadoVacio(
                icono: Icons.event_busy_outlined,
                titulo: 'No pudimos cargar el itinerario',
                mensaje: snapshot.error is ExcepcionActividades
                    ? (snapshot.error! as ExcepcionActividades).mensaje
                    : 'No fue posible cargar las actividades.',
                accion: BotonAccion(
                  texto: 'Reintentar',
                  icono: Icons.refresh_rounded,
                  onPressed: onReintentar,
                ),
              )
            else if ((snapshot.data ?? const <ActividadViaje>[]).isEmpty)
              EstadoVacio(
                icono: Icons.event_note_outlined,
                titulo: 'Aún no hay actividades',
                mensaje:
                    'Agrega actividades para comenzar a construir tu itinerario.',
                accion: BotonAccion(
                  texto: 'Agregar actividad',
                  icono: Icons.add_rounded,
                  onPressed: onCrear,
                ),
              )
            else
              ..._construirDias(context, snapshot.data!),
          ],
        );
      },
    );
  }

  List<Widget> _construirDias(
    BuildContext context,
    List<ActividadViaje> actividades,
  ) {
    final grupos = <DateTime, List<ActividadViaje>>{};

    for (final actividad in actividades) {
      final dia = DateTime(
        actividad.fecha.year,
        actividad.fecha.month,
        actividad.fecha.day,
      );

      grupos.putIfAbsent(dia, () => []).add(actividad);
    }

    final dias = grupos.keys.toList()..sort();

    return [
      for (final dia in dias) ...[
        Padding(
          padding: const EdgeInsets.only(
            top: DimensionesApp.espacio8,
            bottom: DimensionesApp.espacio8,
          ),
          child: Text(
            _fechaLarga(dia),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final actividad in grupos[dia]!)
          Padding(
            padding: const EdgeInsets.only(
              bottom: DimensionesApp.espacio12,
            ),
            child: _TarjetaActividad(
              actividad: actividad,
              onEditar: () => onEditar(actividad),
              onCambiarCompletada: () =>
                  onCambiarCompletada(actividad),
              onEliminar: () => onEliminar(actividad),
            ),
          ),
      ],
    ];
  }

  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  static String _fechaLarga(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _TarjetaActividad extends StatelessWidget {
  const _TarjetaActividad({
    required this.actividad,
    required this.onEditar,
    required this.onCambiarCompletada,
    required this.onEliminar,
  });

  final ActividadViaje actividad;
  final VoidCallback onEditar;
  final VoidCallback onCambiarCompletada;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final hora = actividad.horaInicio;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DimensionesApp.espacio12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: actividad.completada,
              tooltip: actividad.completada
                  ? 'Marcar como pendiente'
                  : 'Marcar como completada',
              onChanged: (_) => onCambiarCompletada(),
            ),
            const SizedBox(width: DimensionesApp.espacio4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad.titulo,
                    style: textTheme.titleMedium?.copyWith(
                      decoration: actividad.completada
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (hora != null) ...[
                    const SizedBox(height: DimensionesApp.espacio4),
                    Text(
                      hora,
                      style: textTheme.bodySmall,
                    ),
                  ],
                  if (actividad.lugar?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: DimensionesApp.espacio8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 18),
                        const SizedBox(width: DimensionesApp.espacio8),
                        Expanded(
                          child: Text(actividad.lugar!.trim()),
                        ),
                      ],
                    ),
                  ],
                  if (actividad.notas?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: DimensionesApp.espacio8),
                    Text(
                      actividad.notas!.trim(),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opciones de actividad',
              onSelected: (valor) {
                if (valor == 'editar') {
                  onEditar();
                } else if (valor == 'eliminar') {
                  onEliminar();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
