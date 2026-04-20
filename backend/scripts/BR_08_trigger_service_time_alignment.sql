create or replace function service_time_alignment() returns trigger as
$$
declare
    slot_duration int;
begin
    select r.slot_duration into slot_duration
    from restaurants r
    where r.id = new.restaurant;

    -- opérateur :: permet de cast en int
    if(extract(minute from new.start_time)::int % slot_duration != 0) then
        raise exception 'BR-08: L''heure de début (%) n''est pas alignée sur les créneaux du restaurant (% min).', new.start_time, slot_duration;
    end if;

    if(extract(minute from new.end_time)::int % slot_duration != 0) then
        raise exception 'BR-08: L''heure de fin (%) n''est pas alignée sur les créneaux du restaurant (% min).', new.end_time, slot_duration;
    end if;

    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_service_time_alignment on services;

create trigger trg_service_time_alignment
before INSERT or UPDATE on services
for each row
execute procedure service_time_alignment();