# Geolocalización en Destino+

Destino+ incorpora geolocalización para poder utilizar la posición actual del
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
              |
              +-- FuenteUbicacionActual
              |       |
              |       +-- ServicioGeolocalizacion
              |               |
              |               +-- geolocator
              |
              +-- FuenteClimaCoordenadas
                      |
                      +-- ServicioClimaDestino
                              |
                              +-- Open-Meteo
```

## Flujo de ubicación actual

Al seleccionar `Usar mi ubicación`:

1. Destino+ comprueba que el servicio de ubicación esté activo;
2. verifica o solicita permiso;
3. obtiene las coordenadas actuales;
4. conserva temporalmente la precisión informada por la plataforma;
5. envía latitud y longitud al servicio meteorológico;
6. Open-Meteo devuelve el clima correspondiente a esas coordenadas;
7. la pantalla muestra clima actual y pronóstico.

No es necesario convertir primero las coordenadas a un nombre de ciudad para
consultar el clima.

En esta etapa la interfaz identifica el resultado como:

```text
Mi ubicación actual
```

y muestra también la precisión aproximada de la lectura GPS o de red.

## Modelo de dominio

`UbicacionActual` conserva:

```text
latitud
longitud
precisionMetros
fechaHora
```

Los errores se normalizan mediante `ExcepcionUbicacion` y
`TipoErrorUbicacion`.

## Permisos de plataforma

La lógica para solicitar permisos ya existe.

La declaración de permisos Android y las acciones específicas ante estados
como permiso bloqueado o servicio de ubicación desactivado se completarán en
el último commit de esta rama.

Destino+ solo necesita ubicación mientras la aplicación está en uso. No se
realiza seguimiento en segundo plano.

## Privacidad

La posición actual:

- no se guarda en Supabase;
- no se almacena en `shared_preferences`;
- no se añade al perfil del usuario;
- se utiliza temporalmente para la consulta solicitada.

Los datos meteorológicos continúan obteniéndose mediante Open-Meteo.
