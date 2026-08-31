/// Configuración de monitoreo obtenida mediante `--dart-define`.
///
/// El repositorio no contiene el DSN real de Destino+. La configuración
/// específica de cada entorno se proporciona al ejecutar o compilar la app.
class ConfiguracionMonitoreo {
  const ConfiguracionMonitoreo({
    required this.dsn,
    required this.entorno,
  });

  factory ConfiguracionMonitoreo.desdeEntorno() {
    return const ConfiguracionMonitoreo(
      dsn: String.fromEnvironment('SENTRY_DSN'),
      entorno: String.fromEnvironment(
        'SENTRY_ENVIRONMENT',
        defaultValue: 'development',
      ),
    );
  }

  final String dsn;
  final String entorno;

  /// El monitoreo remoto solo se activa cuando existe un DSN configurado.
  bool get habilitado => dsn.trim().isNotEmpty;

  /// Entorno normalizado para evitar nombres vacíos en Sentry.
  String get entornoNormalizado {
    final valor = entorno.trim();
    return valor.isEmpty ? 'development' : valor;
  }
}
