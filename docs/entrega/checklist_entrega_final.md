# Checklist de entrega final de Destino+

Este documento organiza el cierre del proyecto antes de la entrega académica.

Debe utilizarse como lista de control real. Un elemento solo debe marcarse
como completado cuando haya sido ejecutado y comprobado.

## Convención

```text
[ ] Pendiente
[x] Completado y verificado
```

No convertir un elemento en `[x]` únicamente porque el código exista.

## 1. Funcionalidad principal

### Autenticación

- [x] Registro implementado con Supabase Auth.
- [x] Inicio de sesión implementado.
- [x] Estado de sesión integrado.
- [x] Rutas privadas protegidas.
- [x] Cierre de sesión implementado.
- [x] Validaciones de formularios cubiertas por pruebas.
- [ ] Repetir flujo completo en la versión Android final.

### Navegación

- [x] Inicio.
- [x] Viajes.
- [x] Explorar.
- [x] Perfil.
- [x] Navegación entre pantallas principales probada.
- [x] Rutas desconocidas manejadas.
- [ ] Revisión visual final en Android.

### Viajes

- [x] Crear viaje.
- [x] Listar viajes.
- [x] Abrir detalle.
- [x] Editar viaje.
- [x] Eliminar viaje.
- [x] Validar fechas.
- [x] Estados vacío, carga y error.
- [ ] Ejecutar CRUD completo manualmente sobre Android Release.

### Actividades

- [x] Crear actividad.
- [x] Editar actividad.
- [x] Eliminar actividad.
- [x] Confirmación antes de eliminar.
- [x] Marcar pendiente/completada.
- [x] Agrupar actividades por día.
- [x] Validar que la actividad pertenezca al rango del viaje.
- [ ] Ejecutar flujo completo manualmente sobre Android Release.

## 2. Integraciones

### Supabase

- [x] Supabase Auth integrado.
- [x] Persistencia de viajes.
- [x] Persistencia de actividades.
- [x] Row Level Security preparada para datos del usuario.
- [x] Migraciones versionadas.
- [x] Configuración real excluida de Git.
- [ ] Confirmar funcionamiento final desde Android Release.

### Open-Meteo

- [x] Búsqueda de ubicación por texto.
- [x] Consulta de clima actual.
- [x] Pronóstico diario.
- [x] Estados de carga y error.
- [x] Consulta por coordenadas.
- [x] Pruebas automatizadas.
- [x] Pruebas manuales durante desarrollo.
- [ ] Captura final consistente con la versión entregada.

### Geolocalización

- [x] Servicio de geolocalización.
- [x] Manejo de permisos en la lógica.
- [x] Manejo de servicio desactivado.
- [x] Manejo de permiso bloqueado.
- [x] Manejo de timeout/no disponible.
- [x] Permisos declarados en AndroidManifest.
- [x] Sin permiso de ubicación en segundo plano.
- [ ] Probar diálogo real de permiso en Android.
- [ ] Probar ubicación concedida en Android.
- [ ] Probar permiso denegado en Android.
- [ ] Probar acceso a configuración en Android.

### Preferencias locales

- [x] Tema Sistema/Claro/Oscuro.
- [x] Persistencia del tema.
- [x] Celsius/Fahrenheit.
- [x] Persistencia de unidad.
- [x] Conversión visible en clima.
- [x] Pruebas automatizadas de reinicio simulado.
- [ ] Reconfirmar persistencia en Android Release.

### Monitoreo

- [x] `sentry_flutter` integrado.
- [x] Inicio condicional según DSN.
- [x] Aplicación funcional sin Sentry.
- [x] PII predeterminada deshabilitada.
- [x] Screenshots automáticos deshabilitados.
- [x] View hierarchy deshabilitada.
- [x] Evento controlado bloqueado en `production`.
- [x] Evento real enviado desde Destino+.
- [x] Evento real recibido en Sentry.
- [x] Evidencia real guardada.
- [x] `SENTRY_TEST_EVENT` vuelto a `false` en configuración local.
- [ ] Confirmar monitoreo con configuración de release si se decide incluirlo
  en la versión final.

## 3. Pruebas y calidad

### Durante desarrollo

- [x] Se han ejecutado `flutter analyze` durante los bloques.
- [x] Se han ejecutado `flutter test` durante los bloques.
- [x] Se ampliaron pruebas de autenticación y navegación.
- [x] Se ampliaron pruebas de viajes y actividades.
- [x] Se probaron preferencias, clima y ubicación.
- [x] Se probaron componentes del monitoreo.

### Ejecución final obligatoria

Estas comprobaciones deben realizarse sobre la rama/version final que se
entregará:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

Checklist:

