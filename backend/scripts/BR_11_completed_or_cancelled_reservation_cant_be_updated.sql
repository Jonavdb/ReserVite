create or replace function completed_or_cancelled_reservation_cant_be_updated() returns trigger as
$$
declare
    status_reservation status_type;
begin
    select status from reservations where id = new.id into status_reservation;
    if status_reservation = 'completed' or status_reservation = 'cancelled' then
        raise exception 'Une réservation annulée ou terminée ne peut pas être modifiée';
    end if;
    return new;
end;
$$ language plpgsql;


create trigger completed_or_cancelled_reservation_cant_be_updated
before UPDATE on reservations
for each row
execute procedure completed_or_cancelled_reservation_cant_be_updated();