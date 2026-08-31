import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración de Supabase para Destino+.
///
/// Los valores se reciben mediante `--dart-define` para evitar escribir
/// configuraciones de entorno directamente en el código fuente.
///
/// La clave utilizada por la aplicación debe ser la clave pública
/// `publishable` de Supabase. Nunca debe utilizarse `service_role` ni una
/// clave secreta dentro de una aplicación cliente.
abstract final class ConfiguracionSupabase {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String clavePublica = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool _inicializado = false;

  static bool get tieneConfiguracion =>
      url.trim().isNotEmpty && clavePublica.trim().isNotEmpty;

  static bool get inicializado => _inicializado;

  static Future<void> inicializar() async {
    if (!tieneConfiguracion || _inicializado) {
      return;
    }

    await Supabase.initialize(
      url: url,
      publishableKey: clavePublica,
    );

    _inicializado = true;
  }

  const ConfiguracionSupabase._();
}
