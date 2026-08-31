# Integración de clima con Open-Meteo

Destino+ utiliza Open-Meteo como API pública para consultar ubicaciones y
pronósticos meteorológicos.

## Servicios utilizados

### Geocodificación

Endpoint:

```text
https://geocoding-api.open-meteo.com/v1/search
```

Destino+ envía:

```text
name
count
language=es
format=json
```

El resultado se transforma a `UbicacionClima`, que conserva nombre,
coordenadas, país, región y zona horaria.

### Pronóstico

Endpoint:

```text
https://api.open-meteo.com/v1/forecast
```

El cliente solicita condiciones actuales y siete días de pronóstico:

```text
current:
- temperature_2m
- relative_humidity_2m
- apparent_temperature
- is_day
- weather_code
- wind_speed_10m

daily:
- weather_code
- temperature_2m_max
- temperature_2m_min
- precipitation_probability_max

timezone=auto
forecast_days=7
```

## Consulta por destino

`ServicioClimaDestino` conecta geocodificación y pronóstico.

```text
"Tarija, Bolivia"
        |
        v
buscarUbicaciones()
        |
        v
UbicacionClima
        |
        v
obtenerPronostico()
        |
        v
ClimaDestino
```

El servicio intenta seleccionar la ubicación que mejor coincide con ciudad,
región y país. Si la consulta completa no devuelve resultados y contiene una
coma, intenta nuevamente con la primera parte.

## Integración en la interfaz

La pestaña `Explorar` ya consume `FuenteClimaDestino`.

El usuario puede escribir un destino, por ejemplo:

```text
Tarija, Bolivia
```

La pantalla contempla cuatro estados funcionales:

```text
inicial
cargando
error / sin ubicación
respuesta correcta
```

La respuesta correcta presenta:

- ubicación encontrada;
- temperatura actual;
- sensación térmica;
- humedad relativa;
- velocidad del viento;
- descripción de las condiciones;
- máximas y mínimas diarias;
- probabilidad de precipitación;
- siete días de pronóstico cuando están disponibles;
- zona horaria devuelta por Open-Meteo.

Los códigos meteorológicos se traducen a textos e iconos desde
`ClimaVisual`.

## Arquitectura

```text
PantallaExplorar
        |
        +-- FuenteClimaDestino
                |
                +-- ServicioClimaDestino
                        |
                        +-- FuenteClimaRemota
                                |
                                +-- ClienteOpenMeteo
                                        |
                                        +-- Geocodificación
                                        +-- Pronóstico
```

Las interfaces `FuenteClimaDestino` y `FuenteClimaRemota` permiten probar la
interfaz y la lógica sin depender de Internet.

## Errores

La aplicación no inventa información meteorológica cuando falla una
consulta.

Problemas de red, respuestas HTTP no exitosas, JSON inesperado y ubicaciones
sin resultados se muestran como estados de error con opción de reintento.

## Credenciales

La API pública de Open-Meteo utilizada en esta etapa no requiere almacenar
una clave API en Destino+.

Supabase continúa utilizando su configuración independiente mediante
`config/supabase.local.json`.
