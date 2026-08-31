# Instalación, configuración y ejecución de Destino+

Esta guía describe cómo preparar una copia de desarrollo del proyecto sin
versionar credenciales locales.

## 1. Requisitos

Herramientas necesarias:

```text
Git
Flutter
Dart incluido con Flutter
Chrome para desarrollo web
```

Para la fase Android también serán necesarios:

```text
Android SDK
Android Platform Tools
un dispositivo Android o emulador
```

Comprobar las herramientas:

```powershell
git --version
flutter --version
flutter doctor -v
```

El `pubspec.yaml` actual requiere:

```text
Dart ^3.13.2
```

Las versiones exactas de las dependencias del proyecto se encuentran en:

```text
pubspec.yaml
pubspec.lock
```

## 2. Obtener el proyecto

Clonar:

```powershell
git clone https://github.com/RubenMealla/destino-plus.git
cd destino-plus
```

Descargar dependencias:

```powershell
flutter pub get
```

Comprobar inicialmente:

```powershell
flutter analyze
flutter test
```

## 3. Configuración local

Destino+ utiliza archivos JSON con `--dart-define-from-file`.

Los archivos reales del desarrollador terminan en:

```text
.local.json
```

y están excluidos por `.gitignore` mediante:

```text
config/*.local.json
```

Antes de continuar puede comprobarse:

```powershell
Select-String -Path .gitignore -Pattern "config/\*\.local\.json"
```

## 4. Configurar Supabase

Existe un ejemplo:

```text
config/supabase.example.json
```

Crear una copia local:

```text
config/supabase.local.json
```

Contenido:

```json
{
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "TU_CLAVE_PUBLICA"
}
```

Utilizar la clave pública/publishable del proyecto.

No introducir:

```text
service_role
contraseña de base de datos
tokens administrativos
claves secretas
```

La aplicación lee estos valores desde:

```text
lib/app/config/configuracion_supabase.dart
```

Si faltan ambos valores, Supabase no se inicializa.

Las funciones que dependen de autenticación y base de datos necesitan una
configuración válida para utilizarse realmente.

## 5. Configurar Sentry

Existe:

```text
config/monitoreo.example.json
```

Crear:

```text
config/monitoreo.local.json
```

Ejemplo:

```json
{
  "SENTRY_DSN": "DSN_DEL_PROYECTO",
  "SENTRY_ENVIRONMENT": "development",
  "SENTRY_TEST_EVENT": false
}
```

Variables:

```text
SENTRY_DSN
SENTRY_ENVIRONMENT
SENTRY_TEST_EVENT
```

### Sin DSN

Si `SENTRY_DSN` está vacío o el archivo de monitoreo no se proporciona,
Destino+ debe iniciar normalmente sin Sentry remoto.

### Con DSN

Sentry se inicializa antes del resto de la aplicación y captura errores
globales mediante `sentry_flutter`.

### Evento de prueba

Para una comprobación manual temporal:

```json
"SENTRY_TEST_EVENT": true
```

Solo se permite fuera de:

```text
production
```

Después de verificar el evento se debe volver a:

```json
"SENTRY_TEST_EVENT": false
```

No versionar el DSN real.

## 6. Comprobar archivos privados

Antes de cualquier commit:

```powershell
git status --short
```

No deben aparecer:

```text
config/supabase.local.json
config/monitoreo.local.json
android/key.properties
*.jks
*.keystore
```

## 7. Ejecutar en Chrome sin Sentry

Comando habitual de desarrollo:

```powershell
flutter run -d chrome --dart-define-from-file=config/supabase.local.json
```

Esto permite probar:

- autenticación;
- viajes;
- actividades;
- Open-Meteo;
- preferencias;
- navegación.

La geolocalización puede utilizar la implementación web del navegador, pero no
sustituye la validación final de permisos Android.

## 8. Ejecutar en Chrome con Sentry

PowerShell:

```powershell
flutter run -d chrome `
  --dart-define-from-file=config/supabase.local.json `
  --dart-define-from-file=config/monitoreo.local.json
```

Con `SENTRY_TEST_EVENT=false`, no debe enviarse el evento de verificación en
cada arranque.

Los errores reales no controlados pueden seguir siendo reportados por Sentry.

## 9. Flujo esperado al iniciar

Con ambas configuraciones:

```text
Flutter
  │
  ├── Sentry
  ├── Supabase
  ├── preferencias locales
  └── DestinoPlusApp
```

Si Sentry no está configurado:

```text
Flutter
  │
  ├── Supabase
  ├── preferencias locales
  └── DestinoPlusApp
```

## 10. Ejecutar análisis estático

```powershell
flutter analyze
```

El resultado esperado para el cierre es que no existan problemas pendientes.

Durante desarrollo, si aparece un error o warning nuevo, debe corregirse antes
del commit correspondiente salvo que se documente explícitamente otra razón.

## 11. Ejecutar pruebas automatizadas

Suite completa:

```powershell
flutter test
```

Las pruebas no necesitan conexiones reales a Supabase, Open-Meteo,
geolocalización o Sentry cuando utilizan las implementaciones falsas
correspondientes.

Áreas cubiertas:

```text
autenticación
navegación
viajes
actividades
itinerario
preferencias
clima
geolocalización
monitoreo
```

La cantidad exacta de tests debe tomarse de la ejecución final, no escribirse
manualmente por anticipado.

## 12. Ejecutar una prueba específica

Ejemplo:

```powershell
flutter test test/pantalla_explorar_clima_test.dart
```

Otro ejemplo:

```powershell
flutter test test/inicializador_monitoreo_test.dart
```

