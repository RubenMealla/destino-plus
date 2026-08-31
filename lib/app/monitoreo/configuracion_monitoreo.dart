/// Configuración de monitoreo obtenida mediante `--dart-define`.
///
/// El repositorio no contiene el DSN real de Destino+. La configuración
/// específica de cada entorno se proporciona al ejecutar o compilar la app.
class ConfiguracionMonitoreo {
  const ConfiguracionMonitoreo({
    required this.dsn,
    required this.entorno,
    this.eventoPruebaSolicitado = false,
  });

  factory ConfiguracionMonitoreo.desdeEntorno() {
    return const ConfiguracionMonitoreo(
      dsn: String.fromEnvironment('SENTRY_DSN'),
      entorno: String.fromEnvironment(
        'SENTRY_ENVIRONMENT',
        defaultValue: 'development',
      ),
      eventoPruebaSolicitado: bool.fromEnvironment(
        'SENTRY_TEST_EVENT',
        defaultValue: false,
      ),
    );
  }

  final String dsn;
  final String entorno;
  final bool eventoPruebaSolicitado;

  /// El monitoreo remoto solo se activa cuando existe un DSN configurado.
  bool get habilitado => dsn.trim().isNotEmpty;

  /// Entorno normalizado para evitar nombres vacíos en Sentry.
  String get entornoNormalizado {
    final valor = entorno.trim();
    return valor.isEmpty ? 'development' : valor;
  }

  /// El evento de verificación está bloqueado en producción.
  ///
  /// Deben cumplirse simultáneamente:
  /// - existir un DSN;
  /// - haberse solicitado explícitamente mediante `SENTRY_TEST_EVENT=true`;
  /// - utilizar un entorno distinto de `production`.
  bool get permiteEventoPrueba =>
      habilitado &&
      eventoPruebaSolicitado &&
      entornoNormalizado.toLowerCase() != 'production';
}
