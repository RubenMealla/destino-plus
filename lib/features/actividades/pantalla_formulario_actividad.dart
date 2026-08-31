import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import '../viajes/modelos/viaje.dart';
import 'modelos/actividad_viaje.dart';
import 'servicios/repositorio_actividades.dart';
import 'validacion/validadores_actividad.dart';

/// Formulario para crear o editar una actividad del itinerario.
class PantallaFormularioActividad extends StatefulWidget {
  const PantallaFormularioActividad({
    super.key,
    required this.viajeId,
    this.viaje,
    this.actividadId,
    this.repositorio,
  });

  final String viajeId;

  /// Viaje ya cargado por la pantalla de detalle.
  ///
  /// Permite validar inmediatamente que la actividad quede dentro del rango
  /// del viaje. La base de datos también aplica esta regla.
  final Viaje? viaje;

  final String? actividadId;
  final FuenteActividades? repositorio;

  bool get esEdicion => actividadId != null;

  @override
  State<PantallaFormularioActividad> createState() =>
      _PantallaFormularioActividadState();
}

class _PantallaFormularioActividadState
    extends State<PantallaFormularioActividad> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _lugarController = TextEditingController();
  final _notasController = TextEditingController();

  ActividadViaje? _actividadOriginal;
  bool _cargando = false;
  bool _guardando = false;
  String? _errorCarga;

  FuenteActividades get _repositorio =>
      widget.repositorio ?? RepositorioActividades.instancia;

  @override
  void initState() {
    super.initState();

    if (widget.esEdicion) {
      _cargarActividad();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _lugarController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarActividad() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final actividad = await _repositorio.obtenerPorId(
        widget.actividadId!,
      );

      if (!mounted) {
        return;
      }

      if (actividad == null || actividad.viajeId != widget.viajeId) {
        setState(() {
          _errorCarga = 'La actividad solicitada no existe.';
          _cargando = false;
        });
        return;
      }

      _actividadOriginal = actividad;
      _tituloController.text = actividad.titulo;
      _fechaController.text =
          ValidadoresActividad.formatearFecha(actividad.fecha);
      _horaController.text = actividad.horaInicio ?? '';
      _lugarController.text = actividad.lugar ?? '';
      _notasController.text = actividad.notas ?? '';

      setState(() {
        _cargando = false;
      });
    } on ExcepcionActividades catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = error.mensaje;
        _cargando = false;
      });
    }
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _guardando) {
      return;
    }

    final fecha = ValidadoresActividad.parsearFecha(
      _fechaController.text,
    )!;

    final viaje = widget.viaje;

    if (viaje != null) {
      final errorFecha = ValidadoresActividad.fechaDentroDelViaje(
        fecha,
        viaje,
      );

      if (errorFecha != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorFecha)),
        );
        return;
      }
    }

    setState(() {
      _guardando = true;
    });

    try {
      if (widget.esEdicion) {
        final original = _actividadOriginal;

        if (original == null) {
          throw const ExcepcionActividades(
            'No fue posible preparar la actividad para editarla.',
          );
        }

        await _repositorio.actualizar(
          original.copyWith(
            titulo: _tituloController.text.trim(),
            fecha: fecha,
            horaInicio: _horaController.text.trim(),
            limpiarHoraInicio: _horaController.text.trim().isEmpty,
            lugar: _lugarController.text.trim(),
            limpiarLugar: _lugarController.text.trim().isEmpty,
            notas: _notasController.text.trim(),
            limpiarNotas: _notasController.text.trim().isEmpty,
          ),
        );
      } else {
        await _repositorio.crear(
          viajeId: widget.viajeId,
          titulo: _tituloController.text,
          fecha: fecha,
          horaInicio: _horaController.text,
          lugar: _lugarController.text,
          notas: _notasController.text,
        );
      }

      if (!mounted) {
        return;
      }

      context.pop(true);
    } on ExcepcionActividades catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.mensaje)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tituloPantalla =
        widget.esEdicion ? 'Editar actividad' : 'Nueva actividad';

    return Scaffold(
      appBar: AppBar(title: Text(tituloPantalla)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _errorCarga != null
              ? Center(
                  child: EstadoVacio(
                    icono: Icons.event_busy_outlined,
                    titulo: 'No pudimos cargar la actividad',
                    mensaje: _errorCarga!,
                    accion: BotonAccion(
                      texto: 'Reintentar',
                      icono: Icons.refresh_rounded,
                      onPressed: _cargarActividad,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: ContenidoAdaptable(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.esEdicion
                                ? 'Actualiza la actividad'
                                : 'Agrega una actividad al itinerario',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: DimensionesApp.espacio8),
                          Text(
                            widget.viaje == null
                                ? 'La hora y el lugar son opcionales.'
                                : 'Programa actividades entre '
                                    '${ValidadoresActividad.formatearFecha(widget.viaje!.fechaInicio)} '
                                    'y ${ValidadoresActividad.formatearFecha(widget.viaje!.fechaFin)}.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: DimensionesApp.espacio24),
                          TextFormField(
                            controller: _tituloController,
                            enabled: !_guardando,
                            textCapitalization:
                                TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            maxLength: ValidadoresActividad.tituloMaximo,
                            validator: ValidadoresActividad.titulo,
                            decoration: const InputDecoration(
                              labelText: 'Actividad',
                              hintText: 'Ej. Visitar San Jacinto',
                              prefixIcon:
                                  Icon(Icons.event_note_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio12),
                          TextFormField(
                            controller: _fechaController,
                            enabled: !_guardando,
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            validator: ValidadoresActividad.fecha,
                            decoration: const InputDecoration(
                              labelText: 'Fecha',
                              hintText: 'DD/MM/AAAA',
                              prefixIcon:
                                  Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio16),
                          TextFormField(
                            controller: _horaController,
                            enabled: !_guardando,
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            validator: ValidadoresActividad.hora,
                            decoration: const InputDecoration(
                              labelText: 'Hora opcional',
                              hintText: 'HH:mm',
                              prefixIcon:
                                  Icon(Icons.schedule_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio16),
                          TextFormField(
                            controller: _lugarController,
                            enabled: !_guardando,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            maxLength: ValidadoresActividad.lugarMaximo,
                            validator: ValidadoresActividad.lugar,
                            decoration: const InputDecoration(
                              labelText: 'Lugar opcional',
                              hintText: 'Ej. Plaza principal',
                              prefixIcon: Icon(Icons.place_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio12),
                          TextFormField(
                            controller: _notasController,
                            enabled: !_guardando,
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: ValidadoresActividad.notasMaximas,
                            validator: ValidadoresActividad.notas,
                            decoration: const InputDecoration(
                              labelText: 'Notas opcionales',
                              hintText:
                                  'Indicaciones o información adicional',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.notes_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio24),
                          BotonAccion(
                            texto: _guardando
                                ? 'Guardando actividad...'
                                : widget.esEdicion
                                    ? 'Guardar cambios'
                                    : 'Guardar actividad',
                            icono:
                                _guardando ? null : Icons.save_outlined,
                            onPressed: _guardando ? null : _guardar,
                          ),
                          if (_guardando) ...[
                            const SizedBox(
                              height: DimensionesApp.espacio12,
                            ),
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
