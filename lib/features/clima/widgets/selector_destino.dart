import 'dart:async';

import 'package:flutter/material.dart';

import '../modelos/ubicacion_clima.dart';
import '../servicios/cliente_open_meteo.dart';

/// Campo reutilizable para buscar y seleccionar destinos con Open-Meteo.
///
/// El texto sigue siendo editable para permitir destinos libres. Cuando el
/// usuario selecciona una sugerencia se entrega también la ubicación exacta,
/// incluidas sus coordenadas.
class SelectorDestino extends StatefulWidget {
  const SelectorDestino({
    super.key,
    required this.controller,
    this.enabled = true,
    this.validator,
    this.fuente,
    this.habilitarAutocompletado = true,
    this.onChanged,
    this.onSubmitted,
    this.onSeleccionado,
    this.maxLength,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon = Icons.place_outlined,
    this.labelText = 'Destino',
    this.hintText = 'Ej. Tarija, Bolivia',
  });

  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final FuenteBusquedaUbicaciones? fuente;
  final bool habilitarAutocompletado;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<UbicacionClima>? onSeleccionado;
  final int? maxLength;
  final TextInputAction textInputAction;
  final IconData prefixIcon;
  final String labelText;
  final String hintText;

  @override
  State<SelectorDestino> createState() => _SelectorDestinoState();
}

class _SelectorDestinoState extends State<SelectorDestino> {
  Timer? _debounce;
  ClienteOpenMeteo? _clientePropio;
  List<UbicacionClima> _sugerencias = const [];
  bool _buscando = false;
  String? _errorBusqueda;
  int _revision = 0;

  FuenteBusquedaUbicaciones? get _fuente {
    if (!widget.habilitarAutocompletado) {
      return null;
    }

    return widget.fuente ?? _clientePropio;
  }

  @override
  void initState() {
    super.initState();

    if (widget.habilitarAutocompletado && widget.fuente == null) {
      _clientePropio = ClienteOpenMeteo();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _clientePropio?.cerrar();
    super.dispose();
  }

  void _alCambiar(String valor) {
    widget.onChanged?.call(valor);
    _debounce?.cancel();

    final termino = valor.trim();
    final revision = ++_revision;

    if (_fuente == null || termino.length < 2) {
      if (_sugerencias.isNotEmpty || _buscando || _errorBusqueda != null) {
        setState(() {
          _sugerencias = const [];
          _buscando = false;
          _errorBusqueda = null;
        });
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _buscar(termino, revision);
    });
  }

  Future<void> _buscar(String termino, int revision) async {
    final fuente = _fuente;
    if (fuente == null || !mounted) {
      return;
    }

    setState(() {
      _buscando = true;
      _errorBusqueda = null;
    });

    try {
      final resultados = await fuente.buscarUbicaciones(termino, limite: 5);

      if (!mounted || revision != _revision) {
        return;
      }

      setState(() {
        _sugerencias = resultados;
        _buscando = false;
      });
    } on ExcepcionClima {
      if (!mounted || revision != _revision) {
        return;
      }

      setState(() {
        _sugerencias = const [];
        _buscando = false;
        _errorBusqueda = 'No pudimos buscar destinos en este momento.';
      });
    } catch (_) {
      if (!mounted || revision != _revision) {
        return;
      }

      setState(() {
        _sugerencias = const [];
        _buscando = false;
        _errorBusqueda = 'No pudimos buscar destinos en este momento.';
      });
    }
  }

  void _seleccionar(UbicacionClima ubicacion) {
    _debounce?.cancel();
    _revision += 1;

    widget.controller.text = ubicacion.nombreCompleto;
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );

    setState(() {
      _sugerencias = const [];
      _buscando = false;
      _errorBusqueda = null;
    });

    widget.onSeleccionado?.call(ubicacion);
    widget.onChanged?.call(widget.controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('selector-destino-campo'),
          controller: widget.controller,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          textCapitalization: TextCapitalization.words,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: _alCambiar,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: _buscando
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_errorBusqueda != null) ...[
          const SizedBox(height: 4),
          Text(_errorBusqueda!, style: Theme.of(context).textTheme.bodySmall),
        ],
        if (_sugerencias.isNotEmpty) ...[
          const SizedBox(height: 4),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sugerencias.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final ubicacion = _sugerencias[index];

                return ListTile(
                  key: ValueKey('destino-sugerencia-$index'),
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(ubicacion.nombreCompleto),
                  onTap: () => _seleccionar(ubicacion),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
