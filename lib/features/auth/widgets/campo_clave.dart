import 'package:flutter/material.dart';

/// Campo reutilizable para contraseñas.
///
/// Permite alternar la visibilidad de la clave sin duplicar esta lógica en
/// las pantallas de inicio de sesión y registro.
class CampoClave extends StatefulWidget {
  const CampoClave({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? Function(String?) validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<CampoClave> createState() => _CampoClaveState();
}

class _CampoClaveState extends State<CampoClave> {
  bool _ocultar = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _ocultar,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _ocultar ? 'Mostrar contraseña' : 'Ocultar contraseña',
          onPressed: () {
            setState(() {
              _ocultar = !_ocultar;
            });
          },
          icon: Icon(
            _ocultar
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
