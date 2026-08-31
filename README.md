# Destino+

**Destino+** es una aplicación desarrollada con Flutter para planificar y
organizar viajes personales desde un solo lugar.

> **Organiza tu destino. Disfruta el camino.**

El proyecto integra autenticación, planificación de viajes, actividades,
consulta meteorológica, geolocalización, preferencias locales y monitoreo de
errores.

## Estado del proyecto

La funcionalidad principal de Destino+ se encuentra implementada y cuenta con
pruebas automatizadas.

La fase Android Release todavía debe completarse antes de la entrega final:

- validación real en Android;
- prueba de permisos de ubicación en Android;
- APK Release;
- instalación del APK fuera del IDE;
- configuración de firma;
- AAB firmado;
- evidencias finales de release.

La documentación de pruebas y evidencias se encuentra en:

```text
docs/pruebas/
```

## Funcionalidades principales

### Autenticación

- registro de usuarios;
- inicio de sesión;
- sesión persistente mediante Supabase;
- rutas protegidas;
- cierre de sesión;
- validaciones de formularios.

### Viajes

- crear viajes;
- listar viajes;
- consultar detalle;
- editar viajes;
- eliminar viajes;
- título, destino, fechas y descripción;
- validación de rangos de fechas.

Los viajes pertenecen al usuario autenticado.

### Actividades e itinerario

Cada viaje puede contener actividades con:

- título;
- fecha;
- hora opcional;
- lugar opcional;
- notas opcionales;
- estado pendiente/completado.

Las actividades:

- pueden crearse;
- editarse;
- eliminarse;
- marcarse como completadas;
- se agrupan cronológicamente por día;
- deben estar dentro del rango de fechas del viaje.

### Clima

Destino+ consume **Open-Meteo** para mostrar:

- temperatura actual;
- sensación térmica;
- humedad;
- velocidad del viento;
- condición meteorológica;
- pronóstico de hasta 7 días;
- temperaturas máximas y mínimas;
- probabilidad de precipitación.

La búsqueda puede realizarse escribiendo un destino.

### Geolocalización

El usuario puede pulsar:

```text
Usar mi ubicación
```

para:

1. solicitar la ubicación actual;
2. obtener latitud y longitud;
3. consultar Open-Meteo con esas coordenadas;
4. mostrar el clima correspondiente.

La aplicación maneja estados como:

- permiso denegado;
- permiso bloqueado permanentemente;
- servicio de ubicación desactivado;
- tiempo de espera agotado;
- ubicación no disponible.

Destino+ no solicita ubicación en segundo plano.

### Preferencias locales

Mediante `shared_preferences` se conservan:

- apariencia;
- unidad de temperatura.

Apariencia disponible:

```text
Sistema
Claro
Oscuro
```

Unidad de temperatura:

```text
Celsius (°C)
Fahrenheit (°F)
```

Los viajes y actividades no se almacenan en preferencias locales: su fuente
de verdad es Supabase.

### Monitoreo

Destino+ integra **Sentry** para monitoreo de errores.

Características de la configuración actual:

- activación mediante `SENTRY_DSN`;
- separación de entornos;
- funcionamiento normal cuando Sentry no está configurado;
- captura global mediante `sentry_flutter`;
- `sendDefaultPii = false`;
- capturas de pantalla deshabilitadas;
- jerarquía visual deshabilitada;
- monitoreo de rendimiento deshabilitado para el alcance actual;
- evento controlado de verificación disponible solo fuera de `production`.

La integración real fue validada enviando un evento desde Destino+ a un
proyecto Sentry.

Detalles:

```text
docs/monitoreo.md
```

## Tecnologías

| Área | Tecnología |
| --- | --- |
| Aplicación | Flutter / Dart |
| UI | Material 3 |
| Navegación | GoRouter |
| Estado global | Provider |
| Backend | Supabase |
| Autenticación | Supabase Auth |
| Base de datos | PostgreSQL / Supabase |
| Persistencia local | SharedPreferences |
| API pública | Open-Meteo |
| HTTP | paquete `http` |
| Geolocalización | Geolocator |
| Monitoreo | Sentry |
| Control de versiones | Git / GitHub |

## Arquitectura general

El proyecto utiliza una estructura orientada por funcionalidades.

```text
lib/
├── app/
│   ├── config/
│   ├── monitoreo/
│   ├── preferencias/
│   ├── router/
│   └── theme/
├── features/
│   ├── actividades/
│   ├── auth/
│   ├── clima/
│   ├── explorar/
│   ├── inicio/
│   ├── perfil/
│   ├── ubicacion/
│   └── viajes/
└── shared/
    └── widgets/
```

Además:

```text
test/                 pruebas automatizadas
docs/                 documentación técnica
supabase/migrations/  migraciones de base de datos
evidencias/           evidencias reales de validación
config/               ejemplos y configuración local ignorada por Git
android/              proyecto Android generado por Flutter
```

La interfaz depende de contratos y servicios propios cuando es conveniente,
lo que permite sustituir implementaciones reales por fakes durante las
pruebas.

## Requisitos de desarrollo

Para trabajar con el proyecto se necesita:

- Git;
- Flutter compatible con el proyecto;
- Dart incluido con Flutter;
- Chrome para pruebas web durante desarrollo;
- Android SDK y un dispositivo/emulador para la validación Android final.

Comprobar el entorno:

```powershell
flutter --version
flutter doctor -v
git --version
```

## Clonar el repositorio

```powershell
git clone https://github.com/RubenMealla/destino-plus.git
cd destino-plus
flutter pub get
```

## Configuración de Supabase

Destino+ no almacena la configuración local real de Supabase en Git.

Existe una configuración local esperada:

```text
config/supabase.local.json
```

