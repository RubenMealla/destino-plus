# Integración de clima con Open-Meteo

Destino+ utiliza Open-Meteo como API pública para consultar ubicaciones y
pronósticos meteorológicos.

## Formas de consulta

La aplicación dispone de dos caminos:

```text
Destino escrito
      |
      +-- Geocodificación
              |
              +-- latitud / longitud
                      |
                      +-- Pronóstico
```

y:

```text
Ubicación actual del dispositivo
      |
      +-- latitud / longitud
              |
              +-- Pronóstico
```

La segunda opción evita una geocodificación innecesaria porque el dispositivo
ya entrega las coordenadas.

## Geocodificación

Endpoint:

```text
https://geocoding-api.open-meteo.com/v1/search
```

Se utiliza para búsquedas manuales por ciudad o destino.

## Pronóstico

Endpoint:

```text
https://api.open-meteo.com/v1/forecast
```

Destino+ solicita condiciones actuales y siete días de pronóstico, incluyendo
temperatura, sensación térmica, humedad, viento, código meteorológico,
máximas, mínimas y probabilidad de precipitación.

## Integración en Explorar

La pestaña `Explorar` permite:

```text
Consultar clima
Usar mi ubicación
```

Ambas alternativas terminan reutilizando el mismo modelo visual de resultado.

Cuando se usa la ubicación actual, la pantalla muestra también la precisión
aproximada informada por el dispositivo.

## Estados

La interfaz contempla:

```text
inicial
cargando
error
respuesta correcta
pronóstico diario vacío
```

La aplicación no inventa clima cuando Open-Meteo, la red o la ubicación no
están disponibles.

## Arquitectura desacoplada

```text
PantallaExplorar
    |
    +-- FuenteClimaDestino
    |
    +-- FuenteClimaUbicacionActual
            |
            +-- FuenteUbicacionActual
            +-- FuenteClimaCoordenadas
```

Estas interfaces permiten probar la pantalla sin Internet ni GPS reales.

## Credenciales

La API pública utilizada no requiere almacenar una clave API en Destino+.

La configuración de Supabase continúa separada mediante
`config/supabase.local.json`.
