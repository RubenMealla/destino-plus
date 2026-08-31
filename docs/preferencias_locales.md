# Preferencias locales de Destino+

Destino+ utiliza almacenamiento local únicamente para preferencias pequeñas
del dispositivo y de la interfaz.

Los datos principales del usuario, como autenticación, viajes y actividades,
continúan utilizando Supabase como fuente de verdad.

## Tecnología

La persistencia local se implementa con:

```text
shared_preferences
```

La aplicación evita acceder directamente al paquete desde las pantallas. Las
preferencias pasan por estados y servicios propios de Destino+:

```text
EstadoApariencia ───────┐
                        ├── ServicioPreferenciasLocales
EstadoUnidades ─────────┘            |
                                     +-- AlmacenPreferencias
                                             |
                                             +-- shared_preferences
```

Esta separación permite probar la lógica sin almacenamiento real, centralizar
las claves y mantener la interfaz desacoplada.

## Apariencia persistente

Clave:

```text
preferencias.modo_apariencia
```

Valores:

```text
sistema
claro
oscuro
```

`EstadoApariencia` traduce la selección a `ThemeMode` y la pantalla Perfil
permite cambiarla.

## Unidad de temperatura

Clave:

```text
preferencias.unidad_temperatura
```

Valores admitidos:

```text
celsius
fahrenheit
```

La unidad predeterminada es `celsius`.

Cuando el usuario elige Fahrenheit, la selección se persiste. Si vuelve a
Celsius, la clave se elimina porque Celsius ya es el comportamiento
predeterminado.

Open-Meteo continúa siendo la fuente de los valores meteorológicos. La
preferencia solo transforma cómo se presenta la temperatura al usuario:

```text
°F = (°C × 9 / 5) + 32
```

`EstadoUnidades` concentra esa preferencia y la conversión, evitando colocar
la fórmula dentro de las pantallas.

La integración visible con Perfil y con la pantalla de clima se realiza en el
siguiente commit de `feature/profile-settings`.

## Alcance del almacenamiento local

Sí corresponde a este mecanismo:

- apariencia;
- unidad de temperatura;
- futuras preferencias de visualización pequeñas.

No se almacenan aquí:

- contraseñas;
- sesiones manuales;
- viajes;
- actividades;
- coordenadas GPS;
- claves privadas;
- secretos de Supabase.

Viajes y actividades continúan almacenándose en Supabase y protegidos mediante
RLS.
