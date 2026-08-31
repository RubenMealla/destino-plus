import 'package:destino_plus/app/config/configuracion_supabase.dart';
import 'package:destino_plus/features/auth/servicios/servicio_autenticacion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la configuración detecta la ausencia de dart-define en pruebas', () {
    expect(ConfiguracionSupabase.tieneConfiguracion, isFalse);
    expect(ConfiguracionSupabase.inicializado, isFalse);
  });

  test(
    'el servicio informa cuando Supabase no fue inicializado',
    () async {
      expect(
        ServicioAutenticacion.instancia.iniciarSesion(
          correo: 'usuario@ejemplo.com',
          clave: '123456',
        ),
        throwsA(
          isA<ExcepcionAutenticacion>().having(
            (error) => error.mensaje,
            'mensaje',
            contains('Supabase todavía no está configurado'),
          ),
        ),
      );
    },
  );
}
