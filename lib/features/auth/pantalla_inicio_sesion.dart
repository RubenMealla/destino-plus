import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/marca_destino_plus.dart';
import 'estado/estado_sesion.dart';
import 'servicios/servicio_autenticacion.dart';
import 'widgets/campo_clave.dart';

/// Pantalla de acceso mediante correo electrónico y contraseña.
class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();

  bool _procesando = false;

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

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _procesando) {
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      await context.read<EstadoSesion>().iniciarSesion(
            correo: _correoController.text,
            clave: _claveController.text,
          );

      if (!mounted) {
        return;
      }

      context.go(RutasApp.inicio);
    } on ExcepcionAutenticacion catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.mensaje)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
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
                      enabled: !_procesando,
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
                      onFieldSubmitted: (_) => _iniciarSesion(),
                    ),
                    const SizedBox(height: DimensionesApp.espacio24),
                    BotonAccion(
                      texto:
                          _procesando ? 'Iniciando sesión...' : 'Iniciar sesión',
                      icono: _procesando ? null : Icons.login_rounded,
                      onPressed: _procesando ? null : _iniciarSesion,
                    ),
                    if (_procesando) ...[
                      const SizedBox(height: DimensionesApp.espacio12),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    const SizedBox(height: DimensionesApp.espacio16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta?',
                          style: textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _procesando
                              ? null
                              : () => context.go(RutasApp.registro),
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
