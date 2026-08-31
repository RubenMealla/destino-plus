# Persistencia de actividades de viaje en Destino+

Las actividades representan elementos del itinerario asociados a un viaje
existente.

## Relación

La estructura principal es:

```text
auth.users
    |
    +-- viajes
          |
          +-- actividades_viaje
```

Una actividad no puede existir sin un viaje.

La clave foránea utiliza `on delete cascade`, por lo que al eliminar un viaje
también se eliminan sus actividades.

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

Para cada operación se comprueba que:

1. la actividad pertenece a un viaje existente;
2. el `usuario_id` de ese viaje coincide con `auth.uid()`.

Así, un usuario no puede consultar ni modificar actividades pertenecientes
a los viajes de otra cuenta.

## Migración

Ejecutar después de la migración de `viajes`:

```text
supabase/migrations/202608310002_crear_tabla_actividades_viaje.sql
```

Puede copiarse el contenido en el SQL Editor de Supabase.

## Orden del itinerario

El repositorio devuelve las actividades ordenadas por:

1. fecha;
2. hora de inicio;
3. fecha de creación.

Las actividades sin hora se mantienen permitidas porque no todas las tareas
de un viaje requieren un horario exacto.

## Validaciones iniciales

La capa de persistencia verifica:

- título entre 2 y 120 caracteres;
- lugar opcional de máximo 160;
- notas opcionales de máximo 1000;
- hora opcional en formato `HH:mm`;
- fecha dentro de un rango técnico válido.

La validación para comprobar que la fecha de una actividad pertenezca al
intervalo concreto del viaje se incorporará junto con la interfaz del
itinerario.
