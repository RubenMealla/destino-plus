import 'package:flutter/material.dart';

import 'router/router_app.dart';
import 'theme/tema_app.dart';

class DestinoPlusApp extends StatelessWidget {
  const DestinoPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Destino+',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      themeMode: ThemeMode.system,
      routerConfig: RouterApp.router,
    );
  }
}
