# Arquitectura técnica de Destino+

Este documento describe cómo está organizado Destino+ y cómo colaboran sus
componentes principales.

El objetivo de la arquitectura es mantener separadas, en la medida adecuada al
alcance académico del proyecto:

- presentación;
- estado;
- reglas de negocio;
- acceso a servicios externos;
- persistencia;
- integraciones de plataforma;
- configuración.

## 1. Visión general

Destino+ utiliza Flutter como capa de aplicación y combina servicios remotos,
almacenamiento local y capacidades del dispositivo.

```text
                         ┌─────────────────────┐
                         │      Destino+       │
                         │   Flutter / Dart    │
                         └──────────┬──────────┘
                                    │
               ┌────────────────────┼────────────────────┐
               │                    │                    │
               ▼                    ▼                    ▼
        Presentación / UI      Estado global      Servicios de dominio
               │                    │                    │
               │                    │           ┌────────┼─────────┐
               │                    │           │        │         │
               ▼                    ▼           ▼        ▼         ▼
            GoRouter             Provider    Supabase Open-Meteo Geolocator
                                                     │
                                                     ▼
                                               API meteorológica

                         Preferencias locales
                                │
                                ▼
                       shared_preferences

                         Monitoreo de errores
                                │
                                ▼
                              Sentry
```

## 2. Estructura principal

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
│   ├── presentacion/
│   ├── ubicacion/
│   └── viajes/
├── shared/
│   └── widgets/
└── main.dart
```

Fuera de `lib/`:

```text
android/              configuración de plataforma Android
config/               ejemplos y archivos locales de configuración
docs/                 documentación técnica y académica
evidencias/           evidencia real de pruebas y entrega
supabase/migrations/  definición evolutiva de la base de datos
test/                 pruebas automatizadas
```

## 3. Arranque de la aplicación

El punto de entrada es:

```text
lib/main.dart
```

El orden de inicialización es:

```text
main()
  │
  ├── leer ConfiguracionMonitoreo
  │
  ├── InicializadorMonitoreo
  │       │
  │       ├── sin DSN → continuar normalmente
  │       └── con DSN → SentryFlutter.init(...)
  │
  └── _iniciarAplicacion()
          │
          ├── WidgetsFlutterBinding.ensureInitialized()
          ├── ConfiguracionSupabase.inicializar()
          ├── EstadoApariencia.cargar()
          ├── EstadoUnidades.cargar()
          └── runApp(DestinoPlusApp)
```

La inicialización de Flutter permanece dentro del mismo flujo utilizado por
Sentry. Esto evita mezclar zonas de ejecución entre el binding y `runApp`.

## 4. Aplicación y estado global

`DestinoPlusApp` registra estados compartidos mediante `MultiProvider`.

Estados globales actuales:

```text
EstadoSesion
EstadoApariencia
EstadoUnidades
```

Responsabilidades:

### EstadoSesion

Mantiene el estado de autenticación utilizado por la aplicación y por la
protección de rutas.

### EstadoApariencia

Controla:

```text
Sistema
Claro
Oscuro
```

y expone el `ThemeMode` utilizado por `MaterialApp.router`.

### EstadoUnidades

Controla la presentación de temperaturas:

```text
Celsius
Fahrenheit
```

La conversión se centraliza en este estado para evitar fórmulas repetidas en
las pantallas.

## 5. Navegación

Destino+ utiliza:

```text
go_router
```

Configuración:

```text
lib/app/router/router_app.dart
```

La navegación centraliza:

- rutas públicas;
- rutas protegidas;
- redirección según sesión;
- navegación principal;
- rutas anidadas de viajes y actividades;
- pantalla comprensible para rutas inexistentes.

Flujo simplificado:

```text
sin sesión
   │
   ├── presentación
   ├── inicio de sesión
   └── registro

con sesión
   │
   └── navegación principal
         ├── Inicio
         ├── Viajes
         │    ├── Nuevo viaje
         │    └── Detalle
         │          ├── Editar viaje
         │          ├── Nueva actividad
         │          └── Editar actividad
         ├── Explorar
         └── Perfil
