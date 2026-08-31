# Configuración de Supabase en Destino+

Destino+ utiliza Supabase para la autenticación de usuarios.

Esta configuración corresponde al entorno de desarrollo. No deben escribirse
claves privadas ni credenciales administrativas dentro del código fuente.

## 1. Crear el proyecto

1. Crear un proyecto en Supabase.
2. Esperar a que el proyecto termine de inicializarse.
3. Verificar que el proveedor de autenticación por correo electrónico esté habilitado.

## 2. Obtener los datos públicos del cliente

Desde el panel del proyecto, obtener:

- URL del proyecto;
- clave pública `publishable`.

La aplicación cliente NO debe utilizar:

- `service_role`;
- claves secretas;
- contraseñas de base de datos;
- credenciales administrativas.

## 3. Ejecutar Destino+ con la configuración

PowerShell:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL="https://TU-PROYECTO.supabase.co" --dart-define=SUPABASE_PUBLISHABLE_KEY="TU_CLAVE_PUBLICA"
```

La misma estrategia se podrá utilizar posteriormente en Android.

## 4. Confirmación de correo

Supabase puede requerir confirmación de correo después del registro.

Si la confirmación está habilitada:

1. el usuario crea su cuenta;
2. Supabase envía el mensaje de confirmación;
3. el usuario confirma su correo;
4. después puede iniciar sesión.

Destino+ detecta este caso y muestra una indicación en español.

## 5. Seguridad

La clave `publishable` está diseñada por Supabase para aplicaciones cliente.
La seguridad de los datos no debe depender de ocultar esta clave.

Cuando se implemente la base de datos se deberán configurar políticas de
Row Level Security (RLS) apropiadas para cada tabla.

Nunca debe usarse una clave `service_role` dentro de Flutter.

## 6. Desarrollo sin configuración

Si `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY` no están definidos, la
aplicación puede iniciar para continuar con el desarrollo visual, pero las
operaciones reales de inicio de sesión y registro mostrarán que Supabase
todavía no está configurado.
