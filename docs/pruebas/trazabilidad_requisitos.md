# Trazabilidad de requisitos, implementación y pruebas de Destino+

Este documento relaciona los requisitos principales del proyecto con su
implementación técnica, pruebas y evidencia prevista.

La trazabilidad no sustituye la matriz funcional:

```text
docs/pruebas/matriz_pruebas_funcionales.md
```

ni el plan de evidencias:

```text
docs/pruebas/plan_evidencias.md
```

Su objetivo es permitir responder de forma directa:

```text
¿Qué requisito se pidió?
        ↓
¿Dónde está implementado?
        ↓
¿Cómo se prueba?
        ↓
¿Qué evidencia lo demuestra?
        ↓
¿Cuál es su estado?
```

## Convención de estado

| Estado | Significado |
| --- | --- |
| `Implementado` | La función existe en el proyecto. |
| `Probado` | Existe cobertura automatizada y/o validación manual realizada durante desarrollo. |
| `Pendiente de evidencia final` | La función existe, pero todavía falta ejecutar y guardar la evidencia final de entrega. |
| `Pendiente Android` | Requiere Android real/emulador y todavía debe validarse en esa plataforma. |
| `Pendiente release` | Se completará en la fase de compilación y distribución final. |

No se usa `Aprobado final` en esta etapa.

## 1. Aplicación Flutter funcional

**Requisito**

Desarrollar una aplicación funcional con Flutter y Dart.

**Implementación**

Proyecto principal:

```text
lib/
```

Entrada de la aplicación:

```text
lib/main.dart
```

Aplicación y estado global:

```text
lib/app/destino_plus_app.dart
```

**Pruebas**

La suite completa se ejecuta mediante:

```powershell
flutter test
```

La calidad estática se comprueba mediante:

```powershell
flutter analyze
```

**Evidencia prevista**

```text
evidencias/06_pruebas/01_flutter_analyze.png
evidencias/06_pruebas/02_flutter_test.png
```

**Estado**

`Implementado` y `Probado`.

La ejecución final todavía debe conservarse como evidencia.

## 2. Identidad propia de la aplicación

**Requisito**

La aplicación debe tener una identidad clara y coherente.

**Implementación**

Nombre visible:

```text
Destino+
```

Lema:

```text
Organiza tu destino. Disfruta el camino.
```

Tema visual y Material 3:

```text
lib/app/theme/
```

Las pantallas utilizan componentes y estilos propios del proyecto.

**Pruebas**

La identidad se valida principalmente de forma visual y funcional.

**Evidencia prevista**

```text
evidencias/03_navegacion/
evidencias/04_viajes_actividades/
evidencias/05_integraciones/
```

**Estado**

`Implementado`; `Pendiente de evidencia final`.

## 3. Múltiples pantallas y navegación

**Requisito**

Disponer de varias pantallas integradas mediante navegación.

**Implementación**

Destino+ dispone, entre otras, de:

```text
Inicio
Inicio de sesión
Registro
Viajes
Formulario de viaje
Detalle de viaje
Formulario de actividad
Explorar
Perfil
```

Router:

```text
lib/app/router/
```

Navegación principal:

```text
Inicio
Viajes
Explorar
Perfil
```

**Pruebas**

```text
test/navegacion_core_test.dart
test/auth_interfaz_test.dart
```

Casos relacionados:

```text
NAV-01
NAV-02
NAV-03
NAV-04
AUTH-05
```

**Evidencia prevista**

```text
evidencias/03_navegacion/01_inicio.png
evidencias/03_navegacion/02_viajes.png
evidencias/03_navegacion/03_explorar.png
evidencias/03_navegacion/04_perfil.png
```

**Estado**

`Implementado` y `Probado`; `Pendiente de evidencia final`.

## 4. Autenticación de usuario

**Requisito**

Incluir acceso de usuario y manejo básico de sesión.

**Implementación**

Módulo:

```text
lib/features/auth/
```

Proveedor real:

```text
Supabase Auth
```

Funciones principales:

```text
registro
inicio de sesión
estado de sesión
protección de rutas
cierre de sesión
```

**Pruebas**

```text
test/auth_interfaz_test.dart
test/navegacion_core_test.dart
```

Casos relacionados:

```text
AUTH-01
AUTH-02
AUTH-03
AUTH-04
AUTH-05
AUTH-06
AUTH-07
AUTH-08
NAV-02
NAV-03
```

**Evidencia prevista**

```text
evidencias/02_autenticacion/
```

**Estado**

`Implementado` y `Probado`.

Registro real con Supabase fue validado durante desarrollo; la evidencia final
debe realizarse con un usuario de prueba sin exponer datos sensibles.

## 5. CRUD principal

**Requisito**

Implementar operaciones de crear, leer, actualizar y eliminar datos.

**Implementación**

Entidad principal:

