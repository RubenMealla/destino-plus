import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import 'modelos/actividad_viaje.dart';
import 'servicios/repositorio_actividades.dart';

/// Formulario para crear o editar una actividad del itinerario.
class PantallaFormularioActividad extends StatefulWidget {
  const PantallaFormularioActividad({
    super.key,
    required this.viajeId,
    this.actividadId,
    this.repositorio,
  });

  final String viajeId;
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
      _fechaController.text = _formatearFecha(actividad.fecha);
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

  String? _validarTitulo(String? valor) {
    final titulo = valor?.trim() ?? '';

    if (titulo.length < 2) {
      return 'El título debe tener al menos 2 caracteres.';
    }

    if (titulo.length > 120) {
      return 'El título no puede superar los 120 caracteres.';
    }

    return null;
  }

  String? _validarFecha(String? valor) {
    if (_parsearFecha(valor) == null) {
      return 'Usa el formato DD/MM/AAAA.';
    }

    return null;
  }

  String? _validarHora(String? valor) {
    final hora = valor?.trim() ?? '';

    if (hora.isEmpty) {
      return null;
    }

    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(hora)) {
      return 'Usa el formato HH:mm.';
    }

    return null;
  }

  DateTime? _parsearFecha(String? valor) {
    final partes = (valor ?? '').trim().split('/');

    if (partes.length != 3) {
      return null;
    }

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final anio = int.tryParse(partes[2]);

    if (dia == null || mes == null || anio == null) {
      return null;
    }

    if (anio < 2000 || anio > 2100 || mes < 1 || mes > 12) {
      return null;
    }

    final fecha = DateTime(anio, mes, dia);

    if (fecha.year != anio || fecha.month != mes || fecha.day != dia) {
      return null;
    }

    return fecha;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _guardando) {
      return;
    }

    final fecha = _parsearFecha(_fechaController.text)!;

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
                            'La hora y el lugar son opcionales.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: DimensionesApp.espacio24),
                          TextFormField(
                            controller: _tituloController,
                            enabled: !_guardando,
                            textCapitalization:
                                TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            maxLength: 120,
                            validator: _validarTitulo,
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
                            validator: _validarFecha,
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
                            validator: _validarHora,
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
                            maxLength: 160,
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
                            maxLength: 1000,
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

  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}
