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

La aplicación no accede directamente al paquete desde las pantallas. Existe
una capa intermedia:

```text
EstadoApariencia
        |
        +-- ServicioPreferenciasLocales
                |
                +-- AlmacenPreferencias
                        |
                        +-- AlmacenPreferenciasSharedPreferences
```

Esta separación permite:

- cambiar la implementación de persistencia sin modificar la interfaz;
- probar la lógica sin depender del almacenamiento real del dispositivo;
- mantener las claves centralizadas;
- evitar mezclar preferencias locales con la persistencia de Supabase.

## Apariencia persistente

La preferencia utilizada es:

```text
preferencias.modo_apariencia
```

Los modos admitidos son:

```text
sistema
claro
oscuro
```

`EstadoApariencia` traduce esos valores a los modos de Flutter:

| Destino+ | Flutter |
| --- | --- |
| `sistema` | `ThemeMode.system` |
| `claro` | `ThemeMode.light` |
| `oscuro` | `ThemeMode.dark` |

Cuando se selecciona `Sistema`, la preferencia explícita se elimina y la
aplicación vuelve a respetar la configuración del dispositivo.

Si se encuentra un valor local desconocido o antiguo, Destino+ utiliza
`Sistema` como alternativa segura.

La conexión de este estado con `MaterialApp` y con la pantalla de Perfil se
realizará en el siguiente commit.

## Qué sí corresponde a almacenamiento local

Ejemplos apropiados:

- apariencia;
- preferencias de visualización;
- futuras unidades o ajustes pequeños del dispositivo.

## Qué no se almacena aquí

No se duplican mediante `shared_preferences`:

- contraseñas;
- sesiones manuales;
- viajes;
- actividades;
- claves privadas;
- secretos de Supabase.

Los viajes y actividades siguen almacenándose en Supabase y protegidos
mediante RLS.
