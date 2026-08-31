import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'configuracion_monitoreo.dart';

/// Evento controlado utilizado únicamente para comprobar la integración.
///
/// No genera una excepción ni bloquea la aplicación. Envía un mensaje de
/// nivel `info` identificable en el dashboard de Sentry.
abstract interface class VerificadorMonitoreo {
  Future<void> enviarEventoPrueba(
    ConfiguracionMonitoreo configuracion,
  );
}

class VerificadorMonitoreoSentry implements VerificadorMonitoreo {
  const VerificadorMonitoreoSentry();

  static const String mensaje =
      'Destino+ - evento controlado de verificación de monitoreo';

  @override
  Future<void> enviarEventoPrueba(
    ConfiguracionMonitoreo configuracion,
  ) async {
    final id = await Sentry.captureMessage(
      mensaje,
      level: SentryLevel.info,
      withScope: (scope) {
        scope.setTag('destino_plus.verificacion', 'manual');
        scope.setTag(
          'destino_plus.environment',
          configuracion.entornoNormalizado,
        );
      },
    );

    // Solo se imprime el identificador técnico del evento. No contiene
    // contraseña, token ni información personal del usuario.
    debugPrint(
      'Sentry: evento de verificación enviado. Event ID: $id',
    );
  }
}
