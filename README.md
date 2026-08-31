# Destino+

Aplicación móvil para la planificación y organización de viajes personales.

## Estado del proyecto

🚧 Proyecto en desarrollo.

**Versión actual:** `0.1.0+1`

Destino+ se encuentra actualmente en su etapa inicial de configuración. Las funcionalidades descritas como alcance previsto se irán incorporando progresivamente y solo se considerarán implementadas cuando hayan sido desarrolladas y probadas.

## Descripción

Destino+ es una aplicación desarrollada con Flutter y Dart orientada a centralizar la planificación de viajes personales.

La aplicación busca permitir que una persona organice en un solo lugar sus destinos, fechas, actividades e información útil relacionada con cada viaje.

## Problema que busca resolver

Durante la planificación de un viaje, la información suele quedar distribuida entre notas, calendarios, aplicaciones de clima y otros medios.

Destino+ busca reducir esa dispersión mediante una aplicación sencilla que permita organizar la información principal de cada viaje y consultar datos útiles relacionados con el destino.

## Objetivo general

Desarrollar una aplicación móvil que permita planificar y organizar viajes personales mediante una interfaz clara, navegación coherente, almacenamiento de información y acceso a servicios externos relacionados con el viaje.

## Alcance previsto

Durante el desarrollo se plantea incorporar progresivamente:

- autenticación de usuarios;
- navegación entre múltiples pantallas;
- panel principal o inicio;
- gestión de viajes;
- creación, consulta, modificación y eliminación de viajes;
- registro de actividades asociadas a un viaje;
- consumo de una API pública relacionada con el clima;
- geolocalización;
- persistencia de información;
- preferencias locales;
- manejo de estados de carga, éxito y error;
- validaciones de formularios;
- diseño adaptable a diferentes tamaños de pantalla;
- pruebas y evidencias del funcionamiento.

> **Nota:** esta lista representa el alcance previsto. Una funcionalidad se documentará como implementada únicamente después de desarrollarla y probarla.

## Pantallas previstas

La aplicación contará como mínimo con las siguientes pantallas principales:

1. Inicio de sesión y registro.
2. Inicio o panel principal.
3. Lista de viajes.
4. Detalle de un viaje.
5. Creación y edición de viajes.
6. Perfil y ajustes.

Durante el desarrollo podrán incorporarse pantallas adicionales si son necesarias para mantener una navegación clara.

## Tecnologías iniciales

Actualmente el proyecto utiliza:

- Flutter `3.47.2`;
- Dart `3.13.2`;
- Git;
- GitHub;
- Flutter Web para la etapa inicial de desarrollo.

Tecnologías adicionales, como Provider, GoRouter, Supabase, SharedPreferences, geolocalización y una API pública de clima, se incorporarán únicamente cuando corresponda a cada etapa del proyecto.

## Requisitos actuales

Para trabajar con el proyecto en su estado actual se necesita:

- Flutter SDK compatible con Dart `3.13.2`;
- Dart SDK;
- Git;
- Google Chrome para la ejecución inicial en Flutter Web;
- conexión a Internet para recuperar dependencias.

La configuración de Android se realizará posteriormente, antes de generar y probar la versión Release, APK y AAB.

## Descargar el proyecto

Clonar el repositorio:

```bash
git clone https://github.com/RubenMealla/destino-plus.git
```

Entrar al proyecto:

```bash
cd destino_plus
```

## Recuperar dependencias

```bash
flutter pub get
```

## Verificar el entorno

```bash
flutter --version
dart --version
flutter doctor -v
flutter devices
```

## Ejecución inicial en Web

Durante la primera etapa del desarrollo se utilizará Google Chrome:

```bash
flutter run -d chrome
```

## Estructura inicial del proyecto

```text
destino_plus/
├── android/
├── lib/
│   └── main.dart
├── test/
│   └── widget_test.dart
├── web/
├── .gitignore
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
└── README.md
```

La estructura de `lib/` se reorganizará progresivamente a medida que se incorporen pantallas, modelos, servicios, estado global y componentes reutilizables.

## Versionado del proyecto

La versión actual se encuentra definida en `pubspec.yaml`:

```yaml
version: 0.1.0+1
```

Interpretación:

- `0.1.0`: versión visible actual del proyecto;
- `+1`: número interno de compilación.

El versionado se actualizará conforme avance el desarrollo y se preparen nuevas entregas.

## Control de versiones con Git

El proyecto utiliza Git para registrar de forma progresiva su evolución y GitHub como repositorio remoto.

**Rama principal:**

```text
main
```

Las funcionalidades y cambios importantes se desarrollarán en ramas específicas antes de integrarse en `main`.

Ejemplos:

```text
feature/project-setup
feature/ui-foundation
feature/navigation
feature/auth
feature/trips-crud
feature/weather-api
feature/location
```

Las ramas fusionadas podrán conservarse como evidencia del proceso de desarrollo.

## Convención de commits

Se utilizarán prefijos habituales en proyectos de software:

- `feat:` nueva funcionalidad;
- `fix:` corrección de un error;
- `docs:` documentación;
- `test:` pruebas;
- `refactor:` reorganización de código sin cambiar su comportamiento;
- `chore:` tareas técnicas o de configuración;
- `style:` cambios de formato que no modifican la lógica.

Ejemplo:

```text
feat: agrega navegación principal
```

## Seguridad

El repositorio está configurado para evitar publicar archivos sensibles o locales, entre ellos:

```text
.env
.env.*
config/live.json
android/key.properties
*.jks
*.keystore
```

No deben publicarse contraseñas, tokens privados, claves de firma, credenciales reales ni archivos de configuración que contengan secretos.

## Pruebas

En esta etapa inicial todavía no se ha definido la batería completa de pruebas del proyecto.

A medida que se incorporen funcionalidades se documentarán:

- análisis estático con `flutter analyze`;
- pruebas automatizadas con `flutter test`;
- pruebas funcionales;
- pruebas negativas;
- evidencias de ejecución;
- matriz de pruebas.

## Plataforma Android y entrega final

La aplicación será desarrollada inicialmente en Flutter Web para facilitar la construcción de la interfaz y la navegación.

Antes de la entrega final se configurará y verificará Android para:

- ejecutar la aplicación en modo Release;
- instalar y probar la aplicación fuera del entorno de desarrollo;
- configurar la firma;
- generar el APK Release;
- generar el AAB;
- comprobar versión y build;
- organizar las evidencias de entrega.

## Limitaciones actuales

En la versión `0.1.0+1`:

- todavía no se ha implementado la interfaz definitiva;
- todavía no existe autenticación;
- todavía no existe el CRUD de viajes;
- todavía no se ha integrado una API pública;
- todavía no se ha implementado geolocalización;
- todavía no se ha configurado persistencia;
- todavía no se ha configurado Android SDK en el entorno de desarrollo;
- todavía no se ha generado APK ni AAB.

Estas limitaciones corresponden al estado inicial del proyecto y se irán resolviendo de manera progresiva.

## Repositorio

GitHub:

```text
https://github.com/RubenMealla/destino-plus
```

## Autor

**Ruben Mealla**

Diplomado en Desarrollo Web y Aplicaciones Móviles  
Módulo 3 - Desarrollo de Aplicaciones Móviles  
Gestión 2026