```

`StatefulShellRoute.indexedStack` conserva el contexto de las cuatro secciones
principales mientras el usuario navega entre ellas.

## 6. Organización por funcionalidades

Las funciones principales se agrupan dentro de `lib/features`.

Cada módulo puede contener, según sus necesidades:

```text
modelos/
servicios/
estado/
pantallas
```

No todos los módulos necesitan exactamente las mismas capas.

El proyecto evita crear abstracciones sin utilidad práctica, pero introduce
interfaces cuando ayudan a:

- separar la UI de SDK externos;
- sustituir servicios por fakes;
- probar errores;
- aislar reglas de negocio.

## 7. Autenticación

Módulo:

```text
lib/features/auth/
```

Proveedor:

```text
Supabase Auth
```

Responsabilidades:

- registro;
- inicio de sesión;
- cierre de sesión;
- observación del usuario actual;
- exposición del estado de sesión;
- traducción de errores técnicos a mensajes comprensibles.

La navegación consulta `EstadoSesion` para impedir acceso a secciones privadas
cuando el usuario no está autenticado.

## 8. Viajes

Módulo:

```text
lib/features/viajes/
```

Entidad principal:

```text
Viaje
```

Responsabilidades:

- crear;
- listar;
- obtener;
- actualizar;
- eliminar;
- validar datos del formulario;
- presentar detalle.

Persistencia:

```text
Supabase
```

La interfaz consume contratos de repositorio, por lo que los widget tests
pueden utilizar implementaciones falsas sin conectarse a Internet.

## 9. Actividades

Módulo:

```text
lib/features/actividades/
```

Entidad:

```text
ActividadViaje
```

Relación:

```text
Viaje
  │
  └── 0..N Actividades
```

Reglas destacadas:

- cada actividad pertenece a un viaje;
- la fecha debe encontrarse dentro del rango del viaje;
- puede tener hora, lugar y notas opcionales;
- puede estar pendiente o completada;
- el itinerario se organiza por día.

La validación existe en la aplicación y se refuerza en Supabase mediante las
migraciones correspondientes.

## 10. Supabase

Configuración:

```text
lib/app/config/configuracion_supabase.dart
```

Variables esperadas:

```text
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

Destino+ utiliza únicamente la clave pública de cliente.

No debe utilizar:

```text
service_role
claves privadas
tokens administrativos
```

Persistencia principal:

```text
viajes
actividades_viaje
```

Las políticas de Row Level Security restringen el acceso a los registros que
corresponden al usuario autenticado.

Las migraciones versionadas se encuentran en:

```text
supabase/migrations/
```

Esto permite conocer cómo evolucionó la estructura de base de datos junto con
el código fuente.

## 11. Open-Meteo

Módulo:

```text
lib/features/clima/
```

Flujo para búsqueda por texto:

```text
PantallaExplorar
      │
      ▼
ServicioClimaDestino
      │
      ├── buscar ubicación
      │      │
      │      ▼
      │   Open-Meteo Geocoding
      │
      └── obtener pronóstico
             │
             ▼
         Open-Meteo Forecast
```

`ServicioClimaDestino` puede trabajar con:

```text
texto de destino
coordenadas conocidas
```

Cuando se consulta por texto:

1. normaliza la consulta;
2. obtiene posibles ubicaciones;
3. selecciona la opción con mejor coincidencia;
4. consulta el pronóstico;
5. devuelve un `ClimaDestino`.

Cuando ya existen coordenadas no realiza geocodificación innecesaria.

## 12. Geolocalización

Módulo:

```text
lib/features/ubicacion/
```

Plugin:

```text
geolocator
```

El servicio se desacopla mediante contratos propios.

Flujo:

```text
ServicioGeolocalizacion
        │
        ├── comprobar servicio
        ├── comprobar permiso
        ├── solicitar permiso si corresponde
        └── obtener posición
                │
                ▼
        UbicacionActual
```

La lectura utiliza precisión alta con tiempo máximo de espera.

Errores de dominio:

```text
servicioDeshabilitado
permisoDenegado
permisoDenegadoPermanentemente
tiempoAgotado
noDisponible
```

La interfaz puede ofrecer acciones distintas según cada estado.

## 13. Integración ubicación + clima

Servicio:

```text
ServicioClimaUbicacionActual
```

Flujo:

```text
Usar mi ubicación
       │
       ▼
ServicioGeolocalizacion
       │
       ▼
latitud + longitud
       │
       ▼
ServicioClimaDestino.consultarCoordenadas(...)
       │
       ▼
Open-Meteo
       │
       ▼
ClimaUbicacionActual
```

Las coordenadas no se persisten como preferencia ni como dato del perfil.

## 14. Preferencias locales

Directorio:

```text
lib/app/preferencias/
```

Tecnología:

```text
shared_preferences
```

La UI no utiliza directamente el paquete. El flujo es:

