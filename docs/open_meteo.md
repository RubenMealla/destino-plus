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

## Consulta por destino

`ServicioClimaDestino` conecta ambos endpoints.

Ejemplo conceptual:

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

El servicio normaliza el texto, busca hasta ocho opciones y selecciona la que
mejor coincide con las palabras del destino guardado.

Si una consulta como:

```text
Tarija, Bolivia
```

no devuelve resultados, se intenta una segunda búsqueda con:

```text
Tarija
```

Esto permite trabajar mejor con destinos escritos de distintas formas por el
usuario.

Si no existe ninguna ubicación compatible, se genera `ExcepcionClima` con un
mensaje que la interfaz podrá mostrar sin inventar datos meteorológicos.

## Arquitectura

```text
Pantalla / estado de interfaz
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

La interfaz visual y sus estados de `loading`, error, ausencia de resultados
y respuesta correcta se incorporarán en el siguiente commit.

## Errores

`ClienteOpenMeteo` convierte problemas de red, respuestas HTTP no exitosas y
formatos JSON inesperados en `ExcepcionClima`.

`ServicioClimaDestino` agrega errores propios de búsqueda, por ejemplo cuando
no se encuentra una ubicación para el texto escrito.

## Credenciales

La API pública de Open-Meteo utilizada en esta etapa no requiere almacenar
una clave API en Destino+.

Supabase continúa utilizando su configuración independiente mediante
`config/supabase.local.json`.
