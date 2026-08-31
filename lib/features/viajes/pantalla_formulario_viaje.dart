import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import 'modelos/viaje.dart';
import 'servicios/repositorio_viajes.dart';

/// Formulario para crear o editar un viaje.
class PantallaFormularioViaje extends StatefulWidget {
  const PantallaFormularioViaje({
    super.key,
    this.viajeId,
    this.repositorio,
  });

  final String? viajeId;
  final FuenteViajes? repositorio;

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

  @override
  void initState() {
    super.initState();

    if (widget.esEdicion) {
      _cargarViaje();
    }
  }

  Future<void> _cargarViaje() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final viaje = await _repositorio.obtenerPorId(widget.viajeId!);

      if (!mounted) return;

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
      _fechaInicioController.text = _formatearFecha(viaje.fechaInicio);
      _fechaFinController.text = _formatearFecha(viaje.fechaFin);
      _descripcionController.text = viaje.descripcion ?? '';

      setState(() {
        _cargando = false;
      });
    } on ExcepcionViajes catch (error) {
      if (!mounted) return;

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

  String? _validarTexto(
    String? valor, {
    required String nombre,
    required int maximo,
  }) {
    final texto = valor?.trim() ?? '';

    if (texto.length < 2) {
      return '$nombre debe tener al menos 2 caracteres.';
    }

    if (texto.length > maximo) {
      return '$nombre no puede superar $maximo caracteres.';
    }

    return null;
  }

  String? _validarFecha(String? valor) {
    if (_parsearFecha(valor) == null) {
      return 'Usa el formato DD/MM/AAAA.';
    }
    return null;
  }

  DateTime? _parsearFecha(String? valor) {
    final partes = (valor ?? '').trim().split('/');
    if (partes.length != 3) return null;

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final anio = int.tryParse(partes[2]);

    if (dia == null || mes == null || anio == null) return null;
    if (anio < 2000 || anio > 2100 || mes < 1 || mes > 12) return null;

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

    final inicio = _parsearFecha(_fechaInicioController.text)!;
    final fin = _parsearFecha(_fechaFinController.text)!;

    if (fin.isBefore(inicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de fin no puede ser anterior a la fecha de inicio.',
          ),
        ),
      );
      return;
    }

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

      if (!mounted) return;

      context.pop(true);
    } on ExcepcionViajes catch (error) {
      if (!mounted) return;

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
    final tituloPantalla = widget.esEdicion ? 'Editar viaje' : 'Nuevo viaje';
    final tituloFormulario =
        widget.esEdicion ? 'Actualiza tu viaje' : 'Crea un nuevo viaje';

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
                                : 'Completa la información principal. Después podrás '
                                    'agregar más detalles y actividades.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: DimensionesApp.espacio24),
                          TextFormField(
                            controller: _tituloController,
                            enabled: !_guardando,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 100,
                            validator: (valor) => _validarTexto(
                              valor,
                              nombre: 'El título',
                              maximo: 100,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Título del viaje',
                              hintText: 'Ej. Vacaciones de invierno',
                              prefixIcon: Icon(Icons.luggage_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio12),
                          TextFormField(
                            controller: _destinoController,
                            enabled: !_guardando,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 120,
                            validator: (valor) => _validarTexto(
                              valor,
                              nombre: 'El destino',
                              maximo: 120,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Destino',
                              hintText: 'Ej. Tarija, Bolivia',
                              prefixIcon: Icon(Icons.place_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio12),
                          TextFormField(
                            controller: _fechaInicioController,
                            enabled: !_guardando,
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            validator: _validarFecha,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de inicio',
                              hintText: 'DD/MM/AAAA',
                              prefixIcon:
                                  Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio16),
                          TextFormField(
                            controller: _fechaFinController,
                            enabled: !_guardando,
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            validator: _validarFecha,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de fin',
                              hintText: 'DD/MM/AAAA',
                              prefixIcon:
                                  Icon(Icons.event_available_outlined),
                            ),
                          ),
                          const SizedBox(height: DimensionesApp.espacio16),
                          TextFormField(
                            controller: _descripcionController,
                            enabled: !_guardando,
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 1000,
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