```text
Viaje
```

Código:

```text
lib/features/viajes/
```

Persistencia:

```text
Supabase
```

Operaciones:

```text
crear viaje
listar viajes
consultar detalle
editar viaje
eliminar viaje
```

**Pruebas**

Entre otras:

```text
test/viajes_resiliencia_test.dart
```

además de las pruebas específicas ya existentes para modelo, listado, detalle,
edición y eliminación.

Casos relacionados:

```text
VIA-01
VIA-02
VIA-03
VIA-04
VIA-05
VIA-06
VIA-07
```

**Evidencia prevista**

```text
evidencias/04_viajes_actividades/01_viajes_estado_vacio.png
evidencias/04_viajes_actividades/02_crear_viaje.png
evidencias/04_viajes_actividades/03_lista_viajes.png
evidencias/04_viajes_actividades/04_detalle_viaje.png
evidencias/04_viajes_actividades/05_editar_viaje.png
evidencias/04_viajes_actividades/06_confirmar_eliminar_viaje.png
```

**Estado**

`Implementado` y `Probado`; `Pendiente de evidencia final`.

## 6. Relación viaje → actividades e itinerario

**Requisito funcional del proyecto**

Permitir organizar actividades dentro de cada viaje.

**Implementación**

Código:

```text
lib/features/actividades/
lib/features/viajes/pantalla_detalle_viaje.dart
```

Persistencia:

```text
Supabase
```

Funciones:

```text
crear actividad
editar actividad
eliminar actividad
marcar como completada
agrupar por día
validar que la fecha pertenezca al viaje
```

La validación también se refuerza en la base de datos mediante migraciones de
Supabase.

**Pruebas**

```text
test/actividades_flujo_integral_test.dart
test/itinerario_actividades_test.dart
```

y otras pruebas del módulo de actividades.

Casos relacionados:

```text
ACT-01
ACT-02
ACT-03
ACT-04
ACT-05
ACT-06
ACT-07
ACT-08
```

**Evidencia prevista**

```text
evidencias/04_viajes_actividades/07_itinerario_vacio.png
evidencias/04_viajes_actividades/08_crear_actividad.png
evidencias/04_viajes_actividades/09_itinerario_por_dias.png
evidencias/04_viajes_actividades/10_actividad_completada.png
evidencias/04_viajes_actividades/11_confirmar_eliminar_actividad.png
```

**Estado**

`Implementado` y `Probado`; `Pendiente de evidencia final`.

## 7. Base de datos remota y seguridad por usuario

**Requisito técnico**

Persistir información principal en una fuente remota y limitar el acceso a los
datos del usuario correspondiente.

**Implementación**

Proveedor:

```text
Supabase
```

Tablas principales:

```text
viajes
actividades_viaje
```

Migraciones:

```text
supabase/migrations/
```

Se utilizan políticas RLS para restringir los datos al usuario propietario.

**Pruebas**

Las capas de repositorio se prueban mediante dobles/fuentes controladas.

La comprobación final de RLS debe conservarse como parte de la validación
técnica de Supabase si se solicita evidencia específica.

**Evidencia prevista**

El funcionamiento visible se demuestra mediante autenticación y CRUD.

No se deben capturar secretos ni claves privadas de Supabase.

**Estado**

`Implementado`; `Pendiente de evidencia final`.

## 8. API pública relacionada con el propósito del proyecto

**Requisito**

Consumir una API pública relacionada con la aplicación.

**Implementación**

API:

```text
Open-Meteo
```

Código:

```text
lib/features/clima/
```

La aplicación utiliza geocodificación y pronóstico meteorológico para el
destino buscado.

**Pruebas**

Entre otras:

```text
test/pantalla_explorar_clima_test.dart
test/integracion_unidades_clima_test.dart
test/servicio_clima_ubicacion_errores_test.dart
```

Casos relacionados:

```text
API-01
API-02
API-03
API-04
API-05
```

**Evidencia prevista**

```text
evidencias/05_integraciones/01_clima_tarija.png
evidencias/05_integraciones/02_clima_otro_destino.png
evidencias/05_integraciones/03_clima_error_destino.png
```

**Estado**

`Implementado` y `Probado`; `Pendiente de evidencia final`.

## 9. Estados de carga, error y recuperación

**Requisito de calidad**

Una integración remota no debe dejar la interfaz bloqueada ni fallar sin
explicación.

**Implementación**

Existen estados de:

```text
carga
resultado
error
reintento
estado vacío
```

en módulos como viajes, clima y ubicación.

**Pruebas**

```text
test/viajes_resiliencia_test.dart
test/pantalla_explorar_clima_test.dart
test/servicio_clima_ubicacion_errores_test.dart
```

Casos relacionados:

```text
VIA-07
API-03
API-04
API-05
GEO-02
GEO-03
GEO-04
GEO-05
GEO-06
```

