# Persistencia de actividades de viaje en Destino+

Las actividades representan elementos del itinerario asociados a un viaje
existente.

## Relación

```text
auth.users
    |
    +-- viajes
          |
          +-- actividades_viaje
```

Una actividad no puede existir sin un viaje. La clave foránea utiliza
`on delete cascade`, por lo que al eliminar un viaje también se eliminan sus
actividades.

## Tabla `actividades_viaje`

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `id` | `uuid` | Identificador único. |
| `viaje_id` | `uuid` | Viaje propietario de la actividad. |
| `titulo` | `text` | Nombre de la actividad. |
| `fecha` | `date` | Día planificado. |
| `hora_inicio` | `time` | Hora opcional. |
| `lugar` | `text` | Lugar opcional. |
| `notas` | `text` | Notas opcionales. |
| `completada` | `boolean` | Estado de realización. |
| `creado_en` | `timestamptz` | Fecha de creación. |
| `actualizado_en` | `timestamptz` | Última modificación. |

## Seguridad mediante RLS

Las políticas no confían en un `usuario_id` enviado por Flutter.

Para cada operación se comprueba que la actividad pertenece a un viaje cuyo
`usuario_id` coincide con `auth.uid()`.

Así, un usuario no puede consultar ni modificar actividades pertenecientes a
los viajes de otra cuenta.

## Validación del rango del viaje

Destino+ valida la fecha de una actividad en dos niveles.

La interfaz avisa inmediatamente cuando la fecha queda antes del inicio o
después del final del viaje.

La base de datos también utiliza el trigger:

```text
actividades_validar_fecha_en_viaje
```

Por lo tanto, incluso una petición que no pase por el formulario Flutter no
puede guardar una actividad fuera del intervalo del viaje.

La migración correspondiente es:

```text
supabase/migrations/202608310003_validar_fechas_actividades.sql
```

## Orden e itinerario

El repositorio devuelve las actividades ordenadas por fecha y hora. La
interfaz las agrupa por día para formar un itinerario legible.

Las actividades pueden marcarse como completadas sin ser eliminadas. Ese
estado queda persistido en Supabase.

## Migraciones relacionadas

Ejecutar en este orden:

```text
202608310001_crear_tabla_viajes.sql
202608310002_crear_tabla_actividades_viaje.sql
202608310003_validar_fechas_actividades.sql
```
