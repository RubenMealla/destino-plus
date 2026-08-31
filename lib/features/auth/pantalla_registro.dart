import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/marca_destino_plus.dart';
import 'widgets/campo_clave.dart';

/// Interfaz inicial para el registro de usuarios.
///
/// Incluye validaciones locales y confirmación de contraseña. La creación
/// real de cuentas se conectará al servicio de autenticación posteriormente.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  final _confirmacionController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _claveController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    final nombre = valor?.trim() ?? '';

    if (nombre.isEmpty) {
      return 'Ingresa tu nombre.';
    }

    if (nombre.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }

    return null;
  }

  String? _validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }

    final expresion = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!expresion.hasMatch(correo)) {
      return 'Ingresa un correo electrónico válido.';
    }

    return null;
  }

  String? _validarClave(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa una contraseña.';
    }

    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    return null;
  }

  String? _validarConfirmacion(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma tu contraseña.';
    }

    if (valor != _claveController.text) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }

  void _validarFormulario() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Formulario válido. El registro se conectará en la siguiente etapa.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => context.go(RutasApp.inicioSesion),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ContenidoAdaptable(
            padding: const EdgeInsets.fromLTRB(
              DimensionesApp.espacio20,
              DimensionesApp.espacio8,
              DimensionesApp.espacio20,
              DimensionesApp.espacio32,
            ),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: MarcaDestinoPlus(
                        mostrarLema: false,
                        alineacion: CrossAxisAlignment.center,
                      ),
                    ),
                    const SizedBox(height: DimensionesApp.espacio24),
                    Text(
                      'Crea tu cuenta',
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionesApp.espacio8),
                    Text(
                      'Empieza a organizar tus próximos destinos con Destino+.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionesApp.espacio32),
                    TextFormField(
                      controller: _nombreController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      validator: _validarNombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      validator: _validarCorreo,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    CampoClave(
                      controller: _claveController,
                      etiqueta: 'Contraseña',
                      validator: _validarClave,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    CampoClave(
                      controller: _confirmacionController,
                      etiqueta: 'Confirmar contraseña',
                      validator: _validarConfirmacion,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _validarFormulario(),
                    ),
                    const SizedBox(height: DimensionesApp.espacio24),
                    BotonAccion(
                      texto: 'Crear cuenta',
                      icono: Icons.person_add_alt_1_rounded,
                      onPressed: _validarFormulario,
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta?',
                          style: textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go(RutasApp.inicioSesion),
                          child: const Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
