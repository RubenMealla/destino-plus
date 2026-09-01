# Destino+

Destino+ es una aplicación Flutter para planificar y organizar viajes personales desde un solo lugar.

> **Organiza tu destino. Disfruta el camino.**

Permite gestionar viajes e itinerarios, consultar clima real, usar la ubicación actual, personalizar la apariencia y conservar consultas meteorológicas recientes.

## Estado del proyecto

La funcionalidad principal se encuentra implementada y validada.

Versión preparada para distribución:

```text
1.0.1+2
```

En la validación de cierre de esta versión:

- `flutter analyze` finalizó sin errores;
- la suite completa ejecutó 136 pruebas automatizadas correctamente;
- los flujos principales fueron probados manualmente;
- se comprobó creación y edición de viajes, actividades, clima, geolocalización, navegación y persistencia local.

Los binarios APK/AAB no se almacenan en el historial Git. Para una entrega o distribución pueden adjuntarse a una GitHub Release.

## 📱 Probar Destino+ sin instalar Flutter

La forma más sencilla para un evaluador o usuario es instalar el APK de Release correspondiente a la versión publicada.

1. Descarga `DestinoPlus-1.0.1.apk` desde los artefactos de entrega o desde la sección **Releases** del repositorio.
2. Copia el APK a un dispositivo Android.
3. Si Android lo solicita, autoriza temporalmente la instalación desde esa fuente.
4. Abre el APK y confirma la instalación.
5. Inicia Destino+.

Para actualizar una instalación anterior mediante ADB conservando sus datos:

```powershell
adb install -r ".\DestinoPlus-1.0.1.apk"
```

La opción `-r` reinstala/actualiza la misma aplicación conservando los datos cuando la firma y el `applicationId` son compatibles.

## Problema que resuelve

Planificar un viaje suele implicar separar información entre notas, aplicaciones del clima, listas y calendarios. Destino+ centraliza en una sola aplicación:

- datos principales del viaje;
- fechas;
- destino;
- actividades del itinerario;
- estado pendiente/completado;
- clima del destino;
- consultas meteorológicas recientes;
- ubicación actual;
- preferencias de visualización.

## Funcionalidades principales

### Autenticación

- registro de usuarios;
- inicio de sesión;
- sesión persistente mediante Supabase;
- rutas protegidas;
- cierre de sesión;
- validación de formularios.

### Inicio

La pantalla Inicio utiliza información real de la aplicación:

- hasta tres próximos viajes;
- acceso a la lista completa de viajes;
- hasta tres consultas meteorológicas recientes;
- actualización inmediata después de consultar un clima;
- persistencia local de los climas recientes entre reinicios;
- estados vacíos cuando todavía no existen viajes o consultas.

Los viajes siguen teniendo a Supabase como fuente de verdad. Los climas recientes son una comodidad local y no sustituyen el pronóstico en tiempo real.

### Viajes

El usuario puede:

- crear;
- listar;
- consultar detalle;
- editar;
- eliminar viajes.

Cada viaje contiene:

- título;
- destino;
- fecha de inicio;
- fecha de fin;
- descripción opcional.

La selección de fechas se realiza mediante calendario:

- un viaje nuevo comienza como mínimo en la fecha actual;
- la fecha final no puede ser anterior a la inicial;
- si se modifica el inicio por delante del fin, el fin se ajusta de forma coherente;
- la edición contempla viajes históricos existentes;
- no se permite modificar el rango si dejaría actividades existentes fuera del viaje.

### Selección de destino

Destino+ reutiliza un selector de destinos basado en el servicio de geocodificación de Open-Meteo.

Características:

- comienza a buscar desde dos caracteres;
- utiliza un debounce aproximado de 350 ms;
- muestra sugerencias de ubicación;
- utiliza nombres legibles como `Tarija, Bolivia`;
- guarda el destino como texto, por lo que no requiere una migración adicional de base de datos.

El selector se utiliza tanto en el formulario de viaje como en **Explorar**.

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
- solo pueden usar fechas comprendidas entre el inicio y el fin del viaje.

La fecha de la actividad se selecciona mediante un calendario limitado al rango del viaje.

### Clima

Destino+ consume Open-Meteo para mostrar:

