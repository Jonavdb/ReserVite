create or replace function completed_or_cancelled_reservation_cant_be_updated() returns trigger as
$$
declare
    status_reservation status_type;
begin
    select status from reservations where id = old.id into status_reservation;
    if status_reservation = 'completed' or status_reservation = 'cancelled' then
        raise exception 'Une réservation annulée ou terminée ne peut pas être modifiée';
    end if;
    return new;
end;
$$ language plpgsql;

create or replace function completed_or_cancelled_reservation_cant_be_updated_2() returns trigger as
$$
declare
    status_reservation status_type;
begin
    select status from reservations where id = old.reservation into status_reservation;
    if status_reservation = 'completed' or status_reservation = 'cancelled' then
        raise exception 'Une réservation annulée ou terminée ne peut pas être modifiée';
    end if;
    return old;
end;
$$ language plpgsql;


create trigger completed_or_cancelled_reservation_cant_be_updated
before UPDATE on reservations
for each row
execute procedure completed_or_cancelled_reservation_cant_be_updated();

create trigger cant_updated_reservation_cpl_ccl_reservation_tables
before UPDATE or delete on reservation_tables
for each row
execute procedure completed_or_cancelled_reservation_cant_be_updated_2()
