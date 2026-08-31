# Monitoreo de errores de Destino+

Destino+ utiliza Sentry como integración de monitoreo de errores.

## SDK

Dependencia:

```text
sentry_flutter
```

El SDK oficial para Flutter permite capturar errores de Flutter y, en Android,
también integra la capa nativa correspondiente.

## Configuración

La aplicación obtiene la configuración mediante `--dart-define`.

Variables:

```text
SENTRY_DSN
SENTRY_ENVIRONMENT
```

Ejemplo versionado:

```text
config/monitoreo.example.json
```

Archivo local previsto:

```text
config/monitoreo.local.json
```

La regla existente:

```text
config/*.local.json
```

impide versionar el archivo local.

## Arranque con y sin monitoreo

El flujo de inicio se encuentra en:

```text
lib/app/monitoreo/inicializador_monitoreo.dart
lib/main.dart
```

Flujo:

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
                        +-- inicializar Supabase
                        +-- cargar preferencias
                        +-- runApp(DestinoPlusApp)
```

De esta forma el proyecto puede:

- ejecutar tests sin una cuenta Sentry;
- desarrollarse sin DSN;
- activar monitoreo mediante configuración externa;
- capturar errores ocurridos durante la inicialización de servicios cuando
  Sentry está habilitado.

## Captura global

`SentryFlutter.init` ejecuta el `appRunner` bajo las integraciones de captura
de errores del SDK.

Destino+ no reemplaza manualmente `FlutterError.onError` ni
`PlatformDispatcher.onError`, porque el SDK oficial ya instala las
integraciones correspondientes.

## Privacidad y alcance

La configuración aplicada establece:

```text
sendDefaultPii = false
attachScreenshot = false
attachViewHierarchy = false
tracesSampleRate = 0
```

El objetivo actual es monitorear errores, no comportamiento del usuario ni
rendimiento.

No se adjuntan deliberadamente:

- capturas de pantalla;
- jerarquía visual;
- coordenadas GPS;
- contraseñas;
- contenido de viajes;
- contenido de actividades;
- tokens o configuración privada de Supabase.

## DSN

El DSN es una credencial de cliente utilizada por el SDK para enviar eventos.

Destino+ no guarda el DSN real en Git. Se proporcionará mediante:

```text
config/monitoreo.local.json
```

Nunca deben introducirse en Flutter:

```text
SENTRY_AUTH_TOKEN
tokens administrativos
claves privadas
```

## Ejecución sin Sentry

La ejecución habitual continúa siendo válida:

```powershell
flutter run -d chrome --dart-define-from-file=config/supabase.local.json
```

En ese caso `SENTRY_DSN` estará vacío y la aplicación arrancará normalmente.

## Ejecución con Sentry

Cuando exista el archivo local, Flutter permite utilizar más de un archivo de
`dart-define` repitiendo la opción correspondiente.

Ejemplo conceptual:

```powershell
flutter run -d chrome `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

La configuración real de Sentry se creará en la siguiente etapa.

## Pruebas automatizadas

```text
test/configuracion_monitoreo_test.dart
test/inicializador_monitoreo_test.dart
```

Las pruebas verifican que:

- un DSN vacío mantenga el monitoreo deshabilitado;
- Destino+ pueda ejecutar su inicialización sin invocar Sentry;
- un DSN configurado active la plataforma de monitoreo;
- la aplicación se ejecute una sola vez;
- el entorno configurado llegue correctamente al adaptador.

Estas pruebas no envían eventos reales a Internet.

## Verificación real pendiente

La integración no se considerará completamente evidenciada hasta:

1. crear un proyecto Flutter real en Sentry;
2. configurar su DSN local;
3. enviar un evento controlado desde Destino+;
4. comprobar su llegada al dashboard;
5. guardar una captura real en:

```text
evidencias/08_monitoreo/
```

La verificación controlada corresponde al siguiente commit de esta rama.
