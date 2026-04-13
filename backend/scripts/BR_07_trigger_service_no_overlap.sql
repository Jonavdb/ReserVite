create or replace function service_no_overlap() returns trigger as
$$
declare
    _conflict_count int;
begin
    select count(*) into _conflict_count
    from services
    where restaurant = new.restaurant   -- même resto
    and day_of_week = new.day_of_week   -- même jour de la semaine
    and id != coalesce(NEW.id, -1)      -- lors d'un insert, new.id peut être vide, donc la base de données remplacerait ça par -1 pour éviter un bug
    and start_time < new.start_time
    and end_time > new.end_time;

    if _conflict_count > 0 then
        raise exception 'Le service (de % à %) chevauche un autre service déjà existant pour ce jour.', NEW.start_time, NEW.end_time;
    end if;

    return new;
end;
$$ language plpgsql;

drop trigger if exists service_no_overlap on services;

create trigger trg_service_no_overlap
    before insert or update
    on services
    for each row
execute procedure service_no_overlap();