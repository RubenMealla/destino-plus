# Matriz de pruebas funcionales de Destino+

Esta matriz organiza los casos que deben verificarse antes de la entrega final
del proyecto.

No sustituye las pruebas automatizadas del repositorio. Su objetivo es reunir
en un solo documento:

- qué comportamiento se valida;
- cuál es el resultado esperado;
- qué resultado fue observado;
- si existe una prueba automatizada relacionada;
- qué evidencia debe conservarse para la entrega.

## Criterio de estados

Se utilizan los siguientes estados:

| Estado | Significado |
| --- | --- |
| `Pendiente` | Todavía falta ejecutar o documentar la prueba manual final. |
| `Cubierto por test` | Existe prueba automatizada; debe repetirse en la validación final. |
| `Validado manualmente` | El comportamiento ya fue comprobado manualmente durante el desarrollo. |
| `Aprobado final` | Reservado para la ejecución final documentada con evidencia. |
| `Fallido` | El comportamiento observado no coincide con el esperado. |
| `No aplica` | El caso no corresponde a la plataforma o etapa evaluada. |

`Aprobado final` no debe utilizarse hasta realizar la validación de cierre y
guardar la evidencia correspondiente.

## Matriz

| ID | Módulo | Escenario | Precondición | Pasos resumidos | Resultado esperado | Resultado obtenido actual | Estado | Evidencia final esperada |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AUTH-01 | Autenticación | Abrir inicio de sesión | Aplicación iniciada sin sesión | Abrir Destino+ | Se muestra la pantalla de acceso | Cubierto por navegación y pruebas de autenticación | Cubierto por test | Captura de pantalla de acceso |
| AUTH-02 | Autenticación | Validar campos vacíos en login | Sin sesión | Pulsar `Iniciar sesión` sin completar campos | Se muestran mensajes de validación y no se envía el formulario | Cubierto por `test/auth_interfaz_test.dart` | Cubierto por test | Salida de `flutter test` |
| AUTH-03 | Autenticación | Validar correo inválido y contraseña corta | Sin sesión | Introducir datos inválidos y enviar | Se muestran mensajes de error en español | Cubierto por `test/auth_interfaz_test.dart` | Cubierto por test | Salida de `flutter test` |
| AUTH-04 | Autenticación | Mostrar y ocultar contraseña | Sin sesión | Pulsar el icono de visibilidad | La contraseña alterna entre oculta y visible | Cubierto por `test/auth_interfaz_test.dart` | Cubierto por test | Salida de `flutter test` |
| AUTH-05 | Autenticación | Navegar de login a registro | Sin sesión | Pulsar `Crear cuenta` | Se abre el formulario de registro | Cubierto por pruebas de interfaz | Cubierto por test | Captura o salida de test |
| AUTH-06 | Autenticación | Validar formulario de registro | Sin sesión | Enviar campos vacíos o inválidos | Se muestran validaciones y no se crea una cuenta | Cubierto por `test/auth_interfaz_test.dart` | Cubierto por test | Salida de `flutter test` |
| AUTH-07 | Autenticación | Registrar usuario real | Supabase configurado y conexión disponible | Completar datos válidos y crear cuenta | Supabase crea el usuario y la app reconoce la sesión | Comprobado durante la integración inicial con Supabase | Validado manualmente | Captura de registro o usuario de prueba sin exponer datos sensibles |
| AUTH-08 | Autenticación | Cerrar sesión | Usuario autenticado | Ir a Perfil y pulsar `Cerrar sesión` | Se cierra la sesión y se vuelve al flujo de acceso | Función implementada; repetir en cierre | Pendiente | Captura antes/después o video corto |
| NAV-01 | Navegación | Navegar entre las cuatro secciones principales | Usuario autenticado | Usar `Inicio`, `Viajes`, `Explorar`, `Perfil` | Cada opción abre su sección correcta | Cubierto por `test/navegacion_core_test.dart` | Cubierto por test | Salida de `flutter test` + captura de barra |
| NAV-02 | Navegación | Proteger ruta privada sin sesión | Sin sesión | Intentar abrir una ruta privada | La app redirige a inicio de sesión | Cubierto por `test/navegacion_core_test.dart` | Cubierto por test | Salida de `flutter test` |
| NAV-03 | Navegación | Acceder a registro sin sesión | Sin sesión | Abrir ruta de registro | Registro permanece accesible | Cubierto por test | Cubierto por test | Salida de `flutter test` |
| NAV-04 | Navegación | Ruta desconocida | Aplicación iniciada | Abrir una ruta inexistente | Se muestra un error comprensible, no una pantalla rota | Cubierto por test | Cubierto por test | Salida de `flutter test` |
| VIA-01 | Viajes | Lista vacía | Usuario autenticado sin viajes | Entrar a `Viajes` | Se muestra estado vacío con acción para crear un viaje | Cubierto por pruebas existentes | Cubierto por test | Captura del estado vacío |
| VIA-02 | Viajes | Crear viaje válido | Usuario autenticado | Completar título, destino y fechas válidas | El viaje se persiste y aparece en la lista | Cubierto por pruebas y validado durante desarrollo | Cubierto por test | Captura del formulario y lista resultante |
| VIA-03 | Viajes | Rechazar rango de fechas inválido | Usuario autenticado | Poner fin anterior al inicio | El formulario no guarda y muestra el error correspondiente | Cubierto por `test/viajes_resiliencia_test.dart` | Cubierto por test | Salida de `flutter test` |
| VIA-04 | Viajes | Abrir detalle | Existe un viaje | Seleccionarlo desde la lista | Se muestran título, destino, fechas, duración y descripción | Cubierto por pruebas existentes | Cubierto por test | Captura del detalle |
| VIA-05 | Viajes | Editar viaje | Existe un viaje | Abrir edición, modificar datos y guardar | Los cambios se persisten y se muestran en detalle/lista | Cubierto por pruebas existentes | Cubierto por test | Capturas antes/después |
| VIA-06 | Viajes | Eliminar viaje | Existe un viaje | Pulsar eliminar, confirmar | El viaje desaparece y también deben eliminarse sus actividades por relación de BD | Cubierto por pruebas del CRUD; validar BD final | Cubierto por test | Captura de confirmación + lista final |
| VIA-07 | Viajes | Recuperarse de error temporal de carga | Fuente devuelve error inicialmente | Pulsar `Reintentar` | La lista vuelve a solicitar datos y puede recuperarse | Cubierto por `test/viajes_resiliencia_test.dart` | Cubierto por test | Salida de `flutter test` |
| ACT-01 | Actividades | Estado vacío del itinerario | Viaje sin actividades | Abrir detalle | Se muestra estado `Aún no hay actividades` | Cubierto por pruebas | Cubierto por test | Captura del itinerario vacío |
| ACT-02 | Actividades | Crear actividad dentro del viaje | Existe un viaje | Agregar actividad con fecha válida | La actividad se guarda y aparece en su día | Cubierto por pruebas | Cubierto por test | Captura del formulario y resultado |
| ACT-03 | Actividades | Rechazar actividad fuera del rango | Existe un viaje | Usar fecha anterior o posterior al viaje | No se guarda y se muestra el rango permitido | Cubierto por `test/actividades_flujo_integral_test.dart` | Cubierto por test | Salida de `flutter test` |
| ACT-04 | Actividades | Aceptar primer y último día | Existe un viaje | Crear actividades exactamente en inicio y fin | Ambas fechas son válidas | Cubierto por test | Cubierto por test | Salida de `flutter test` |
| ACT-05 | Actividades | Agrupar itinerario por día | Varias actividades en fechas diferentes | Abrir detalle | Las actividades aparecen agrupadas cronológicamente | Cubierto por `test/itinerario_actividades_test.dart` | Cubierto por test | Captura con dos o más días |
| ACT-06 | Actividades | Marcar actividad completada | Existe actividad pendiente | Pulsar checkbox | El estado se persiste y se muestra como completada | Cubierto por tests; comportamiento probado durante desarrollo | Cubierto por test | Captura antes/después |
| ACT-07 | Actividades | Editar actividad | Existe actividad | Abrir opciones, editar y guardar | Los cambios aparecen en el itinerario | Cubierto por pruebas existentes | Cubierto por test | Capturas antes/después |
| ACT-08 | Actividades | Eliminar actividad con confirmación | Existe actividad | Elegir eliminar y confirmar | La actividad desaparece; si era la última aparece estado vacío | Cubierto por `test/actividades_flujo_integral_test.dart` | Cubierto por test | Captura de confirmación + estado final |
| PREF-01 | Preferencias | Cambiar tema a oscuro | Usuario autenticado | Perfil → Apariencia → Oscuro | Toda la app usa `ThemeMode.dark` | Probado manualmente durante desarrollo y cubierto por test | Validado manualmente | Captura del tema oscuro |
| PREF-02 | Preferencias | Persistir tema tras reinicio | Tema oscuro seleccionado | Cerrar y volver a abrir la app | La preferencia se recupera | Cubierto por `test/preferencias_reinicio_test.dart` y prueba manual previa | Validado manualmente | Captura antes/después del reinicio |
| PREF-03 | Preferencias | Volver a tema del sistema | Preferencia de tema personalizada | Seleccionar `Sistema` | Se elimina la preferencia explícita y se respeta el dispositivo | Cubierto por test | Cubierto por test | Salida de test o captura |
| PREF-04 | Preferencias | Cambiar a Fahrenheit | Usuario autenticado | Perfil → Unidad → Fahrenheit | Explorar muestra temperaturas en °F | Probado durante desarrollo y cubierto por tests | Validado manualmente | Captura de Perfil + clima en °F |
| PREF-05 | Preferencias | Persistir Fahrenheit | Fahrenheit seleccionado | Reiniciar app | La unidad sigue en Fahrenheit | Cubierto por `test/preferencias_reinicio_test.dart` | Cubierto por test | Captura después del reinicio |
| PREF-06 | Preferencias | Cambiar unidad sin repetir API | Clima ya cargado | Cambiar estado de unidad | Se actualizan valores visibles sin repetir la consulta | Cubierto por `test/integracion_unidades_clima_test.dart` | Cubierto por test | Salida de `flutter test` |
| API-01 | Open-Meteo | Consultar clima por ciudad | Internet disponible | Explorar → escribir `Tarija, Bolivia` → consultar | Se encuentra ubicación y se muestra clima actual + pronóstico | Probado manualmente durante el desarrollo | Validado manualmente | Captura de resultado real |
| API-02 | Open-Meteo | Consultar otra ciudad | Internet disponible | Escribir un destino distinto | Se muestran datos correspondientes a la nueva ubicación | Se indicó que las pruebas manuales del bloque funcionaron | Validado manualmente | Captura de segunda ciudad |
| API-03 | Open-Meteo | Destino inexistente | Internet disponible | Escribir un lugar sin resultados | Se muestra estado de error/sin ubicación, sin inventar clima | Cubierto por tests; repetir manualmente | Cubierto por test | Captura del estado de error |
| API-04 | Open-Meteo | Estado de carga | Consulta iniciada | Pulsar consultar | Se muestra indicador mientras espera la respuesta | Cubierto por widget test | Cubierto por test | Salida de test o captura |
| API-05 | Open-Meteo | Error de red/servicio | API no disponible o fuente falsa en test | Consultar | Se muestra mensaje comprensible y opción de reintento | Cubierto por tests | Cubierto por test | Salida de `flutter test` |
| GEO-01 | Geolocalización | Usar ubicación actual | Permiso disponible y ubicación activa | Explorar → `Usar mi ubicación` | Se obtienen coordenadas y se consulta Open-Meteo | Flujo general probado en desarrollo; Android real queda pendiente | Pendiente | Captura/video en Android |
| GEO-02 | Geolocalización | Permiso denegado | Permiso no concedido | Pulsar `Usar mi ubicación` y negar | La app informa el problema y permite reintentar | Cubierto por pruebas automatizadas | Cubierto por test | Evidencia en Android |
| GEO-03 | Geolocalización | Permiso bloqueado | Permiso denegado permanentemente | Intentar usar ubicación | Se ofrece `Abrir configuración de la app` | Cubierto por widget test | Cubierto por test | Evidencia en Android |
| GEO-04 | Geolocalización | Servicio desactivado | GPS/ubicación apagada | Pulsar `Usar mi ubicación` | Se ofrece abrir configuración de ubicación | Cubierto por widget test | Cubierto por test | Evidencia en Android |
| GEO-05 | Geolocalización | Tiempo de espera agotado | Fuente de ubicación tarda demasiado | Solicitar posición | Se muestra error recuperable | Cubierto por `test/servicio_geolocalizacion_test.dart` | Cubierto por test | Salida de `flutter test` |
| GEO-06 | Geolocalización | No consultar clima si falla ubicación | Error antes de obtener coordenadas | Solicitar clima por ubicación | Open-Meteo no debe ser llamado | Cubierto por `test/servicio_clima_ubicacion_errores_test.dart` | Cubierto por test | Salida de `flutter test` |
| REL-01 | Android Release | Ejecutar app en Android | Android SDK y dispositivo/emulador configurados | `flutter run --release` | La aplicación inicia sin errores en Android | Todavía no ejecutado | Pendiente | Captura/video del dispositivo |
| REL-02 | Android Release | Permisos reales de ubicación | APK/app ejecutándose en Android | Usar ubicación por primera vez | Android muestra permiso y la app responde correctamente | Todavía no ejecutado | Pendiente | Capturas del diálogo y resultado |
| REL-03 | Android Release | Construir APK Release | Entorno Android listo | `flutter build apk --release` | Se genera `app-release.apk` correctamente | Todavía no ejecutado | Pendiente | Consola + archivo generado |
| REL-04 | Android Release | Instalar APK fuera del IDE | APK Release generado | Instalar manualmente en Android | La aplicación instala, abre y funciona | Todavía no ejecutado | Pendiente | Captura de instalación + app |
| REL-05 | Android Release | Construir AAB firmado | Signing configurado | `flutter build appbundle` | Se genera `app.aab` firmado | Todavía no ejecutado | Pendiente | Consola + archivo generado |
| REL-06 | Calidad | Análisis estático final | Rama final preparada | Ejecutar `flutter analyze` | Sin problemas pendientes | Se ha ejecutado durante el desarrollo; repetir al cierre | Pendiente | Archivo/captura de salida final |
| REL-07 | Calidad | Suite automatizada final | Rama final preparada | Ejecutar `flutter test` | Todos los tests pasan | Se ha ejecutado durante el desarrollo; repetir al cierre | Pendiente | Archivo/captura de salida final |

## Pruebas automatizadas existentes

La suite del proyecto contiene pruebas específicas para, entre otros:

```text
autenticación
navegación
modelo y CRUD de viajes
validaciones de viajes
detalle y edición
eliminación de viajes
modelo y gestión de actividades
validaciones de actividades
itinerario
persistencia local
apariencia
unidades
Open-Meteo
geolocalización
integración clima + ubicación
estados de error
```

La cantidad total de tests no se fija en este documento porque puede cambiar
con nuevos commits. La cifra válida para la entrega debe obtenerse de la
ejecución final real de:

```powershell
flutter test
```

## Procedimiento de cierre de la matriz

Antes de entregar:

1. ejecutar `flutter analyze`;
2. ejecutar `flutter test`;
3. ejecutar los casos manuales de las funciones principales;
4. repetir los casos específicos de Android en un dispositivo o emulador;
5. guardar evidencias en la estructura definida para el proyecto;
6. completar `Resultado obtenido actual`;
7. cambiar a `Aprobado final` únicamente los casos realmente ejecutados;
8. registrar como `Fallido` cualquier caso que no cumpla lo esperado y
   corregirlo antes del release.

No deben fabricarse capturas, salidas de consola ni estados de aprobación.
