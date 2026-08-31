import 'package:flutter/material.dart';

import 'app/config/configuracion_supabase.dart';
import 'app/destino_plus_app.dart';
import 'app/monitoreo/configuracion_monitoreo.dart';
import 'app/monitoreo/inicializador_monitoreo.dart';
import 'app/preferencias/estado_apariencia.dart';
import 'app/preferencias/estado_unidades.dart';

Future<void> main() async {
  final configuracionMonitoreo =
      ConfiguracionMonitoreo.desdeEntorno();

  await InicializadorMonitoreo(
    configuracion: configuracionMonitoreo,
  ).iniciar(_iniciarAplicacion);
}

Future<void> _iniciarAplicacion() async {
  // Cuando Sentry está habilitado, el SDK prepara el binding y el manejador
  // global antes de ejecutar este callback. Al mantener toda la
  // inicialización de Flutter dentro del mismo flujo evitamos "Zone mismatch"
  // en Flutter Web.
  WidgetsFlutterBinding.ensureInitialized();

  await ConfiguracionSupabase.inicializar();
  await EstadoApariencia.instancia.cargar();
  await EstadoUnidades.instancia.cargar();

  runApp(const DestinoPlusApp());
}
