import 'package:flutter/material.dart';

import 'app/config/configuracion_supabase.dart';
import 'app/destino_plus_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConfiguracionSupabase.inicializar();

  runApp(const DestinoPlusApp());
}
