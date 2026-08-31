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

/// Pantalla para crear una cuenta de Destino+.
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

  bool _procesando = false;

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

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _procesando) {
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      final resultado = await context.read<EstadoSesion>().registrar(
            nombre: _nombreController.text,
            correo: _correoController.text,
            clave: _claveController.text,
          );

      if (!mounted) {
        return;
      }

      if (resultado.requiereConfirmacionCorreo) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirma tu correo'),
            content: const Text(
              'La cuenta fue creada. Revisa tu correo electrónico y confirma '
              'tu dirección antes de iniciar sesión.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );

        if (mounted) {
          context.go(RutasApp.inicioSesion);
        }

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
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          onPressed:
              _procesando ? null : () => context.go(RutasApp.inicioSesion),
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
                      enabled: !_procesando,
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
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    CampoClave(
                      controller: _confirmacionController,
                      etiqueta: 'Confirmar contraseña',
                      validator: _validarConfirmacion,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _registrar(),
                    ),
                    const SizedBox(height: DimensionesApp.espacio24),
                    BotonAccion(
                      texto: _procesando ? 'Creando cuenta...' : 'Crear cuenta',
                      icono:
                          _procesando ? null : Icons.person_add_alt_1_rounded,
                      onPressed: _procesando ? null : _registrar,
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
                          '¿Ya tienes una cuenta?',
                          style: textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _procesando
                              ? null
                              : () => context.go(RutasApp.inicioSesion),
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
