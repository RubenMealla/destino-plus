import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../features/auth/estado/estado_sesion.dart';
import '../../features/auth/servicios/servicio_autenticacion.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/tarjeta_informativa.dart';

/// Pantalla inicial del perfil y los ajustes del usuario.
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  bool _cerrandoSesion = false;

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final estadoSesion = context.watch<EstadoSesion>();
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
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                    'Las preferencias se habilitarán cuando exista persistencia local.',
              ),
              const SizedBox(height: DimensionesApp.espacio16),
              const TarjetaInformativa(
                icono: Icons.palette_outlined,
                titulo: 'Apariencia',
                child: Text(
                  'El tema de la aplicación utiliza actualmente la configuración '
                  'del sistema.',
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio12),
              const TarjetaInformativa(
                icono: Icons.settings_outlined,
                titulo: 'Preferencias',
                child: Text(
                  'Las preferencias del usuario se incorporarán en una etapa posterior.',
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio24),
              BotonAccion(
                texto: _cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar sesión',
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
