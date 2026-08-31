# Persistencia de viajes en Destino+

Este documento describe la estructura inicial utilizada para almacenar los
viajes personales de cada usuario.

## Tabla `viajes`

Cada viaje pertenece a un usuario autenticado de Supabase.

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `id` | `uuid` | Identificador único del viaje. |
| `usuario_id` | `uuid` | Usuario propietario del viaje. |
| `titulo` | `text` | Nombre que el usuario asigna al viaje. |
| `destino` | `text` | Destino principal. |
| `fecha_inicio` | `date` | Fecha inicial del viaje. |
| `fecha_fin` | `date` | Fecha final del viaje. |
| `descripcion` | `text` | Información adicional opcional. |
| `creado_en` | `timestamptz` | Fecha de creación. |
| `actualizado_en` | `timestamptz` | Última modificación. |

## Reglas de integridad

La base de datos valida que:

- el título tenga entre 2 y 100 caracteres;
- el destino tenga entre 2 y 120 caracteres;
- la descripción no supere 1000 caracteres;
- la fecha final no sea anterior a la fecha inicial.

Estas reglas también se validarán en Flutter para ofrecer retroalimentación
inmediata al usuario. Las restricciones de la base de datos representan una
segunda capa de protección.

## Seguridad mediante RLS

La tabla utiliza Row Level Security (RLS).

Las políticas permiten que un usuario autenticado únicamente pueda:

- consultar sus propios viajes;
- crear viajes con su propio `usuario_id`;
- actualizar sus propios viajes;
- eliminar sus propios viajes.

Por lo tanto, el filtro de seguridad no depende solamente de la interfaz
Flutter.

## Migración

La definición versionada se encuentra en:

```text
supabase/migrations/202608310001_crear_tabla_viajes.sql
```

Mientras no se utilice Supabase CLI, el contenido del archivo puede copiarse
y ejecutarse desde el SQL Editor del proyecto de Supabase.

## Verificación manual recomendada

Después de ejecutar la migración:

1. verificar que exista la tabla `public.viajes`;
2. comprobar que RLS esté habilitado;
3. revisar que existan las cuatro políticas;
4. mantener iniciada una sesión de Destino+;
5. continuar con el siguiente commit, donde la interfaz utilizará este
   repositorio para crear y listar viajes.
