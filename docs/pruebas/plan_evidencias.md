# Plan de evidencias de Destino+

Este documento define cómo reunir y organizar las evidencias técnicas y
funcionales del proyecto antes de la entrega final.

Su objetivo es evitar capturas aisladas, nombres ambiguos o pruebas sin
relación con los requisitos del diplomado.

## Regla principal

Una evidencia debe demostrar un estado o resultado real del proyecto.

No se deben:

- fabricar capturas;
- editar una salida de consola para aparentar éxito;
- marcar una prueba como aprobada si no fue ejecutada;
- incluir contraseñas, tokens, claves privadas o archivos de configuración
  local;
- guardar capturas que expongan credenciales de Supabase.

La matriz de pruebas funcionales se encuentra en:

```text
docs/pruebas/matriz_pruebas_funcionales.md
```

Las evidencias se almacenarán en:

```text
evidencias/
```

## Estructura prevista

```text
evidencias/
├── 01_entorno/
├── 02_autenticacion/
├── 03_navegacion/
├── 04_viajes_actividades/
├── 05_integraciones/
├── 06_pruebas/
├── 07_release_android/
└── 08_monitoreo/
```

Las carpetas pueden permanecer vacías hasta que exista evidencia real.

## Convención de nombres

Formato recomendado:

```text
NN_descripcion_corta.ext
```

Ejemplos:

```text
01_flutter_doctor.png
02_login.png
03_registro_validacion.png
04_lista_viajes.png
05_detalle_itinerario.png
06_clima_tarija.png
07_flutter_test.png
08_apk_instalado.png
```

Usar:

- minúsculas;
- guion bajo;
- nombres descriptivos;
- numeración para conservar orden.

No usar nombres como:

```text
captura1.png
imagen_final.png
prueba_nueva.png
```

porque no explican qué se está demostrando.

## 01_entorno

Objetivo: demostrar el entorno utilizado para desarrollar y compilar.

Evidencias recomendadas:

```text
evidencias/01_entorno/
├── 01_flutter_version.png
├── 02_flutter_doctor.png
├── 03_git_version.png
└── 04_estructura_proyecto.png
```

### 01_flutter_version.png

Ejecutar:

```powershell
flutter --version
```

Debe mostrar la versión real usada para la entrega.

### 02_flutter_doctor.png

Ejecutar:

```powershell
flutter doctor -v
```

La captura final debe realizarse cuando Android esté configurado.

No usar como evidencia final una salida que todavía muestre componentes
obligatorios sin instalar.

### 03_git_version.png

Ejecutar:

```powershell
git --version
```

### 04_estructura_proyecto.png

Mostrar una vista limpia del proyecto o del repositorio donde se aprecien
carpetas como:

```text
lib/
test/
docs/
android/
supabase/
```

No incluir archivos privados.

## 02_autenticacion

Objetivo: demostrar que el acceso y registro funcionan con Supabase.

Evidencias sugeridas:

```text
evidencias/02_autenticacion/
├── 01_inicio_sesion.png
├── 02_validacion_login.png
├── 03_registro.png
├── 04_usuario_autenticado.png
└── 05_cierre_sesion.png
```

### Capturas importantes

`01_inicio_sesion.png`
: pantalla de acceso limpia.

`02_validacion_login.png`
: ejemplo de mensajes de validación.

`03_registro.png`
: formulario de registro.

`04_usuario_autenticado.png`
: una pantalla posterior al acceso que demuestre sesión iniciada.

`05_cierre_sesion.png`
: estado posterior a cerrar sesión.

No es necesario mostrar contraseñas ni datos personales reales.

Puede utilizarse un usuario de prueba creado exclusivamente para la defensa.

## 03_navegacion

Objetivo: demostrar la integración entre las pantallas principales.

Evidencias sugeridas:

```text
evidencias/03_navegacion/
├── 01_inicio.png
├── 02_viajes.png
├── 03_explorar.png
└── 04_perfil.png
```

Las cuatro capturas deben dejar visible, cuando sea posible, la navegación
principal:

```text
Inicio
Viajes
Explorar
Perfil
```

Esto ayuda a demostrar que no son pantallas aisladas.

## 04_viajes_actividades

Objetivo: demostrar el CRUD principal de la aplicación y el itinerario.

Evidencias sugeridas:

```text
evidencias/04_viajes_actividades/
├── 01_viajes_estado_vacio.png
├── 02_crear_viaje.png
├── 03_lista_viajes.png
├── 04_detalle_viaje.png
├── 05_editar_viaje.png
├── 06_confirmar_eliminar_viaje.png
├── 07_itinerario_vacio.png
├── 08_crear_actividad.png
├── 09_itinerario_por_dias.png
├── 10_actividad_completada.png
└── 11_confirmar_eliminar_actividad.png
```

No es obligatorio conservar todas si varias funciones pueden demostrarse
claramente en una misma captura, pero el conjunto final debe permitir
comprobar:

- crear;
- leer;
- actualizar;
- eliminar;
- validaciones;
- actividades asociadas al viaje;
- agrupación por día;
- estado completado.

## 05_integraciones

Objetivo: demostrar las integraciones externas y locales.

Evidencias sugeridas:

```text
evidencias/05_integraciones/
├── 01_clima_tarija.png
├── 02_clima_otro_destino.png
├── 03_clima_error_destino.png
├── 04_tema_oscuro.png
├── 05_temperatura_fahrenheit.png
├── 06_ubicacion_actual_android.png
├── 07_permiso_ubicacion_android.png
└── 08_configuracion_ubicacion_android.png
```