```text
UI
 │
 ▼
EstadoApariencia / EstadoUnidades
 │
 ▼
ServicioPreferenciasLocales
 │
 ▼
AlmacenPreferencias
 │
 ▼
SharedPreferencesAsync
```

Esto permite sustituir el almacenamiento real por un mapa en memoria durante
las pruebas.

## 15. Monitoreo

Directorio:

```text
lib/app/monitoreo/
```

Proveedor:

```text
Sentry
```

Flujo:

```text
ConfiguracionMonitoreo
        │
        ▼
InicializadorMonitoreo
        │
        ├── sin DSN → app normal
        │
        └── con DSN
              │
              ▼
        PlataformaMonitoreoSentry
              │
              ▼
        SentryFlutter.init
```

Configuración de privacidad:

```text
sendDefaultPii = false
attachScreenshot = false
attachViewHierarchy = false
tracesSampleRate = 0
```

La verificación controlada utiliza un evento explícito únicamente cuando:

```text
SENTRY_DSN existe
SENTRY_TEST_EVENT = true
environment != production
```

La aplicación no necesita Sentry para funcionar.

## 16. Manejo de errores

El proyecto distingue, cuando corresponde:

```text
errores técnicos
        │
        ▼
excepciones de dominio
        │
        ▼
mensajes comprensibles en la UI
```

Ejemplos:

```text
ExcepcionClima
ExcepcionUbicacion
ExcepcionViajes
ExcepcionAutenticacion
```

Este enfoque evita mostrar directamente mensajes internos de SDK externos al
usuario.

## 17. Componentes compartidos

Directorio:

```text
lib/shared/widgets/
```

Contiene componentes reutilizados por distintas pantallas.

Ejemplos de responsabilidades:

- contenido adaptable;
- navegación principal;
- botones de acción;
- estados vacíos;
- tarjetas informativas;
- encabezados de sección.

El objetivo es reducir duplicación visual y mantener una identidad coherente.

## 18. Temas

Directorio:

```text
lib/app/theme/
```

La aplicación utiliza Material 3 y define temas claro y oscuro.

La elección de tema es estado global y puede persistirse localmente.

## 19. Configuración por entorno

Los valores externos se proporcionan mediante:

```text
--dart-define
--dart-define-from-file
```

Archivos de ejemplo versionados:

```text
config/supabase.example.json
config/monitoreo.example.json
```

Archivos locales:

```text
config/supabase.local.json
config/monitoreo.local.json
```

`.gitignore` excluye:

```text
config/*.local.json
```

Esto permite separar:

```text
código fuente
configuración del desarrollador
credenciales de cliente
```

## 20. Pruebas y testabilidad

Las interfaces utilizadas en servicios permiten construir fakes para pruebas.

Ejemplo conceptual:

```text
Pantalla
   │
   ▼
FuenteClimaDestino
   │
   ├── producción → ServicioClimaDestino → Open-Meteo
   └── test       → FuenteClimaFalsa
```

Lo mismo se aplica a módulos como:

- geolocalización;
- repositorios;
- preferencias;
- monitoreo.

La suite se encuentra en:

```text
test/
```

y se ejecuta mediante:

```powershell
flutter test
```

## 21. Seguridad y privacidad

Decisiones principales:

- autenticación mediante Supabase;
- RLS en registros del usuario;
- `service_role` fuera del cliente;
- configuraciones locales ignoradas por Git;
- ubicación obtenida solo por acción del usuario;
- sin ubicación en segundo plano;
- coordenadas no persistidas;
- Sentry sin PII predeterminada;
- sin screenshots automáticos de Sentry;
- sin tokens administrativos dentro de Flutter.

## 22. Dependencias principales

Las dependencias funcionales actuales incluyen:

```text
go_router
supabase_flutter
provider
shared_preferences
http
geolocator
sentry_flutter
```

Flutter proporciona:

```text
Material
Widgets
flutter_test
```

Las versiones exactas se definen en:

```text
pubspec.yaml
```

## 23. Principios utilizados

La arquitectura prioriza:

```text
responsabilidad clara
dependencias explícitas
servicios sustituibles
estado centralizado cuando es global
persistencia adecuada al tipo de dato
errores comprensibles
configuración fuera del código
testabilidad
```

Destino+ no intenta implementar una arquitectura empresarial completa. La
estructura se mantiene proporcional al alcance de un proyecto académico móvil
individual, pero deja puntos de extensión claros para evolución futura.
