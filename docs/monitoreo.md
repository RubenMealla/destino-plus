# Monitoreo de errores de Destino+

Destino+ utilizará Sentry para monitorear errores no controlados de la
aplicación.

## Motivo de la elección

Sentry dispone de SDK oficial para Flutter y permite trabajar con Android y
Web. En Android también puede capturar errores de la capa nativa mediante los
SDK incluidos por `sentry_flutter`.

El monitoreo se mantendrá desacoplado de las funciones principales de
Destino+. Si no existe configuración de Sentry, la aplicación debe poder
iniciar y funcionar normalmente.

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

El archivo local no debe incorporarse al repositorio.

Contenido esperado:

```json
{
  "SENTRY_DSN": "DSN_DEL_PROYECTO",
  "SENTRY_ENVIRONMENT": "development"
}
```

`ConfiguracionMonitoreo` considera el monitoreo deshabilitado cuando
`SENTRY_DSN` está vacío. Esto permite ejecutar tests y desarrollar la
aplicación sin depender de una cuenta externa.

## DSN y credenciales

El DSN es la clave de cliente que permite que la aplicación envíe eventos al
proyecto de Sentry. Aunque está diseñado para utilizarse desde aplicaciones
cliente, Destino+ no versionará el DSN real para evitar acoplar el repositorio
académico a una cuenta concreta.

Nunca deben utilizarse en Flutter:

```text
SENTRY_AUTH_TOKEN
tokens de administración
credenciales de cuenta
claves privadas
```

Los tokens administrativos solo serían necesarios para tareas externas como
CI/CD o carga automatizada de símbolos y no forman parte de la aplicación
cliente.

## Entornos

Durante desarrollo:

```text
SENTRY_ENVIRONMENT=development
```

Para el APK/AAB final:

```text
SENTRY_ENVIRONMENT=production
```

Esto permitirá diferenciar errores de pruebas de los errores correspondientes
a la versión entregada.

## Integración prevista

La rama `feature/monitoring` se divide en tres etapas:

```text
1. configuración segura y comprobable;
2. integración de sentry_flutter y captura global de errores;
3. evento de verificación controlado, documentación y evidencia real.
```

La segunda etapa debe proteger el inicio de la app para que una ausencia de
DSN no rompa Destino+.

## Privacidad

El monitoreo debe centrarse en información técnica necesaria para diagnosticar
errores.

No se enviarán deliberadamente:

- contraseñas;
- configuración local de Supabase;
- tokens de sesión;
- coordenadas GPS como datos personalizados;
- contenido de viajes o actividades como información adicional de errores.

Antes del release se revisará la configuración final de Sentry y la evidencia
del dashboard.

## Evidencia final

La evidencia de monitoreo solo se considerará válida cuando:

1. exista un proyecto real de Sentry;
2. Destino+ envíe un evento controlado;
3. el evento aparezca en el dashboard;
4. se guarde una captura real en:

```text
evidencias/08_monitoreo/
```

No se simularán eventos ni capturas para completar la documentación.