- temperatura actual;
- sensación térmica;
- humedad;
- velocidad del viento;
- condición meteorológica;
- pronóstico de hasta siete días;
- temperaturas máximas y mínimas;
- probabilidad de precipitación.

En **Explorar**, al seleccionar una sugerencia del autocompletado se reutilizan sus coordenadas exactas para consultar el pronóstico, evitando una geocodificación textual innecesaria.

### Geolocalización

El usuario puede pulsar **Usar mi ubicación** para:

1. solicitar la ubicación actual;
2. obtener latitud y longitud;
3. consultar Open-Meteo con esas coordenadas;
4. mostrar el clima correspondiente.

Se contemplan:

- permiso denegado;
- permiso bloqueado permanentemente;
- servicio de ubicación desactivado;
- tiempo de espera agotado;
- ubicación no disponible.

Destino+ no solicita ubicación en segundo plano.

### Preferencias locales

Mediante `shared_preferences` se conservan:

- apariencia: Sistema, Claro u Oscuro;
- unidad de temperatura: Celsius o Fahrenheit;
- consultas meteorológicas recientes.

### Monitoreo

Destino+ integra Sentry para monitoreo de errores.

La configuración contempla:

- `SENTRY_DSN`;
- separación de entornos;
- funcionamiento sin Sentry cuando no se configura DSN;
- `sendDefaultPii = false`;
- capturas de pantalla deshabilitadas;
- jerarquía visual deshabilitada;
- evento controlado de verificación fuera de `production`.

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
| HTTP | `http` |
| Geolocalización | Geolocator |
| Monitoreo | Sentry |
| Control de versiones | Git / GitHub |

## Entorno utilizado

El proyecto fue validado con:

```text
Flutter 3.47.2
Dart 3.13.2
Windows 10
```

El SDK declarado en `pubspec.yaml` es:

```yaml
environment:
  sdk: ^3.13.2
```

## Persistencia y flujo de datos

| Información | Fuente / persistencia |
| --- | --- |
| Usuario y sesión | Supabase Auth |
| Viajes | Supabase PostgreSQL |
| Actividades | Supabase PostgreSQL |
| Apariencia | SharedPreferences |
| Unidad de temperatura | SharedPreferences |
| Climas recientes | SharedPreferences |
| Clima actual/pronóstico | Open-Meteo |
| Ubicación actual | Geolocator, uso puntual |
| Eventos de monitoreo | Sentry cuando está configurado |

## Arquitectura general

El código se organiza principalmente por funcionalidades:

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

Otros directorios importantes:

```text
test/                 pruebas automatizadas
docs/                 documentación técnica
supabase/migrations/  migraciones de base de datos
evidencias/           evidencias de validación
config/               ejemplos y configuración local
android/              proyecto Android
```

## Requisitos para desarrollo

Se necesita:

- Git;
- Flutter compatible con el proyecto;
- Dart incluido con Flutter;
- Chrome para ejecución web;
- Android SDK para compilación Android;
- dispositivo Android o emulador para pruebas Android;
- conexión a Internet para Supabase y Open-Meteo.

Comprobar el entorno:

```powershell
flutter --version
flutter doctor -v
git --version
```

## Instalación para desarrolladores

Clonar:

```powershell
git clone https://github.com/RubenMealla/destino-plus.git
cd destino-plus
```

Instalar dependencias:

```powershell
flutter pub get
```

## Configuración de Supabase

El repositorio incluye:

```text
config/supabase.example.json
```

Crear localmente:

```text
config/supabase.local.json
```

con las variables públicas necesarias para el cliente Flutter.

El archivo real está protegido mediante:

```gitignore
config/*.local.json
```

Nunca deben publicarse:

- contraseñas;
- claves `service_role`;
- claves privadas;
- tokens administrativos;
- `android/key.properties`;
- archivos `.jks` o `.keystore`.

## Configuración de Sentry

Ejemplo versionado:

```text
config/monitoreo.example.json
```

Configuración local:

```text
config/monitoreo.local.json
```

La aplicación puede ejecutarse sin Sentry si no se proporciona un DSN.

Para un Release productivo, `SENTRY_ENVIRONMENT` debe corresponder al entorno de producción y el evento de prueba debe permanecer desactivado.

## Ejecutar la aplicación

Sin Sentry:

```powershell
flutter run -d chrome --dart-define-from-file=config/supabase.local.json
```