La regla:

```text
config/*.local.json
```

impide que los archivos locales se versionen.

El archivo debe proporcionar las variables requeridas por la configuración de
Supabase del proyecto.

No deben incorporarse al repositorio:

- contraseñas;
- `service_role`;
- claves privadas;
- tokens administrativos.

## Configuración de Sentry

Ejemplo versionado:

```text
config/monitoreo.example.json
```

Para una configuración local crear:

```text
config/monitoreo.local.json
```

con una estructura equivalente a:

```json
{
  "SENTRY_DSN": "DSN_DEL_PROYECTO",
  "SENTRY_ENVIRONMENT": "development",
  "SENTRY_TEST_EVENT": false
}
```

El DSN real no se versiona en este repositorio.

El evento controlado:

```text
SENTRY_TEST_EVENT=true
```

se utiliza únicamente para verificar la integración en un entorno distinto de
`production`.

## Ejecutar durante desarrollo

### Sin Sentry

```powershell
flutter run -d chrome --dart-define-from-file=config/supabase.local.json
```

### Con Sentry

```powershell
flutter run -d chrome `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

La ausencia de un DSN de Sentry no debe impedir que Destino+ se ejecute.

## Base de datos

La persistencia principal utiliza Supabase.

Las migraciones se encuentran en:

```text
supabase/migrations/
```

Entidades principales:

```text
viajes
actividades_viaje
```

Se utilizan políticas **Row Level Security (RLS)** para restringir el acceso a
los datos del usuario correspondiente.

También existe validación de fechas de actividades para reforzar en la base de
datos que una actividad pertenezca al intervalo de su viaje.

## API Open-Meteo

Destino+ utiliza servicios de Open-Meteo para:

```text
geocodificación de destinos
pronóstico meteorológico
```

No se necesita almacenar una API key privada para esta integración.

La documentación específica se encuentra en:

```text
docs/open_meteo.md
```

## Permisos Android

El manifest principal utiliza los permisos necesarios para las funciones
actuales:

```text
android.permission.INTERNET
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_FINE_LOCATION
```

No se utiliza:

```text
android.permission.ACCESS_BACKGROUND_LOCATION
```

La prueba definitiva de estos permisos debe realizarse en Android durante la
fase de release.

## Pruebas

Ejecutar análisis estático:

```powershell
flutter analyze
```

Ejecutar la suite automatizada:

```powershell
flutter test
```

La suite cubre áreas como:

- autenticación;
- navegación;
- viajes;
- actividades;
- itinerario;
- validaciones;
- preferencias locales;
- apariencia;
- unidades;
- Open-Meteo;
- geolocalización;
- integración ubicación + clima;
- estados de error;
- monitoreo.

No se fija en este README una cantidad concreta de tests porque puede cambiar
durante el desarrollo. La cifra válida es la informada por la ejecución final
real de `flutter test`.

## Documentación de pruebas

Matriz funcional:

```text
docs/pruebas/matriz_pruebas_funcionales.md
```

Plan de evidencias:

```text
docs/pruebas/plan_evidencias.md
```

Trazabilidad:

```text
docs/pruebas/trazabilidad_requisitos.md
```

La documentación sigue el esquema:

```text
requisito
   ↓
implementación
   ↓
prueba
   ↓
evidencia
   ↓
conclusión
```

No deben marcarse como aprobadas pruebas que no hayan sido ejecutadas.

## Git y flujo de trabajo

El desarrollo utiliza:

```text
main
feature/*
fix/*
test/*
docs/*
```

Las funcionalidades se trabajan en ramas específicas y se integran a `main`
mediante Pull Requests.

Las ramas fusionadas pueden conservarse como parte del historial académico del
proyecto.

Comandos útiles:

```powershell
git status
git --no-pager diff --check
git --no-pager log --oneline --decorate --graph --all
```

Antes de commits importantes se recomienda revisar únicamente los archivos
que realmente se desean versionar.

## Evidencias

Las evidencias reales se organizan bajo:

```text
evidencias/
```

Plan:

```text
01_entorno/
02_autenticacion/
03_navegacion/
04_viajes_actividades/
05_integraciones/
06_pruebas/
07_release_android/
08_monitoreo/
```

No deben incorporarse secretos ni evidencias fabricadas.

## Release Android pendiente

La fase final incluirá, una vez configurado correctamente el entorno Android:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run --release
flutter build apk --release
flutter build appbundle
```

También deberá comprobarse:

- ejecución en Android;
- permisos reales de ubicación;
- instalación del APK Release fuera del IDE;
- firma del bundle;
- generación del AAB;
- hashes de los artefactos finales;
- evidencias correspondientes.

Hasta realizar esas acciones no deben declararse como completadas.

## Seguridad y privacidad

Principios aplicados:

- RLS en datos de usuario;
- configuración local excluida de Git;
- ausencia de `service_role` en el cliente;
- ubicación utilizada solo cuando el usuario la solicita;
- sin seguimiento de ubicación en segundo plano;
- Sentry sin PII predeterminada;
- sin capturas automáticas en Sentry;
- sin tokens administrativos dentro de Flutter.

## Propósito académico

Destino+ fue desarrollado como proyecto individual para demostrar la
integración práctica de conceptos de desarrollo móvil con Flutter:

- interfaz;
- navegación;
- autenticación;
- CRUD;
- base de datos;
- API externa;
- persistencia local;
- estado global;
- capacidad nativa;
- manejo de errores;
- pruebas;
- Git;
- documentación;
- monitoreo;
- preparación para distribución Android.

## Licencia

Este repositorio corresponde a un proyecto académico. La incorporación de una
licencia de distribución específica puede definirse según el uso futuro del
proyecto.
