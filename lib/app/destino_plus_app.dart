import 'package:flutter/material.dart';

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
      home: const _VistaTemporal(),
    );
  }
}

class _VistaTemporal extends StatelessWidget {
  const _VistaTemporal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Destino+',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
