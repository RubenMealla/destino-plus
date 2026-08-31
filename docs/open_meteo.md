# Integración de clima con Open-Meteo

Destino+ utiliza Open-Meteo como API pública para consultar ubicaciones y
pronósticos meteorológicos.

## Servicios utilizados

### Geocodificación

Endpoint:

```text
https://geocoding-api.open-meteo.com/v1/search
```

Destino+ envía inicialmente:

```text
name
count
language=es
format=json
```

El resultado se transforma a `UbicacionClima`, que conserva:

- nombre;
- latitud;
- longitud;
- país;
- código de país;
- región;
- zona horaria.

### Pronóstico

Endpoint:

```text
https://api.open-meteo.com/v1/forecast
```

El cliente solicita:

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

Las variables diarias requieren una zona horaria. `timezone=auto` permite que
Open-Meteo resuelva la zona correspondiente a las coordenadas.

## Arquitectura

```text
ClienteOpenMeteo
    |
    +-- buscarUbicaciones()
    |
    +-- obtenerPronostico()
            |
            +-- PronosticoClima
                    |
                    +-- ClimaActual
                    +-- PronosticoDiario
```

La interfaz todavía no consume este cliente en el primer commit de la rama.
La integración con destinos y los estados de carga/error se implementará en
los siguientes commits.

## Errores

`ClienteOpenMeteo` convierte problemas de red, respuestas HTTP no exitosas y
formatos JSON inesperados en `ExcepcionClima` con mensajes comprensibles para
la aplicación.

## Credenciales

La API pública de Open-Meteo utilizada en esta etapa no requiere almacenar
una clave API en Destino+.

Supabase continúa utilizando su configuración independiente mediante
`config/supabase.local.json`.
