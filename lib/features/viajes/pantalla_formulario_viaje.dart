import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import '../actividades/servicios/repositorio_actividades.dart';
import '../clima/servicios/cliente_open_meteo.dart';
import '../clima/widgets/selector_destino.dart';
import 'modelos/viaje.dart';
import 'servicios/repositorio_viajes.dart';
import 'validacion/validadores_viaje.dart';

/// Formulario para crear o editar un viaje.
class PantallaFormularioViaje extends StatefulWidget {
  const PantallaFormularioViaje({
    super.key,
    this.viajeId,
    this.repositorio,
    this.repositorioActividades,
    this.fuenteUbicaciones,
    this.fechaActual,
  });

  final String? viajeId;
  final FuenteViajes? repositorio;
  final FuenteActividades? repositorioActividades;
  final FuenteBusquedaUbicaciones? fuenteUbicaciones;

  /// Permite fijar "hoy" en pruebas sin alterar el comportamiento real.
  final DateTime? fechaActual;

  bool get esEdicion => viajeId != null;

  @override
  State<PantallaFormularioViaje> createState() =>
      _PantallaFormularioViajeState();
}

class _PantallaFormularioViajeState extends State<PantallaFormularioViaje> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _destinoController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _descripcionController = TextEditingController();

  Viaje? _viajeOriginal;
  bool _cargando = false;
  bool _guardando = false;
  String? _errorCarga;

  FuenteViajes get _repositorio =>
      widget.repositorio ?? RepositorioViajes.instancia;

  FuenteActividades get _repositorioActividades =>
      widget.repositorioActividades ?? RepositorioActividades.instancia;

  DateTime get _hoy =>
      ValidadoresViaje.soloFecha(widget.fechaActual ?? DateTime.now());

  bool get _habilitarAutocompletado =>
      widget.fuenteUbicaciones != null || widget.repositorio == null;

  @override
  void initState() {
    super.initState();

    if (widget.esEdicion) {
      _cargarViaje();
    } else {
      final hoy = _hoy;
      _fechaInicioController.text = ValidadoresViaje.formatearFecha(hoy);
      _fechaFinController.text = ValidadoresViaje.formatearFecha(hoy);
    }
  }

  Future<void> _cargarViaje() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final viaje = await _repositorio.obtenerPorId(widget.viajeId!);

      if (!mounted) {
        return;
      }

      if (viaje == null) {
        setState(() {
          _errorCarga = 'El viaje solicitado no existe.';
          _cargando = false;
        });
        return;
      }

      _viajeOriginal = viaje;
      _tituloController.text = viaje.titulo;
      _destinoController.text = viaje.destino;
      _fechaInicioController.text = ValidadoresViaje.formatearFecha(
        viaje.fechaInicio,
      );
      _fechaFinController.text = ValidadoresViaje.formatearFecha(
        viaje.fechaFin,
      );
      _descripcionController.text = viaje.descripcion ?? '';

      setState(() {
        _cargando = false;
      });
    } on ExcepcionViajes catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = error.mensaje;
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _destinoController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  DateTime _fechaMinimaInicio() {
    final original = _viajeOriginal?.fechaInicio;

    if (original != null) {
      final fechaOriginal = ValidadoresViaje.soloFecha(original);

      if (fechaOriginal.isBefore(_hoy)) {
        return fechaOriginal;
      }
    }

    return _hoy;
  }

  Future<void> _seleccionarFechaInicio() async {
    if (_guardando) {
      return;
    }

    final minima = _fechaMinimaInicio();
    final actual =
        ValidadoresViaje.parsearFecha(_fechaInicioController.text) ?? minima;
    final inicial = actual.isBefore(minima) ? minima : actual;

    final seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: minima,
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Selecciona la fecha de inicio',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (seleccionada == null || !mounted) {
      return;
    }

    final inicio = ValidadoresViaje.soloFecha(seleccionada);
    final finActual = ValidadoresViaje.parsearFecha(_fechaFinController.text);

    setState(() {
      _fechaInicioController.text = ValidadoresViaje.formatearFecha(inicio);

      if (finActual == null ||
          ValidadoresViaje.soloFecha(finActual).isBefore(inicio)) {
        _fechaFinController.text = ValidadoresViaje.formatearFecha(inicio);
      }
    });
  }

  Future<void> _seleccionarFechaFin() async {
    if (_guardando) {
      return;
    }

    final inicio =
        ValidadoresViaje.parsearFecha(_fechaInicioController.text) ?? _hoy;
    final minima = ValidadoresViaje.soloFecha(inicio);
    final finActual =
        ValidadoresViaje.parsearFecha(_fechaFinController.text) ?? minima;
    final inicial = finActual.isBefore(minima) ? minima : finActual;

    final seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: minima,
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Selecciona la fecha de fin',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (seleccionada == null || !mounted) {
      return;
    }

    setState(() {
      _fechaFinController.text = ValidadoresViaje.formatearFecha(seleccionada);
    });
  }

  String? _validarInicio(String? valor) {
    final errorFormato = ValidadoresViaje.fecha(valor);

    if (errorFormato != null) {
      return errorFormato;
    }

    final inicio = ValidadoresViaje.parsearFecha(valor)!;

    return ValidadoresViaje.fechaInicioPermitida(
      inicio,
      hoy: _hoy,
      inicioOriginal: _viajeOriginal?.fechaInicio,
    );
  }

  String? _validarFin(String? valor) {
    final errorFormato = ValidadoresViaje.fecha(valor);

    if (errorFormato != null) {
      return errorFormato;
    }

    final inicio = ValidadoresViaje.parsearFecha(_fechaInicioController.text);
    final fin = ValidadoresViaje.parsearFecha(valor);

    if (inicio != null && fin != null) {
      return ValidadoresViaje.rangoFechas(inicio, fin);
    }

    return null;
  }

  Future<bool> _rangoDejaActividadesFuera(
    Viaje original,
    DateTime inicio,
    DateTime fin,
  ) async {
    final originalInicio = ValidadoresViaje.soloFecha(original.fechaInicio);
    final originalFin = ValidadoresViaje.soloFecha(original.fechaFin);
    final nuevoInicio = ValidadoresViaje.soloFecha(inicio);
    final nuevoFin = ValidadoresViaje.soloFecha(fin);

    if (originalInicio == nuevoInicio && originalFin == nuevoFin) {
      return false;
    }

    final actividades = await _repositorioActividades.listarPorViaje(
      original.id,
    );

    return actividades.any((actividad) {
      final fecha = ValidadoresViaje.soloFecha(actividad.fecha);
      return fecha.isBefore(nuevoInicio) || fecha.isAfter(nuevoFin);
    });
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _guardando) {
      return;
    }

    final inicio = ValidadoresViaje.parsearFecha(_fechaInicioController.text)!;
    final fin = ValidadoresViaje.parsearFecha(_fechaFinController.text)!;

    setState(() {
      _guardando = true;
    });

    try {
      if (widget.esEdicion) {
        final original = _viajeOriginal;

        if (original == null) {
          throw const ExcepcionViajes(
            'No fue posible preparar el viaje para editarlo.',
          );
        }

        if (await _rangoDejaActividadesFuera(original, inicio, fin)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'El nuevo rango dejaría actividades fuera del viaje. '
                  'Ajusta primero esas actividades.',
                ),
              ),
            );
          }
          return;
        }

        await _repositorio.actualizar(
          original.copyWith(
            titulo: _tituloController.text.trim(),
            destino: _destinoController.text.trim(),
            fechaInicio: inicio,
            fechaFin: fin,
            descripcion: _descripcionController.text.trim(),
            limpiarDescripcion: _descripcionController.text.trim().isEmpty,
          ),
        );
      } else {
        await _repositorio.crear(
          titulo: _tituloController.text,
          destino: _destinoController.text,
          fechaInicio: inicio,
          fechaFin: fin,
          descripcion: _descripcionController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ExcepcionViajes catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.mensaje)));
    } on ExcepcionActividades {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible comprobar las actividades del viaje. '
            'Inténtalo nuevamente.',
          ),
        ),
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
    final tituloPantalla = widget.esEdicion ? 'Editar viaje' : 'Nuevo viaje';
    final tituloFormulario = widget.esEdicion
        ? 'Actualiza tu viaje'
        : 'Crea un nuevo viaje';

    return Scaffold(
      appBar: AppBar(title: Text(tituloPantalla)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _errorCarga != null
          ? Center(
              child: EstadoVacio(
                icono: Icons.error_outline_rounded,
                titulo: 'No pudimos cargar el viaje',
                mensaje: _errorCarga!,
                accion: BotonAccion(
                  texto: 'Reintentar',
                  icono: Icons.refresh_rounded,
                  onPressed: _cargarViaje,
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
                        tituloFormulario,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: DimensionesApp.espacio8),
                      Text(
                        widget.esEdicion
                            ? 'Modifica la información y guarda los cambios.'
                            : 'Completa la información principal. Después '
                                  'podrás agregar más detalles y actividades.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: DimensionesApp.espacio24),
                      TextFormField(
                        controller: _tituloController,
                        enabled: !_guardando,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: ValidadoresViaje.tituloMaximo,
                        validator: ValidadoresViaje.titulo,
                        decoration: const InputDecoration(
                          labelText: 'Título del viaje',
                          hintText: 'Ej. Vacaciones de invierno',
                          prefixIcon: Icon(Icons.luggage_outlined),
                        ),
                      ),
                      const SizedBox(height: DimensionesApp.espacio12),
                      SelectorDestino(
                        controller: _destinoController,
                        enabled: !_guardando,
                        fuente: widget.fuenteUbicaciones,
                        habilitarAutocompletado: _habilitarAutocompletado,
                        maxLength: ValidadoresViaje.destinoMaximo,
                        validator: ValidadoresViaje.destino,
                      ),
                      const SizedBox(height: DimensionesApp.espacio12),
                      TextFormField(
                        key: const Key('fecha-inicio-viaje'),
                        controller: _fechaInicioController,
                        enabled: !_guardando,
                        readOnly: true,
                        onTap: _seleccionarFechaInicio,
                        validator: _validarInicio,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de inicio',
                          hintText: 'DD/MM/AAAA',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                        ),
                      ),
                      const SizedBox(height: DimensionesApp.espacio16),
                      TextFormField(
                        key: const Key('fecha-fin-viaje'),
                        controller: _fechaFinController,
                        enabled: !_guardando,
                        readOnly: true,
                        onTap: _seleccionarFechaFin,
                        validator: _validarFin,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de fin',
                          hintText: 'DD/MM/AAAA',
                          prefixIcon: Icon(Icons.event_available_outlined),
                          suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                        ),
                      ),
                      const SizedBox(height: DimensionesApp.espacio16),
                      TextFormField(
                        controller: _descripcionController,
                        enabled: !_guardando,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: ValidadoresViaje.descripcionMaxima,
                        validator: ValidadoresViaje.descripcion,
                        decoration: const InputDecoration(
                          labelText: 'Descripción opcional',
                          hintText: 'Notas generales sobre el viaje',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: DimensionesApp.espacio24),
                      BotonAccion(
                        texto: _guardando
                            ? 'Guardando cambios...'
                            : widget.esEdicion
                            ? 'Guardar cambios'
                            : 'Guardar viaje',
                        icono: _guardando ? null : Icons.save_outlined,
                        onPressed: _guardando ? null : _guardar,
                      ),
                      if (_guardando) ...[
                        const SizedBox(height: DimensionesApp.espacio12),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
