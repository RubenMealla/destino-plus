import 'package:flutter/material.dart';

import '../features/presentacion/pantalla_presentacion.dart';
import 'theme/tema_app.dart';

class DestinoPlusApp extends StatelessWidget {
  const DestinoPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Destino+',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      themeMode: ThemeMode.system,
      home: const PantallaPresentacion(),
    );
  }
}
