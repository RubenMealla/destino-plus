-- Destino+ - actividades asociadas a los viajes
-- Requiere que la tabla public.viajes ya exista.

create table if not exists public.actividades_viaje (
  id uuid primary key default gen_random_uuid(),
  viaje_id uuid not null references public.viajes(id) on delete cascade,
  titulo text not null,
  fecha date not null,
  hora_inicio time,
  lugar text,
  notas text,
  completada boolean not null default false,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),

  constraint actividades_titulo_longitud
    check (char_length(trim(titulo)) between 2 and 120),

  constraint actividades_lugar_longitud
    check (lugar is null or char_length(lugar) <= 160),

  constraint actividades_notas_longitud
    check (notas is null or char_length(notas) <= 1000)
);

create index if not exists actividades_viaje_id_idx
  on public.actividades_viaje (viaje_id);

create index if not exists actividades_viaje_fecha_idx
  on public.actividades_viaje (viaje_id, fecha, hora_inicio);

drop trigger if exists actividades_actualizar_fecha_modificacion
  on public.actividades_viaje;

create trigger actividades_actualizar_fecha_modificacion
before update on public.actividades_viaje
for each row
execute function public.actualizar_fecha_modificacion();

alter table public.actividades_viaje enable row level security;

drop policy if exists "Usuarios consultan actividades de sus viajes"
  on public.actividades_viaje;

create policy "Usuarios consultan actividades de sus viajes"
on public.actividades_viaje
for select
to authenticated
using (
  exists (
    select 1
    from public.viajes
    where viajes.id = actividades_viaje.viaje_id
      and viajes.usuario_id = (select auth.uid())
  )
);

drop policy if exists "Usuarios crean actividades en sus viajes"
  on public.actividades_viaje;

create policy "Usuarios crean actividades en sus viajes"
on public.actividades_viaje
for insert
to authenticated
with check (
  exists (
    select 1
    from public.viajes
    where viajes.id = actividades_viaje.viaje_id
      and viajes.usuario_id = (select auth.uid())
  )
);

drop policy if exists "Usuarios actualizan actividades de sus viajes"
  on public.actividades_viaje;

create policy "Usuarios actualizan actividades de sus viajes"
on public.actividades_viaje
for update
to authenticated
using (
  exists (
    select 1
    from public.viajes
    where viajes.id = actividades_viaje.viaje_id
      and viajes.usuario_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.viajes
    where viajes.id = actividades_viaje.viaje_id
      and viajes.usuario_id = (select auth.uid())
  )
);

drop policy if exists "Usuarios eliminan actividades de sus viajes"
  on public.actividades_viaje;

create policy "Usuarios eliminan actividades de sus viajes"
on public.actividades_viaje
for delete
to authenticated
using (
  exists (
    select 1
    from public.viajes
    where viajes.id = actividades_viaje.viaje_id
      and viajes.usuario_id = (select auth.uid())
  )
);
