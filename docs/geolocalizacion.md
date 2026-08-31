# Geolocalización en Destino+

Destino+ incorpora geolocalización para poder utilizar la posición actual del
dispositivo en funciones relacionadas con viajes y clima.

## Tecnología

La integración utiliza:

```text
geolocator
```

La aplicación no llama directamente al plugin desde las pantallas.

La arquitectura inicial es:

```text
Interfaz
   |
   +-- ServicioGeolocalizacion
           |
           +-- FuenteGeolocalizacion
                   |
                   +-- FuenteGeolocalizacionGeolocator
                           |
                           +-- geolocator
```

Esto permite sustituir la plataforma por una fuente falsa durante las pruebas
automatizadas.

## Flujo del servicio

`ServicioGeolocalizacion.obtenerUbicacionActual()` realiza:

1. comprobar si el servicio de ubicación está activo;
2. comprobar el permiso actual;
3. solicitar permiso si todavía está denegado;
4. detenerse si el permiso se mantiene denegado o está bloqueado;
5. obtener una posición actual;
6. convertir la respuesta del plugin a `UbicacionActual`.

La lectura utiliza precisión alta y un límite de espera de 15 segundos.

## Modelo de dominio

`UbicacionActual` conserva únicamente los datos que Destino+ necesita en esta
etapa:

```text
latitud
longitud
precisionMetros
fechaHora
```

Los errores se normalizan mediante `ExcepcionUbicacion` y
`TipoErrorUbicacion`:

```text
servicioDeshabilitado
permisoDenegado
permisoDenegadoPermanentemente
tiempoAgotado
noDisponible
```

## Permisos de plataforma

Este primer commit prepara la lógica y las pruebas.

La declaración explícita de permisos de Android y la experiencia visual para
los distintos estados se incorporarán antes de cerrar la rama.

Destino+ solo necesita ubicación mientras la aplicación está en uso. No se
planea seguimiento de ubicación en segundo plano.

## Privacidad

La posición actual no se persiste en Supabase ni en `shared_preferences` en
esta etapa.

Se utilizará de forma temporal para funciones solicitadas por el usuario,
como consultar el clima correspondiente a su ubicación actual.
