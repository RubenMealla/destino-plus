-- Destino+ - tabla principal de viajes
-- Ejecutar en el SQL Editor de Supabase o mediante Supabase CLI.

create table if not exists public.viajes (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references auth.users(id) on delete cascade,
  titulo text not null,
  destino text not null,
  fecha_inicio date not null,
  fecha_fin date not null,
  descripcion text,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),

  constraint viajes_titulo_longitud
    check (char_length(trim(titulo)) between 2 and 100),

  constraint viajes_destino_longitud
    check (char_length(trim(destino)) between 2 and 120),

  constraint viajes_descripcion_longitud
    check (descripcion is null or char_length(descripcion) <= 1000),

  constraint viajes_fechas_validas
    check (fecha_fin >= fecha_inicio)
);

create index if not exists viajes_usuario_id_idx
  on public.viajes (usuario_id);

create index if not exists viajes_usuario_fecha_inicio_idx
  on public.viajes (usuario_id, fecha_inicio);

create or replace function public.actualizar_fecha_modificacion()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.actualizado_en = now();
  return new;
end;
$$;

drop trigger if exists viajes_actualizar_fecha_modificacion
  on public.viajes;

create trigger viajes_actualizar_fecha_modificacion
before update on public.viajes
for each row
execute function public.actualizar_fecha_modificacion();

alter table public.viajes enable row level security;

drop policy if exists "Usuarios consultan sus viajes" on public.viajes;
create policy "Usuarios consultan sus viajes"
on public.viajes
for select
to authenticated
using ((select auth.uid()) = usuario_id);

drop policy if exists "Usuarios crean sus viajes" on public.viajes;
create policy "Usuarios crean sus viajes"
on public.viajes
for insert
to authenticated
with check ((select auth.uid()) = usuario_id);

drop policy if exists "Usuarios actualizan sus viajes" on public.viajes;
create policy "Usuarios actualizan sus viajes"
on public.viajes
for update
to authenticated
using ((select auth.uid()) = usuario_id)
with check ((select auth.uid()) = usuario_id);

drop policy if exists "Usuarios eliminan sus viajes" on public.viajes;
create policy "Usuarios eliminan sus viajes"
on public.viajes
for delete
to authenticated
using ((select auth.uid()) = usuario_id);
