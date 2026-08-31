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

La aplicación evita acceder directamente al paquete desde las pantallas:

```text
Perfil / Explorar
       |
       +-- EstadoApariencia
       |
       +-- EstadoUnidades
               |
               +-- ServicioPreferenciasLocales
                       |
                       +-- AlmacenPreferencias
                               |
                               +-- shared_preferences
```

`EstadoApariencia` y `EstadoUnidades` se registran como estado global mediante
Provider.

Ambos se cargan antes de ejecutar `DestinoPlusApp`, por lo que las
preferencias ya están disponibles cuando aparece la interfaz.

## Apariencia

Clave:

```text
preferencias.modo_apariencia
```

Opciones visibles:

```text
Sistema
Claro
Oscuro
```

## Unidad de temperatura

Clave:

```text
preferencias.unidad_temperatura
```

Opciones visibles en Perfil:

```text
Celsius (°C)
Fahrenheit (°F)
```

Celsius es la opción predeterminada.

Open-Meteo continúa entregando las temperaturas utilizadas internamente por
la integración actual. Si el usuario elige Fahrenheit, `EstadoUnidades`
convierte únicamente la presentación:

```text
°F = (°C × 9 / 5) + 32
```

La preferencia se aplica al clima actual, sensación térmica, temperatura
máxima y temperatura mínima de la pantalla Explorar.

El cambio se refleja en la interfaz y permanece después de cerrar y volver a
abrir la aplicación.

## Alcance

Se almacenan localmente:

- modo de apariencia;
- unidad de temperatura.

No se almacenan en `shared_preferences`:

- contraseñas;
- sesiones manuales;
- viajes;
- actividades;
- coordenadas GPS;
- secretos o claves privadas.

Los viajes y actividades continúan en Supabase. La ubicación solo se usa
temporalmente cuando el usuario solicita su clima.
