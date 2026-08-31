import 'package:flutter/material.dart';

import 'app/config/configuracion_supabase.dart';
import 'app/destino_plus_app.dart';
import 'app/preferencias/estado_apariencia.dart';
import 'app/preferencias/estado_unidades.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConfiguracionSupabase.inicializar();
  await EstadoApariencia.instancia.cargar();
  await EstadoUnidades.instancia.cargar();

  runApp(const DestinoPlusApp());
}
