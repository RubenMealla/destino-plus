import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Configuración común para las pruebas de widgets de Destino+.
///
/// Flutter usa 800x600 por defecto. Varias pantallas móviles son desplazables
/// y sus acciones quedan debajo de 600 px en ese entorno artificial. Se
/// conserva el ancho de 800 px y se amplía solo la altura del área de prueba.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await binding.setSurfaceSize(const Size(800, 1200));
  });

  tearDown(() async {
    await binding.setSurfaceSize(null);
  });

  await testMain();
}
