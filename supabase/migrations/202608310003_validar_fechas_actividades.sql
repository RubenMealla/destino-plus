-- Destino+ - protege el rango de fechas de las actividades.
-- Debe ejecutarse después de las migraciones de viajes y actividades.

create or replace function public.validar_fecha_actividad_en_viaje()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
declare
  fecha_inicio_viaje date;
  fecha_fin_viaje date;
begin
  select fecha_inicio, fecha_fin
    into fecha_inicio_viaje, fecha_fin_viaje
  from public.viajes
  where id = new.viaje_id;

  if fecha_inicio_viaje is null or fecha_fin_viaje is null then
    raise exception 'viaje_no_disponible';
  end if;

  if new.fecha < fecha_inicio_viaje or new.fecha > fecha_fin_viaje then
    raise exception 'actividad_fecha_fuera_viaje';
  end if;

  return new;
end;
$$;

drop trigger if exists actividades_validar_fecha_en_viaje
  on public.actividades_viaje;

create trigger actividades_validar_fecha_en_viaje
before insert or update of viaje_id, fecha
on public.actividades_viaje
for each row
execute function public.validar_fecha_actividad_en_viaje();
