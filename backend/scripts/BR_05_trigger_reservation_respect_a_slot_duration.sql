create or replace function reservation_respect_a_slot_duration() returns trigger as
$$
declare
    slot int;
    minutes_of_reservation int;
begin
    select restaurants.slot_duration into slot
    from restaurants
    where id = new.restaurant;

    select extract(minute from new.datetime) into minutes_of_reservation;

    if minutes_of_reservation % slot != 0 then
        raise exception 'Une reservation doit toujours se faire dans le créneau horaire du restaurant';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_reservation_respect_a_slot_duration
    before INSERT or UPDATE on reservations
    for each row
    execute procedure reservation_respect_a_slot_duration();