Esto puede utilizarse durante depuración, pero antes de fusionar cambios debe
ejecutarse nuevamente la suite completa.

## 13. Open-Meteo

No requiere una API key privada.

La aplicación realiza solicitudes HTTP a servicios públicos de Open-Meteo.

Para una prueba manual:

```text
Explorar
→ escribir Tarija, Bolivia
→ Consultar clima
```

También:

```text
Explorar
→ Usar mi ubicación
```

La segunda opción requiere permiso de ubicación.

## 14. Supabase y datos

Las migraciones versionadas se encuentran en:

```text
supabase/migrations/
```

Si se crea un proyecto Supabase nuevo para reproducir completamente el backend,
las migraciones deben aplicarse sobre ese proyecto.

El repositorio no contiene:

```text
contraseña del proyecto Supabase
service_role
secret keys
```

La configuración de backend debe prepararse fuera del código cliente.

## 15. Geolocalización en Android

El manifest principal declara:

```text
android.permission.INTERNET
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_FINE_LOCATION
```

No declara:

```text
android.permission.ACCESS_BACKGROUND_LOCATION
```

Flujo que deberá probarse:

```text
permiso concedido
permiso denegado
permiso bloqueado
servicio de ubicación desactivado
ubicación disponible
```

Estas pruebas quedan para la fase Android final.

## 16. Preparación Android pendiente

Antes de generar el release debe conseguirse un resultado satisfactorio en:

```powershell
flutter doctor -v
```

y verificarse que Flutter detecte el dispositivo:

```powershell
flutter devices
```

Después podrá probarse:

```powershell
flutter run --release
```

La configuración exacta del Android SDK y la firma se documentará en la fase
de release, cuando exista el entorno real configurado.

## 17. Build Android previsto

APK Release:

```powershell
flutter build apk --release
```

Ruta habitual esperada:

```text
build/app/outputs/flutter-apk/app-release.apk
```

AAB:

```powershell
flutter build appbundle
```

Ruta habitual esperada:

```text
build/app/outputs/bundle/release/app.aab
```

Estas rutas deben confirmarse en la ejecución real.

No deben marcarse como artefactos entregados hasta generarlos y probarlos.

## 18. Firma Android

`.gitignore` excluye:

```text
android/key.properties
*.jks
*.keystore
```

Por tanto, la futura firma del release debe mantenerse fuera del repositorio.

Nunca subir:

```text
contraseña del keystore
contraseña de la key
keystore privado
key.properties con secretos
```

## 19. Limpieza antes del release

Procedimiento previsto:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

Después:

```powershell
flutter run --release
flutter build apk --release
flutter build appbundle
```

La instalación del APK debe probarse fuera del IDE.

## 20. Hashes de artefactos

Una vez generados:

```powershell
Get-FileHash build/app/outputs/flutter-apk/app-release.apk -Algorithm SHA256
Get-FileHash build/app/outputs/bundle/release/app.aab -Algorithm SHA256
```

Las salidas reales pueden guardarse dentro de:

```text
evidencias/07_release_android/
```

## 21. Comprobaciones Git

Estado:

```powershell
git status
```

Errores de espacios/formato de patch:

```powershell
git --no-pager diff --check
```

Historial:

```powershell
git --no-pager log --oneline --decorate --graph --all
```

Antes de un commit, agregar únicamente los archivos previstos.

Evitar:

```powershell
git add .
```

cuando no se haya revisado previamente todo el árbol de trabajo.

## 22. Problemas comunes

### La app abre pero no funciona autenticación

Comprobar:

```text
config/supabase.local.json
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

### El clima no carga

Comprobar:

- conexión a Internet;
- destino válido;
- que no exista bloqueo de red;
- mensajes mostrados por la interfaz.

### La ubicación no funciona en Chrome

Comprobar permisos del sitio en el navegador.

La validación de Chrome no sustituye Android.

### Sentry no recibe eventos

Comprobar:

```text
SENTRY_DSN
SENTRY_ENVIRONMENT
```

Para una única verificación:

```text
SENTRY_TEST_EVENT=true
```

Después volver a `false`.

### El archivo local aparece en Git

No agregarlo.

Comprobar:

```powershell
git check-ignore -v config/supabase.local.json
git check-ignore -v config/monitoreo.local.json
```

### `flutter` no se reconoce

Usar la ruta instalada de Flutter o agregar Flutter al `PATH`.

En Windows también puede ejecutarse directamente:

```powershell
& "D:\flutter\flutter\bin\flutter.bat" --version
```

si Flutter se encuentra instalado en esa ruta.

## 23. Documentación relacionada

README:

```text
README.md
```

Arquitectura:

```text
docs/arquitectura.md
```

Supabase:

```text
docs/
```

Open-Meteo:

```text
docs/open_meteo.md
```

Geolocalización:

```text
docs/geolocalizacion.md
```

Preferencias:

```text
docs/preferencias_locales.md
```

Monitoreo:

```text
docs/monitoreo.md
```

Pruebas y evidencia:

```text
docs/pruebas/
```

## 24. Criterio de instalación reproducible

La instalación se considera reproducible cuando otra persona puede:

1. clonar el repositorio;
2. ejecutar `flutter pub get`;
3. crear sus archivos locales de configuración;
4. ejecutar `flutter analyze`;
5. ejecutar `flutter test`;
6. iniciar Destino+;
7. comprender qué servicios externos necesita;
8. hacerlo sin obtener secretos desde el repositorio.

La generación final para Android se añadirá a este procedimiento cuando el
release haya sido realmente ejecutado y validado.
