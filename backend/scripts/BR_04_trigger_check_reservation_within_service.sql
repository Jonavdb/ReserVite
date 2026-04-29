-- (BR-04) L'heure d'une réservation confirmée, terminée ou en attente doit être
-- comprise entre l'heure de début et l'heure de fin d'un service pour le même jour de la semaine.

-- Reservations
create or replace function reservation_within_service_on_reservations() returns trigger as
$$
begin
    if NEW.status = 'cancelled' then
        return NEW;
    end if;

    if not exists (
        select * from services
        where restaurant = NEW.restaurant
          and day_of_week = extract(isodow from NEW.datetime) -- isodow = 1 à 7
          and NEW.datetime::time between start_time and end_time
    ) then
        raise exception 'BR-04: L''heure de réservation n''est couverte par aucun service de ce jour.';
    end if;

    return NEW;
end;
$$ language plpgsql;

drop trigger if exists reservation_within_service on reservations;

create trigger tgr_reservation_within_service_on_reservations
before insert or update
on reservations
for each row
execute procedure reservation_within_service_on_reservations();

-- Services
create or replace function reservation_within_service_on_services() returns trigger as
$$
begin
    if exists (
        select * from reservations
        where restaurant = NEW.restaurant
          and extract(isodow from datetime) = OLD.day_of_week
          and status != 'cancelled'
          and datetime::time between OLD.start_time and OLD.end_time
          and datetime::time not between NEW.start_time and NEW.end_time
    ) then
        raise exception 'BR-04: Impossible de réduire le service, des réservations existent déjà en dehors de ces nouveaux horaires.';
    end if;

    return NEW;
end;
$$ language plpgsql;

create trigger tgr_reservation_within_service_on_services
before update of start_time, end_time, day_of_week
on services
for each row
execute procedure reservation_within_service_on_services();