**Evidencia prevista**

Capturas de estados de error seleccionados y salida de tests.

**Estado**

`Implementado` y `Probado`; `Pendiente de evidencia final`.

## 10. Persistencia local

**Requisito**

Utilizar almacenamiento local para datos apropiados del dispositivo.

**Implementación**

Paquete:

```text
shared_preferences
```

Código:

```text
lib/app/preferencias/
```

Preferencias actuales:

```text
apariencia
unidad de temperatura
```

Los viajes y actividades no se duplican aquí: permanecen en Supabase.

**Pruebas**

```text
test/servicio_preferencias_locales_test.dart
test/estado_unidades_test.dart
test/preferencias_reinicio_test.dart
test/apariencia_perfil_test.dart
```

Casos relacionados:

```text
PREF-01
PREF-02
PREF-03
PREF-04
PREF-05
PREF-06
```

**Evidencia prevista**

```text
evidencias/05_integraciones/04_tema_oscuro.png
evidencias/05_integraciones/05_temperatura_fahrenheit.png
```

**Estado**

`Implementado` y `Probado`; `Pendiente de evidencia final`.

## 11. Estado global

**Requisito técnico**

Mantener estado compartido de forma organizada.

**Implementación**

Proveedor:

```text
Provider
```

Estados globales relevantes:

```text
EstadoSesion
EstadoApariencia
EstadoUnidades
```

Registro:

```text
lib/app/destino_plus_app.dart
```

**Pruebas**

Las pruebas de autenticación, apariencia, unidades y clima ejercitan estos
estados.

**Evidencia prevista**

Se demuestra indirectamente mediante:

```text
cambio global de tema
persistencia de unidades
protección de rutas
sesión
```

**Estado**

`Implementado` y `Probado`.

## 12. Capacidad nativa: geolocalización

**Requisito**

Integrar al menos una capacidad nativa útil para el propósito de la aplicación.

**Implementación**

Paquete:

```text
geolocator
```

Código:

```text
lib/features/ubicacion/
```

Integración:

```text
ubicación actual
      ↓
coordenadas
      ↓
Open-Meteo
      ↓
clima de la ubicación actual
```

Permisos Android:

```text
ACCESS_COARSE_LOCATION
ACCESS_FINE_LOCATION
```

No se solicita ubicación en segundo plano.

**Pruebas**

```text
test/servicio_geolocalizacion_test.dart
test/servicio_clima_ubicacion_actual_test.dart
test/servicio_clima_ubicacion_errores_test.dart
test/pantalla_explorar_clima_test.dart
```

Casos relacionados:

```text
GEO-01
GEO-02
GEO-03
GEO-04
GEO-05
GEO-06
```

**Evidencia prevista**

```text
evidencias/05_integraciones/06_ubicacion_actual_android.png
evidencias/05_integraciones/07_permiso_ubicacion_android.png
evidencias/05_integraciones/08_configuracion_ubicacion_android.png
```

**Estado**

`Implementado` y cubierto por pruebas automatizadas.

La validación del permiso y GPS reales queda `Pendiente Android`.

## 13. Manejo responsable de permisos

**Requisito de plataforma**

Solicitar únicamente los permisos necesarios.

**Implementación**

Manifest principal:

```text
android/app/src/main/AndroidManifest.xml
```

Permisos declarados:

```text
INTERNET
ACCESS_COARSE_LOCATION
ACCESS_FINE_LOCATION
```

No se declara:

```text
ACCESS_BACKGROUND_LOCATION
```

**Pruebas**

La lógica de permisos se cubre mediante el servicio de geolocalización y los
estados de interfaz.

**Evidencia prevista**

Diálogo real de Android y funcionamiento posterior.

**Estado**

`Implementado`; `Pendiente Android`.

## 14. Responsive y adaptación visual

**Requisito de interfaz**

La aplicación debe conservar una presentación utilizable en distintos tamaños.

**Implementación**

Componentes compartidos:

```text
lib/shared/widgets/
```

Entre ellos:

```text
ContenidoAdaptable
```

Las pantallas principales utilizan estructuras desplazables, espaciado
centralizado y componentes Material.

**Pruebas**

La suite de widgets detecta errores de construcción y varios flujos de
interfaz.

La comprobación visual final debe realizarse también en Android.

**Evidencia prevista**

Capturas de pantallas principales en el dispositivo de prueba.

**Estado**

`Implementado`; `Pendiente de evidencia final`.

## 15. Git e historial de desarrollo

**Requisito**

Utilizar Git con historial técnico comprensible.

**Implementación**

Repositorio con:

```text
main
feature/*
fix/*
test/*
docs/*
```

El flujo utilizado conserva ramas fusionadas como parte de la evidencia.

Los cambios importantes se integran mediante Pull Request y merge commit.

