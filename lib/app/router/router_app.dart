import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/actividades/pantalla_formulario_actividad.dart';
import '../../features/auth/estado/estado_sesion.dart';
import '../../features/auth/pantalla_inicio_sesion.dart';
import '../../features/auth/pantalla_registro.dart';
import '../../features/explorar/pantalla_explorar.dart';
import '../../features/inicio/pantalla_inicio.dart';
import '../../features/perfil/pantalla_perfil.dart';
import '../../features/presentacion/pantalla_presentacion.dart';
import '../../features/viajes/pantalla_detalle_viaje.dart';
import '../../features/viajes/pantalla_formulario_viaje.dart';
import '../../features/viajes/pantalla_viajes.dart';
import '../../shared/widgets/navegacion_principal.dart';
import 'rutas_app.dart';

/// Configuración declarativa y centralizada de navegación de Destino+.
abstract final class RouterApp {
  static final GoRouter router = crear();

  static GoRouter crear({
    EstadoSesion? estadoSesion,
    bool protegerRutas = true,
    String ubicacionInicial = RutasApp.inicioSesion,
  }) {
    final estado = estadoSesion ?? EstadoSesion.instancia;

    return GoRouter(
      initialLocation: ubicacionInicial,
      refreshListenable: protegerRutas ? estado : null,
      redirect: (context, state) {
        if (!protegerRutas) {
          return null;
        }

        final ubicacion = state.matchedLocation;
        final esRutaAcceso = ubicacion == RutasApp.inicioSesion ||
            ubicacion == RutasApp.registro;
        final esRutaPublica =
            esRutaAcceso || ubicacion == RutasApp.presentacion;

        if (!estado.autenticado && !esRutaPublica) {
          return RutasApp.inicioSesion;
        }

        if (estado.autenticado && esRutaAcceso) {
          return RutasApp.inicio;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RutasApp.raiz,
          redirect: (_, __) => EstadoSesion.instancia.autenticado
              ? RutasApp.inicio
              : RutasApp.inicioSesion,
        ),
        GoRoute(
          path: RutasApp.presentacion,
          builder: (context, state) => const PantallaPresentacion(),
        ),
        GoRoute(
          path: RutasApp.inicioSesion,
          builder: (context, state) => const PantallaInicioSesion(),
        ),
        GoRoute(
          path: RutasApp.registro,
          builder: (context, state) => const PantallaRegistro(),
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
                  builder: (context, state) => const PantallaInicio(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RutasApp.viajes,
                  builder: (context, state) => const PantallaViajes(),
                  routes: [
                    GoRoute(
                      path: 'nuevo',
                      builder: (context, state) =>
                          const PantallaFormularioViaje(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id'] ?? '';

                        return PantallaDetalleViaje(viajeId: id);
                      },
                      routes: [
                        GoRoute(
                          path: 'editar',
                          builder: (context, state) {
                            final id = state.pathParameters['id'] ?? '';

                            return PantallaFormularioViaje(
                              viajeId: id,
                            );
                          },
                        ),
                        GoRoute(
                          path: 'actividades/nueva',
                          builder: (context, state) {
                            final viajeId =
                                state.pathParameters['id'] ?? '';

                            return PantallaFormularioActividad(
                              viajeId: viajeId,
                            );
                          },
                        ),
                        GoRoute(
                          path: 'actividades/:actividadId/editar',
                          builder: (context, state) {
                            final viajeId =
                                state.pathParameters['id'] ?? '';
                            final actividadId =
                                state.pathParameters['actividadId'] ?? '';

                            return PantallaFormularioActividad(
                              viajeId: viajeId,
                              actividadId: actividadId,
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
                  builder: (context, state) => const PantallaExplorar(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RutasApp.perfil,
                  builder: (context, state) => const PantallaPerfil(),
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
  }

  const RouterApp._();
}