Con Sentry:

```powershell
flutter run -d chrome `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

## Base de datos

Las migraciones están en:

```text
supabase/migrations/
```

Entidades principales:

```text
viajes
actividades_viaje
```

Se utilizan políticas Row Level Security (RLS) para restringir el acceso a los datos del usuario autenticado.

## API Open-Meteo

Se utiliza para:

- geocodificación/autocompletado de destinos;
- condiciones meteorológicas actuales;
- pronóstico.

No requiere almacenar una API key privada en el proyecto.

## Permisos Android

La aplicación utiliza:

```text
android.permission.INTERNET
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_FINE_LOCATION
```

No solicita:

```text
android.permission.ACCESS_BACKGROUND_LOCATION
```

## Pruebas

Análisis estático:

```powershell
flutter analyze
```

Suite automatizada:

```powershell
flutter test
```

En el cierre de la versión `1.0.1+2` se ejecutaron **136 pruebas automatizadas** y todas finalizaron correctamente.

También se realizaron pruebas manuales de los flujos principales después de los cambios de planificación y destinos.

## Generar APK Release

La configuración de firma Android se mantiene fuera del repositorio.

Con Supabase:

```powershell
flutter build apk --release `
  --dart-define-from-file=config/supabase.local.json
```

Con Supabase y Sentry:

```powershell
flutter build apk --release `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

Salida:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Generar AAB Release

Con Supabase:

```powershell
flutter build appbundle --release `
  --dart-define-from-file=config/supabase.local.json
```

Con Supabase y Sentry:

```powershell
flutter build appbundle --release `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

Salida:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Artefactos de entrega

Los artefactos finales pueden copiarse, sin versionarlos, a:

```text
build/release-artifacts/DestinoPlus-1.0.1.apk
build/release-artifacts/DestinoPlus-1.0.1.aab
```

Se recomienda publicar esos archivos como assets de una GitHub Release `v1.0.1`, en lugar de agregarlos al repositorio.

## Seguridad y privacidad

- los datos de viajes y actividades están protegidos mediante RLS;
- los secretos locales no se versionan;
- no se utiliza `service_role` dentro del cliente Flutter;
- la ubicación se solicita únicamente por acción del usuario;
- no existe seguimiento de ubicación en segundo plano;
- Sentry no envía PII predeterminada;
- las capturas automáticas de Sentry permanecen deshabilitadas.

## Limitaciones conocidas

- requiere conexión a Internet para autenticación, sincronización y clima;
- el pronóstico depende de la disponibilidad de Open-Meteo;
- la precisión de la ubicación depende del dispositivo y sus permisos;
- los climas recientes son un caché local informativo y pueden representar una consulta anterior hasta que el usuario vuelva a consultar el destino;
- el proyecto no incluye datos de mapas ni navegación GPS paso a paso.

## Evidencias

Las evidencias del proyecto se organizan en:

```text
evidencias/
```

La trazabilidad académica sigue el esquema:

```text
requisito → código → prueba → evidencia → conclusión
```

## Git y repositorio

Repositorio:

```text
https://github.com/RubenMealla/destino-plus
```

Rama estable:

```text
main
```

Las funcionalidades se desarrollan en ramas específicas y se integran mediante Pull Request.

## Versión

Versión actual:

```text
1.0.1+2
```

En Android:

- `1.0.1` corresponde al `versionName`;
- `2` corresponde al `versionCode`.

El `applicationId` se mantiene sin cambios para conservar compatibilidad con instalaciones anteriores.

## Historial de versiones

### 1.0.1+2

- Inicio conectado a próximos viajes reales;
- climas recientes persistentes;
- actualización Inicio ↔ Explorar;
- calendarios para viajes y actividades;
- validación mejorada de rangos;
- soporte de edición histórica;
- selector reutilizable de destinos;
- autocompletado mediante Open-Meteo;
- reutilización de coordenadas seleccionadas en la consulta del clima;
- mejoras de robustez y pruebas.

### 1.0.0+1

Primera versión Release funcional de Destino+.

## Autor

Proyecto académico individual nombre: Ruben Dario Mealla Lerma

Repositorio mantenido por **RubenMealla**.

## Licencia

Proyecto académico. La licencia de distribución definitiva puede definirse según el uso futuro del proyecto.