**Pruebas**

Comandos:

```powershell
git status
git --no-pager diff --check
git --no-pager log --oneline --decorate --graph --all
```

**Evidencia prevista**

```text
evidencias/06_pruebas/03_git_log.png
evidencias/06_pruebas/04_github_branches_pr.png
```

**Estado**

`Implementado`; `Pendiente de evidencia final`.

## 16. README y documentación técnica

**Requisito**

Permitir que otra persona comprenda, configure, ejecute y evalúe el proyecto.

**Implementación**

Documentación distribuida en:

```text
README.md
docs/
```

Actualmente existen documentos específicos de:

```text
Supabase
Open-Meteo
geolocalización
preferencias locales
pruebas
evidencias
```

**Pruebas**

Revisión manual de enlaces, comandos y coherencia documental.

**Evidencia prevista**

El propio repositorio constituye la evidencia principal.

**Estado**

`Implementado parcialmente`.

La revisión y documentación final se completará en una fase posterior.

## 17. APK Release

**Requisito final**

Generar una aplicación Android Release e instalarla fuera del IDE.

**Implementación prevista**

Comando:

```powershell
flutter build apk --release
```

Ruta esperada:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Después debe instalarse y ejecutarse fuera del flujo normal del IDE.

**Pruebas**

Casos:

```text
REL-01
REL-02
REL-03
REL-04
```

**Evidencia prevista**

```text
evidencias/07_release_android/
```

**Estado**

`Pendiente release`.

## 18. AAB firmado

**Requisito final**

Generar un Android App Bundle firmado para distribución.

**Implementación prevista**

Configuración de firma Android y:

```powershell
flutter build appbundle
```

Ruta esperada:

```text
build/app/outputs/bundle/release/app.aab
```

**Pruebas**

Caso:

```text
REL-05
```

**Evidencia prevista**

```text
evidencias/07_release_android/09_build_aab.png
evidencias/07_release_android/10_aab_generado.png
evidencias/07_release_android/12_sha256_aab.txt
```

**Estado**

`Pendiente release`.

## 19. Calidad final

**Requisito**

Entregar el proyecto sin problemas conocidos de análisis estático y con la
suite automatizada aprobada.

**Implementación prevista**

Antes de release:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

**Pruebas**

Casos:

```text
REL-06
REL-07
```

**Evidencia prevista**

```text
evidencias/06_pruebas/01_flutter_analyze.png
evidencias/06_pruebas/02_flutter_test.png
```

**Estado**

Estas herramientas se han usado durante el desarrollo.

La ejecución que cuenta como cierre queda `Pendiente de evidencia final`.

## 20. Monitoreo

**Requisito de cierre del curso**

El material del diplomado contempla monitoreo dentro de la preparación final
de una aplicación.

**Implementación**

Todavía no se registra una integración final de monitoreo en este documento.

**Pruebas**

Se definirán únicamente si se implementa una solución real.

**Evidencia prevista**

```text
evidencias/08_monitoreo/
```

**Estado**

`Pendiente`.

No se debe declarar cumplido hasta que exista una integración real.

## Resumen de trazabilidad

| Área | Implementación | Pruebas | Evidencia final |
| --- | --- | --- | --- |
| Flutter/Dart | Sí | Sí | Pendiente captura final |
| Identidad visual | Sí | Visual | Pendiente |
| Navegación | Sí | Sí | Pendiente |
| Autenticación | Sí | Sí | Pendiente |
| CRUD viajes | Sí | Sí | Pendiente |
| Actividades | Sí | Sí | Pendiente |
| Supabase | Sí | Parcial automatizada + manual | Pendiente |
| Open-Meteo | Sí | Sí | Pendiente |
| Estados de error | Sí | Sí | Pendiente |
| Persistencia local | Sí | Sí | Pendiente |
| Estado global | Sí | Sí | Pendiente |
| Geolocalización | Sí | Sí | Pendiente Android |
| Permisos Android | Sí | Lógica probada | Pendiente Android |
| Git | Sí | Historial real | Pendiente captura |
| Documentación | En progreso | Revisión manual | Pendiente cierre |
| APK Release | No finalizado | No | Pendiente |
| AAB firmado | No finalizado | No | Pendiente |
| Monitoreo | No finalizado | No | Pendiente |

## Uso durante la entrega

Cuando se ejecute la fase final:

1. revisar esta tabla;
2. ejecutar la matriz funcional;
3. completar las evidencias;
4. comprobar que cada requisito obligatorio tenga:
   - implementación;
   - prueba;
   - evidencia;
5. corregir cualquier requisito obligatorio que todavía figure como pendiente;
6. actualizar README y conclusiones sin afirmar resultados no verificados.

Este documento debe reflejar el estado real del repositorio. Si una función
cambia o se elimina, su trazabilidad también debe actualizarse.
