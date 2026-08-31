import 'package:flutter/material.dart';

import 'app/config/configuracion_supabase.dart';
import 'app/destino_plus_app.dart';
import 'app/monitoreo/configuracion_monitoreo.dart';
import 'app/monitoreo/inicializador_monitoreo.dart';
import 'app/preferencias/estado_apariencia.dart';
import 'app/preferencias/estado_unidades.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configuracionMonitoreo =
      ConfiguracionMonitoreo.desdeEntorno();

  await InicializadorMonitoreo(
    configuracion: configuracionMonitoreo,
  ).iniciar(_iniciarAplicacion);
}

Future<void> _iniciarAplicacion() async {
  await ConfiguracionSupabase.inicializar();
  await EstadoApariencia.instancia.cargar();
  await EstadoUnidades.instancia.cargar();

  runApp(const DestinoPlusApp());
}
