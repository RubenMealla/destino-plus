import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/presentacion/pantalla_presentacion.dart';
import '../../shared/widgets/navegacion_principal.dart';
import 'pantalla_ruta_temporal.dart';
import 'rutas_app.dart';

/// Configuración declarativa y centralizada de navegación de Destino+.
///
/// La navegación principal utiliza un contenedor persistente con cuatro
/// destinos móviles: Inicio, Viajes, Explorar y Perfil.
abstract final class RouterApp {
  static final GoRouter router = GoRouter(
    initialLocation: RutasApp.inicio,
    routes: [
      GoRoute(
        path: RutasApp.raiz,
        redirect: (_, __) => RutasApp.inicio,
      ),
      GoRoute(
        path: RutasApp.presentacion,
        builder: (context, state) => const PantallaPresentacion(),
      ),
      GoRoute(
        path: RutasApp.inicioSesion,
        builder: (context, state) => const PantallaRutaTemporal(
          titulo: 'Inicio de sesión',
          descripcion:
              'El acceso de usuarios se implementará en la etapa de autenticación.',
        ),
      ),
      GoRoute(
        path: RutasApp.registro,
        builder: (context, state) => const PantallaRutaTemporal(
          titulo: 'Registro',
          descripcion:
              'El registro de usuarios se implementará en la etapa de autenticación.',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavegacionPrincipal(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RutasApp.inicio,
                builder: (context, state) => const PantallaRutaTemporal(
                  titulo: 'Inicio',
                  descripcion:
                      'El panel principal se incorporará durante la estructura de pantallas.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RutasApp.viajes,
                builder: (context, state) => const PantallaRutaTemporal(
                  titulo: 'Viajes',
                  descripcion:
                      'La gestión de viajes se implementará en la etapa del CRUD.',
                ),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const PantallaRutaTemporal(
                      titulo: 'Nuevo viaje',
                      descripcion:
                          'El formulario de viajes se implementará en la etapa del CRUD.',
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';

                      return PantallaRutaTemporal(
                        titulo: 'Detalle del viaje',
                        descripcion:
                            'Detalle provisional del viaje $id. Su contenido real se '
                            'implementará en la etapa del CRUD.',
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';

                          return PantallaRutaTemporal(
                            titulo: 'Editar viaje',
                            descripcion:
                                'Edición provisional del viaje $id. El formulario real se '
                                'implementará en la etapa del CRUD.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RutasApp.explorar,
                builder: (context, state) => const PantallaRutaTemporal(
                  titulo: 'Explorar',
                  descripcion:
                      'Esta sección reunirá información útil asociada a los destinos.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RutasApp.perfil,
                builder: (context, state) => const PantallaRutaTemporal(
                  titulo: 'Perfil',
                  descripcion:
                      'El perfil y los ajustes se implementarán en su etapa funcional.',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Ruta no disponible')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No se pudo encontrar la pantalla solicitada.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  const RouterApp._();
}
