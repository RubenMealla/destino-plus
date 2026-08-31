# Configuración de Supabase en Destino+

Destino+ utiliza Supabase para la autenticación de usuarios.

La configuración se recibe mediante `dart-define`. No deben escribirse claves
privadas ni credenciales administrativas dentro del código fuente.

## Datos necesarios

Desde el panel del proyecto de Supabase se necesitan:

- URL del proyecto;
- clave pública `publishable`.

La aplicación cliente NO debe utilizar:

- `service_role`;
- claves secretas;
- contraseñas de base de datos;
- credenciales administrativas.

## Opción recomendada para desarrollo local

El repositorio incluye:

```text
config/supabase.example.json
```

Crear una copia local:

```powershell
Copy-Item config/supabase.example.json config/supabase.local.json
```

Editar `config/supabase.local.json` con los valores del proyecto:

```json
{
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "TU_CLAVE_PUBLICA"
}
```

`config/supabase.local.json` está ignorado por Git y no debe subirse al
repositorio.

Después, la ejecución habitual queda reducida a:

```powershell
flutter run -d chrome --dart-define-from-file=config/supabase.local.json
```

No es necesario volver a escribir la URL y la clave en cada comando.

## Ejecución con valores escritos en el comando

También sigue siendo válido:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL="https://TU-PROYECTO.supabase.co" --dart-define=SUPABASE_PUBLISHABLE_KEY="TU_CLAVE_PUBLICA"
```

## Confirmación de correo

Supabase puede requerir confirmación de correo después del registro.

Si la confirmación está habilitada:

1. el usuario crea su cuenta;
2. Supabase envía el mensaje de confirmación;
3. el usuario confirma su correo;
4. después puede iniciar sesión.

Destino+ detecta este caso y muestra una indicación en español.

## Estado global y rutas protegidas

La sesión de Supabase se mantiene en un estado global de la aplicación.

Cuando no existe una sesión:

- las rutas principales redirigen al inicio de sesión;
- el usuario puede acceder al registro.

Cuando existe una sesión:

- el usuario puede entrar a Inicio, Viajes, Explorar y Perfil;
- intentar volver al acceso o registro redirige al Inicio;
- la sesión existente puede recuperarse al volver a abrir la aplicación.

Desde Perfil se puede cerrar la sesión.

## Seguridad

La clave `publishable` está diseñada para aplicaciones cliente. La seguridad
de los datos no debe depender de ocultarla.

Aun así, Destino+ mantiene la configuración local fuera del repositorio para
evitar mezclar datos de entornos y conservar una entrega limpia.

Cuando se implemente la base de datos se deberán configurar políticas de
Row Level Security (RLS) apropiadas para cada tabla.

Nunca debe usarse una clave `service_role` dentro de Flutter.

## Desarrollo sin configuración

Si no se proporciona configuración de Supabase, la aplicación puede iniciar
para continuar con revisiones de interfaz, pero no podrá autenticar usuarios
reales.
