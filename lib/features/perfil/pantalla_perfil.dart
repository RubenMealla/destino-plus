import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/preferencias/estado_apariencia.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../features/auth/estado/estado_sesion.dart';
import '../../features/auth/servicios/servicio_autenticacion.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/tarjeta_informativa.dart';

/// Perfil, sesión y preferencias locales del usuario.
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  bool _cerrandoSesion = false;
  bool _guardandoApariencia = false;

  Future<void> _cerrarSesion() async {
    if (_cerrandoSesion) {
      return;
    }

    setState(() {
      _cerrandoSesion = true;
    });

    try {
      await context.read<EstadoSesion>().cerrarSesion();
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
          _cerrandoSesion = false;
        });
      }
    }
  }

  Future<void> _cambiarApariencia(ModoApariencia modo) async {
    final estado = context.read<EstadoApariencia>();

    if (_guardandoApariencia || estado.modo == modo) {
      return;
    }

    setState(() {
      _guardandoApariencia = true;
    });

    try {
      await estado.cambiarModo(modo);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar la preferencia de apariencia.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardandoApariencia = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final estadoSesion = context.watch<EstadoSesion>();
    final estadoApariencia = context.watch<EstadoApariencia>();
    final usuario = estadoSesion.usuario;
    final metadata = usuario?.userMetadata;
    final nombre = (metadata?['nombre'] as String?)?.trim();
    final nombreVisible =
        nombre != null && nombre.isNotEmpty ? nombre : 'Usuario de Destino+';
    final correoVisible = usuario?.email ?? 'Correo no disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: ContenidoAdaptable(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 38,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: DimensionesApp.espacio12),
                    Text(
                      nombreVisible,
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionesApp.espacio4),
                    Text(
                      correoVisible,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio32),
              const EncabezadoSeccion(
                titulo: 'Ajustes',
                subtitulo:
                    'Personaliza cómo se ve Destino+ en este dispositivo.',
              ),
              const SizedBox(height: DimensionesApp.espacio16),
              TarjetaInformativa(
                icono: Icons.palette_outlined,
                titulo: 'Apariencia',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elige el tema que prefieres. La selección se guarda '
                      'localmente.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: DimensionesApp.espacio16),
                    Wrap(
                      spacing: DimensionesApp.espacio8,
                      runSpacing: DimensionesApp.espacio8,
                      children: [
                        for (final modo in ModoApariencia.values)
                          ChoiceChip(
                            label: Text(modo.etiqueta),
                            selected: estadoApariencia.modo == modo,
                            onSelected: _guardandoApariencia
                                ? null
                                : (_) => _cambiarApariencia(modo),
                          ),
                      ],
                    ),
                    if (_guardandoApariencia) ...[
                      const SizedBox(height: DimensionesApp.espacio12),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: DimensionesApp.espacio12),
                    Text(
                      estadoApariencia.modo == ModoApariencia.sistema
                          ? 'Destino+ seguirá el modo claro u oscuro '
                              'configurado en tu dispositivo.'
                          : 'Modo ${estadoApariencia.modo.etiqueta} '
                              'seleccionado.',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio12),
              const TarjetaInformativa(
                icono: Icons.storage_outlined,
                titulo: 'Preferencias locales',
                child: Text(
                  'La apariencia se guarda en este dispositivo. Tus viajes '
                  'y actividades continúan almacenándose de forma segura '
                  'en Supabase.',
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio24),
              BotonAccion(
                texto:
                    _cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar sesión',
                icono: _cerrandoSesion ? null : Icons.logout_rounded,
                onPressed: _cerrandoSesion ? null : _cerrarSesion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