### Open-Meteo

`01_clima_tarija.png`
: consulta real de ejemplo.

`02_clima_otro_destino.png`
: segunda consulta que demuestre que los datos no son estáticos.

`03_clima_error_destino.png`
: estado de error o ausencia de resultados.

### Preferencias locales

`04_tema_oscuro.png`
: app usando la preferencia de apariencia.

`05_temperatura_fahrenheit.png`
: clima mostrado en Fahrenheit.

### Geolocalización

Las evidencias `06`, `07` y `08` deben tomarse posteriormente en Android.

Chrome puede utilizarse durante desarrollo, pero no sustituye la evidencia
final del permiso Android.

## 06_pruebas

Objetivo: demostrar calidad técnica y pruebas ejecutadas.

Evidencias recomendadas:

```text
evidencias/06_pruebas/
├── 01_flutter_analyze.png
├── 02_flutter_test.png
├── 03_git_log.png
└── 04_github_branches_pr.png
```

### flutter analyze

Ejecutar:

```powershell
flutter analyze
```

La captura debe mostrar el resultado final real.

### flutter test

Ejecutar:

```powershell
flutter test
```

Debe mostrarse la ejecución final completa o, como mínimo, el resumen que
confirme que la suite terminó correctamente.

No escribir manualmente en la documentación una cantidad de tests que no
coincida con la salida real.

### Historial Git

Comando recomendado:

```powershell
git --no-pager log --oneline --decorate --graph --all
```

La evidencia debe permitir apreciar:

- `main`;
- ramas feature;
- ramas de tests/docs;
- merges;
- commits significativos.

### GitHub

Puede guardarse una captura de Pull Requests y ramas si ayuda a demostrar el
flujo de trabajo.

No es necesario eliminar ramas fusionadas.

## 07_release_android

Objetivo: demostrar que el proyecto fue entregado como aplicación Android real.

Esta carpeta se completa al final.

Evidencias previstas:

```text
evidencias/07_release_android/
├── 01_dispositivo_detectado.png
├── 02_flutter_run_release.png
├── 03_permiso_ubicacion.png
├── 04_app_android_funcionando.png
├── 05_build_apk_release.png
├── 06_apk_generado.png
├── 07_instalacion_fuera_ide.png
├── 08_app_instalada.png
├── 09_build_aab.png
├── 10_aab_generado.png
├── 11_sha256_apk.txt
└── 12_sha256_aab.txt
```

### Comandos previstos

Antes del release final:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

Prueba en Android:

```powershell
flutter run --release
```

APK:

```powershell
flutter build apk --release
```

Ruta esperada:

```text
build/app/outputs/flutter-apk/app-release.apk
```

AAB:

```powershell
flutter build appbundle
```

Ruta esperada:

```text
build/app/outputs/bundle/release/app.aab
```

Las rutas deben verificarse realmente en el momento de generar los archivos.

### Hash SHA-256

En PowerShell:

```powershell
Get-FileHash build/app/outputs/flutter-apk/app-release.apk -Algorithm SHA256
Get-FileHash build/app/outputs/bundle/release/app.aab -Algorithm SHA256
```

Guardar las salidas reales en los archivos `.txt` correspondientes.

## 08_monitoreo

Esta carpeta queda reservada para evidencia de monitoreo si finalmente se
integra una solución como analytics o Crashlytics.

Estructura prevista:

```text
evidencias/08_monitoreo/
```

No crear capturas simuladas de servicios de monitoreo.

Si la función no llega a implementarse, debe documentarse de forma honesta
como limitación o trabajo futuro según corresponda.

## Qué debe aparecer en una captura

Una captura útil debe:

- estar enfocada en el comportamiento que se quiere demostrar;
- mostrar suficiente contexto para identificar Destino+;
- evitar ventanas innecesarias;
- ser legible;
- no exponer secretos;
- corresponder a la versión que se entregará.

## Qué no debe aparecer

Evitar:

- contraseñas;
- claves privadas;
- `service_role`;
- contenido de `config/supabase.local.json`;
- tokens de sesión;
- información personal innecesaria;
- notificaciones privadas del escritorio;
- otras aplicaciones sin relación con la evidencia.

## Relación con la matriz de pruebas

Cada evidencia final debe asociarse a uno o más IDs de:

```text
docs/pruebas/matriz_pruebas_funcionales.md
```

Ejemplo:

```text
evidencias/05_integraciones/01_clima_tarija.png
→ API-01
```

Una misma captura puede demostrar más de un caso si es claramente verificable.

## Momento correcto para capturar

No conviene capturar todo ahora.

Durante el desarrollo:

- ejecutar pruebas;
- corregir errores;
- mantener documentación.

Cuando la funcionalidad esté consolidada:

- ejecutar la matriz final;
- tomar capturas consistentes;
- registrar resultado obtenido;
- guardar evidencia.

Para Android Release, las evidencias deben tomarse después de configurar el
SDK, firma y dispositivo de prueba.

## Resultado esperado al finalizar

La estructura final debería permitir a otra persona recorrer:

```text
requisito
   ↓
caso de prueba
   ↓
resultado
   ↓
evidencia
   ↓
conclusión
```

sin depender únicamente de una explicación oral.
