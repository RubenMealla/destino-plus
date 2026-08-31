# Monitoreo de errores de Destino+

Destino+ utiliza Sentry como integración de monitoreo de errores.

## SDK

Dependencia:

```text
sentry_flutter
```

El SDK oficial para Flutter permite capturar errores de Flutter y también
errores de la capa nativa soportada en Android.

## Configuración

Variables utilizadas:

```text
SENTRY_DSN
SENTRY_ENVIRONMENT
SENTRY_TEST_EVENT
```

Ejemplo versionado:

```text
config/monitoreo.example.json
```

Archivo local:

```text
config/monitoreo.local.json
```

La regla:

```text
config/*.local.json
```

evita que la configuración local termine en Git.

## Arranque con y sin monitoreo

```text
main
  |
  +-- ConfiguracionMonitoreo.desdeEntorno()
  |
  +-- ¿existe SENTRY_DSN?
         |
         +-- no --> iniciar Destino+ normalmente
         |
         +-- sí --> SentryFlutter.init(...)
                        |
                        +-- Supabase
                        +-- preferencias
                        +-- runApp(DestinoPlusApp)
                        |
                        +-- evento de verificación opcional
```

La ausencia del DSN no impide utilizar Destino+.

## Privacidad

La configuración aplicada mantiene:

```text
sendDefaultPii = false
attachScreenshot = false
attachViewHierarchy = false
tracesSampleRate = 0
```

No se adjuntan deliberadamente:

- contraseñas;
- tokens de sesión;
- configuración privada de Supabase;
- coordenadas GPS;
- contenido de viajes;
- contenido de actividades;
- capturas de pantalla;
- jerarquía visual.

## Verificación controlada

La integración incluye un mecanismo explícito para comprobar que Sentry recibe
eventos reales sin provocar un crash artificial.

Se activa únicamente mediante:

```text
SENTRY_TEST_EVENT=true
```

y solo funciona si:

```text
SENTRY_DSN está configurado
SENTRY_ENVIRONMENT no es production
```

En `production` el mecanismo permanece bloqueado aunque se solicite por error.

Mensaje enviado:

```text
Destino+ - evento controlado de verificación de monitoreo
```

Etiquetas:

```text
destino_plus.verificacion = manual
destino_plus.environment = development
```

El evento se envía con nivel:

```text
info
```

Además, la consola muestra el Event ID generado por el SDK.

## Crear el proyecto real en Sentry

Para la evidencia final:

1. crear o iniciar sesión en una cuenta de Sentry;
2. crear un proyecto para Flutter;
3. asignar un nombre reconocible, por ejemplo `destino-plus`;
4. obtener el DSN del proyecto desde su configuración de Client Keys/DSN;
5. crear localmente:

```text
config/monitoreo.local.json
```

con:

```json
{
  "SENTRY_DSN": "DSN_REAL_DEL_PROYECTO",
  "SENTRY_ENVIRONMENT": "development",
  "SENTRY_TEST_EVENT": true
}
```

No copiar el DSN real a documentación versionada.

## Ejecutar la verificación

PowerShell:

```powershell
flutter run -d chrome `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

Después del arranque debe aparecer en consola una línea similar a:

```text
Sentry: evento de verificación enviado. Event ID: ...
```

El identificador real será distinto en cada evento.

En Sentry, buscar el mensaje:

```text
Destino+ - evento controlado de verificación de monitoreo
```

y comprobar que el entorno sea:

```text
development
```

## Después de verificar

Para evitar enviar un evento en cada arranque de desarrollo, cambiar el archivo
local a:

```json
{
  "SENTRY_DSN": "DSN_REAL_DEL_PROYECTO",
  "SENTRY_ENVIRONMENT": "development",
  "SENTRY_TEST_EVENT": false
}
```

El DSN seguirá habilitando captura global de errores, pero ya no se generará el
mensaje de prueba.

## Evidencia

Guardar una captura real del dashboard donde sea visible:

- proyecto Destino+;
- mensaje de verificación;
- entorno `development`;
- fecha/hora del evento.

Ruta prevista:

```text
evidencias/08_monitoreo/01_evento_sentry.png
```

Opcionalmente puede guardarse otra captura de la consola con el Event ID:

```text
evidencias/08_monitoreo/02_event_id_consola.png
```

No incluir en las capturas el contenido de archivos con DSN, tokens o
credenciales.

## Pruebas automatizadas

```text
test/configuracion_monitoreo_test.dart
test/inicializador_monitoreo_test.dart
```

La suite verifica que:

- no haya monitoreo remoto sin DSN;
- el evento sea opt-in;
- solo se envíe un evento controlado;
- production bloquee la verificación;
- la aplicación siga iniciando una sola vez.

Las pruebas automatizadas no realizan conexiones reales a Sentry.

## Estado de cierre

La implementación queda completa cuando:

1. `flutter analyze` pasa;
2. `flutter test` pasa;
3. el evento controlado llega al proyecto real de Sentry;
4. se guarda evidencia real;
5. `SENTRY_TEST_EVENT` vuelve a `false`.

La captura real no debe sustituirse por una imagen simulada.