- [ ] `flutter clean` ejecutado.
- [ ] `flutter pub get` ejecutado.
- [ ] `flutter analyze` final sin problemas.
- [ ] `flutter test` final aprobado.
- [ ] Resultado real de `flutter analyze` guardado como evidencia.
- [ ] Resultado real de `flutter test` guardado como evidencia.
- [ ] Cantidad final de tests registrada únicamente a partir de la salida real.

Evidencias previstas:

```text
evidencias/06_pruebas/01_flutter_analyze.png
evidencias/06_pruebas/02_flutter_test.png
```

## 4. Git y repositorio

- [x] Repositorio Git creado.
- [x] Rama principal `main`.
- [x] Desarrollo por ramas.
- [x] Commits significativos.
- [x] Pull Requests para bloques importantes.
- [x] Merge commits utilizados para conservar historial.
- [x] Ramas fusionadas conservadas.
- [x] Configuraciones locales ignoradas.
- [x] Keystores/archivos de firma excluidos mediante `.gitignore`.
- [ ] Capturar historial Git final.
- [ ] Capturar ramas/PR relevantes en GitHub.
- [ ] Verificar que el árbol de trabajo final esté limpio.
- [ ] Crear tag final `v1.0.0` únicamente después de validar el release.

Comprobaciones:

```powershell
git status
git --no-pager diff --check
git --no-pager log --oneline --decorate --graph --all
```

Evidencias:

```text
evidencias/06_pruebas/03_git_log.png
evidencias/06_pruebas/04_github_branches_pr.png
```

## 5. Documentación

- [x] README de Destino+.
- [x] Arquitectura.
- [x] Instalación y ejecución.
- [x] Documentación de Open-Meteo.
- [x] Documentación de geolocalización.
- [x] Documentación de preferencias.
- [x] Documentación de monitoreo.
- [x] Matriz de pruebas.
- [x] Plan de evidencias.
- [x] Trazabilidad de requisitos.
- [x] Checklist de cierre.
- [ ] Revisar enlaces y rutas después del release.
- [ ] Actualizar README con resultados reales del APK/AAB.
- [ ] Actualizar trazabilidad de elementos pendientes a completados cuando
  corresponda.

## 6. Configuración Android

Esta es la siguiente fase principal del proyecto.

### Entorno

- [ ] Android SDK instalado.
- [ ] Platform Tools instaladas.
- [ ] Licencias Android aceptadas.
- [ ] `flutter doctor -v` sin bloqueo para Android.
- [ ] Dispositivo Android físico o emulador disponible.
- [ ] `flutter devices` detecta el dispositivo.

Comandos:

```powershell
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```

No continuar a la entrega final si Flutter no puede construir y ejecutar la
aplicación en Android.

## 7. Identidad Android

Antes del release revisar:

- [ ] Nombre visible: `Destino+`.
- [ ] `applicationId` definitivo y estable.
- [ ] `version` definitiva del proyecto.
- [ ] Ícono Android final.
- [ ] Permisos mínimos necesarios.
- [ ] No existen permisos innecesarios.
- [ ] Configuraciones de debug no afectan Release.

La versión final prevista del proyecto es:

```text
1.0.0+N
```

El valor exacto de `N` se decidirá y verificará en la fase de release.

No modificar el `applicationId` después de generar artefactos finales sin una
razón explícita, porque Android lo utiliza como identidad de la aplicación.

## 8. Prueba Android Release

Antes de construir los artefactos finales:

```powershell
flutter run --release
```

Checklist:

- [ ] La aplicación inicia.
- [ ] Registro/inicio de sesión funciona.
- [ ] Navegación funciona.
- [ ] CRUD de viajes funciona.
- [ ] Actividades funcionan.
- [ ] Open-Meteo funciona.
- [ ] Preferencias funcionan.
- [ ] Geolocalización funciona.
- [ ] Permisos Android funcionan.
- [ ] No aparecen errores bloqueantes.
- [ ] La interfaz es utilizable en el dispositivo seleccionado.

Caso de la matriz:

```text
REL-01
REL-02
```

## 9. APK Release

Construcción prevista:

```powershell
flutter build apk --release
```

Ruta habitual:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Checklist:

- [ ] Build ejecutado sin errores.
- [ ] `app-release.apk` existe.
- [ ] Tamaño del archivo registrado.
- [ ] Hash SHA-256 generado.
- [ ] APK transferido/instalado fuera del IDE.
- [ ] Aplicación inicia desde el launcher.
- [ ] Flujo principal probado sobre la instalación externa.

Hash:

```powershell
Get-FileHash build/app/outputs/flutter-apk/app-release.apk -Algorithm SHA256
```

Evidencias:

