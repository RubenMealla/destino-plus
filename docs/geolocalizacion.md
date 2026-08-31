# Geolocalización en Destino+

Destino+ incorpora geolocalización para utilizar la posición actual del
dispositivo en funciones relacionadas con viajes y clima.

## Tecnología

La integración utiliza:

```text
geolocator
```

La aplicación no llama directamente al plugin desde las pantallas.

```text
PantallaExplorar
      |
      +-- ServicioClimaUbicacionActual
      |       |
      |       +-- ServicioGeolocalizacion
      |       |       |
      |       |       +-- geolocator
      |       |
      |       +-- ServicioClimaDestino
      |               |
      |               +-- Open-Meteo
      |
      +-- AccionesConfiguracionUbicacion
              |
              +-- geolocator
```

## Permisos Android

`android/app/src/main/AndroidManifest.xml` declara:

```text
android.permission.INTERNET
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_FINE_LOCATION
```

`INTERNET` permite que las compilaciones Android release utilicen Supabase y
Open-Meteo.

Los permisos de ubicación se utilizan únicamente para una acción iniciada por
el usuario: `Usar mi ubicación`.

No se solicita:

```text
ACCESS_BACKGROUND_LOCATION
```

porque Destino+ no realiza seguimiento en segundo plano.

El GPS se declara como hardware no obligatorio para evitar convertirlo en un
requisito de instalación.

## Flujo de ubicación actual

Al seleccionar `Usar mi ubicación`:

1. se comprueba que el servicio de ubicación esté activo;
2. se verifica o solicita permiso;
3. se obtiene la posición;
4. se conserva temporalmente la precisión informada;
5. se envían latitud y longitud a Open-Meteo;
6. la interfaz presenta el clima y el pronóstico.

## Estados y recuperación

Los errores se representan mediante `TipoErrorUbicacion`.

### Servicio de ubicación desactivado

La interfaz ofrece:

```text
Abrir configuración de ubicación
```

### Permiso denegado

La interfaz permite volver a intentar la solicitud:

```text
Reintentar permiso
```

### Permiso bloqueado permanentemente

La aplicación ya no intenta mostrar repetidamente el diálogo del sistema y
ofrece:

```text
Abrir configuración de la app
```

### Tiempo agotado o posición no disponible

La interfaz ofrece:

```text
Reintentar ubicación
```

Las acciones de configuración están desacopladas mediante
`AccionesConfiguracionUbicacion`, por lo que pueden sustituirse por
implementaciones falsas durante pruebas de widgets.

## Privacidad

La posición actual:

- no se guarda en Supabase;
- no se almacena en `shared_preferences`;
- no se añade al perfil del usuario;
- no se obtiene en segundo plano;
- se usa temporalmente cuando el usuario solicita consultar su clima.

## Validación pendiente de plataforma

Las pruebas automatizadas verifican la lógica y los estados de interfaz.

La validación definitiva del diálogo de permisos, ubicación desactivada,
configuración del sistema y lectura GPS debe realizarse posteriormente en un
dispositivo o emulador Android real antes de la entrega release.
