import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/marca_destino_plus.dart';
import 'widgets/campo_clave.dart';

/// Interfaz inicial para el acceso de usuarios.
///
/// En este commit se implementan la presentación, los campos y las
/// validaciones locales. La autenticación real se integrará en el siguiente
/// bloque de trabajo.
class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
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
      return 'Ingresa tu contraseña.';
    }

    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
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
          'Formulario válido. La autenticación se conectará en la siguiente etapa.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContenidoAdaptable(
            padding: const EdgeInsets.fromLTRB(
              DimensionesApp.espacio20,
              DimensionesApp.espacio32,
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
                    const SizedBox(height: DimensionesApp.espacio32),
                    Text(
                      'Bienvenido de nuevo',
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionesApp.espacio8),
                    Text(
                      'Inicia sesión para continuar organizando tus viajes.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionesApp.espacio32),
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _validarFormulario(),
                    ),
                    const SizedBox(height: DimensionesApp.espacio24),
                    BotonAccion(
                      texto: 'Iniciar sesión',
                      icono: Icons.login_rounded,
                      onPressed: _validarFormulario,
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta?',
                          style: textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go(RutasApp.registro),
                          child: const Text('Crear cuenta'),
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