```text
evidencias/07_release_android/05_build_apk_release.png
evidencias/07_release_android/06_apk_generado.png
evidencias/07_release_android/07_instalacion_fuera_ide.png
evidencias/07_release_android/08_app_instalada.png
evidencias/07_release_android/11_sha256_apk.txt
```

## 10. Firma Android

Antes del AAB final:

- [ ] Keystore creado.
- [ ] Keystore almacenado fuera de Git.
- [ ] `android/key.properties` configurado localmente.
- [ ] `android/key.properties` confirmado como ignorado.
- [ ] Contraseñas fuera del repositorio.
- [ ] Gradle utiliza la configuración de firma de release.
- [ ] Firma comprobada.

Nunca versionar:

```text
*.jks
*.keystore
android/key.properties
contraseñas
```

## 11. AAB firmado

Construcción:

```powershell
flutter build appbundle
```

Ruta habitual:

```text
build/app/outputs/bundle/release/app.aab
```

Checklist:

- [ ] Build ejecutado sin errores.
- [ ] AAB generado.
- [ ] AAB firmado.
- [ ] Tamaño registrado.
- [ ] SHA-256 generado.
- [ ] Evidencia guardada.

Hash:

```powershell
Get-FileHash build/app/outputs/bundle/release/app.aab -Algorithm SHA256
```

Evidencias:

```text
evidencias/07_release_android/09_build_aab.png
evidencias/07_release_android/10_aab_generado.png
evidencias/07_release_android/12_sha256_aab.txt
```

## 12. Evidencia funcional final

Revisar:

```text
docs/pruebas/matriz_pruebas_funcionales.md
```

Cada caso obligatorio debe terminar con uno de los estados reales
correspondientes.

Antes de la entrega:

- [ ] Ejecutar casos pendientes.
- [ ] Completar resultado obtenido.
- [ ] Asociar evidencia.
- [ ] Convertir a `Aprobado final` únicamente los casos realmente aprobados.
- [ ] Corregir cualquier caso `Fallido`.
- [ ] No dejar casos obligatorios de release como `Pendiente`.

## 13. Evidencias previstas

Estructura:

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

Ya existe evidencia real del evento de monitoreo.

El resto debe completarse con la versión final para mantener consistencia
visual y técnica.

## 14. Revisión de secretos

Antes del release y antes del último push:

```powershell
git status --short
git ls-files config
```

Comprobar que no estén versionados:

```text
config/supabase.local.json
config/monitoreo.local.json
android/key.properties
*.jks
*.keystore
```

También revisar manualmente que documentación y capturas no revelen:

- DSN completo si se decide ocultarlo en evidencia;
- contraseña;
- tokens;
- `service_role`;
- credenciales de firma;
- información privada innecesaria.

## 15. Versión final

Antes de etiquetar:

- [ ] Cambiar `pubspec.yaml` a versión final.
- [ ] Ejecutar `flutter pub get` si corresponde.
- [ ] Ejecutar análisis y tests.
- [ ] Generar APK y AAB.
- [ ] Instalar y probar APK.
- [ ] Completar evidencias.
- [ ] Actualizar README/documentación.
- [ ] Confirmar `git status` limpio.
- [ ] Fusionar rama de release a `main`.
- [ ] Crear tag `v1.0.0`.
- [ ] Push de `main`.
- [ ] Push del tag.

Tag previsto:

```powershell
git tag -a v1.0.0 -m "Destino+ v1.0.0"
git push origin v1.0.0
```

No crear el tag antes de haber comprobado los artefactos finales.

## 16. Orden recomendado desde este punto

```text
1. terminar documentación final;
2. fusionar docs/final-documentation → main;
3. preparar entorno Android;
4. crear release/1.0.0;
5. fijar versión e identidad Android;
6. configurar firma;
7. ejecutar clean/analyze/test;
8. probar flutter run --release;
9. generar APK Release;
10. instalar APK fuera del IDE;
11. validar funciones principales;
12. generar AAB firmado;
13. calcular hashes;
14. completar matriz y evidencias;
15. actualizar documentación con resultados reales;
16. fusionar release → main;
17. crear tag v1.0.0.
```

## 17. Criterio de proyecto listo para entregar

Destino+ puede considerarse listo únicamente cuando se pueda demostrar:

```text
código funcional
+
tests aprobados
+
análisis estático aprobado
+
backend/API funcionando
+
capacidad nativa probada en Android
+
APK Release instalado y probado
+
AAB firmado
+
historial Git
+
README/documentación
+
evidencias reales
+
monitoreo real
```

Hasta entonces, los elementos pendientes de este checklist deben permanecer
visibles y no presentarse como completados.
