import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/estado/estado_sesion.dart';
import 'preferencias/estado_apariencia.dart';
import 'preferencias/estado_unidades.dart';
import 'router/router_app.dart';
import 'theme/tema_app.dart';

class DestinoPlusApp extends StatelessWidget {
  const DestinoPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EstadoSesion>.value(
          value: EstadoSesion.instancia,
        ),
        ChangeNotifierProvider<EstadoApariencia>.value(
          value: EstadoApariencia.instancia,
        ),
        ChangeNotifierProvider<EstadoUnidades>.value(
          value: EstadoUnidades.instancia,
        ),
      ],
      child: Consumer<EstadoApariencia>(
        builder: (context, apariencia, child) {
          return MaterialApp.router(
            title: 'Destino+',
            debugShowCheckedModeBanner: false,
            theme: TemaApp.claro,
            darkTheme: TemaApp.oscuro,
            themeMode: apariencia.themeMode,
            routerConfig: RouterApp.router,
          );
        },
      ),
    );
  }
}
