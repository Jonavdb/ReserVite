create or replace function completed_or_cancelled_reservation_cant_be_updated() returns trigger as
$$
declare
    status_reservation status_type;
begin
    if old.status = 'completed' or old.status = 'cancelled' then
        raise exception 'Une réservation annulée ou terminée ne peut pas être modifiée';
    end if;
    return new;
end;
$$ language plpgsql;

create or replace function cpl_or_ccd_res_cant_be_updated_reserv_tables() returns trigger as
$$
declare
    status_reservation status_type;
begin
    select status from reservations where id = old.reservation into status_reservation;
    if status_reservation = 'completed' or status_reservation = 'cancelled' then
        raise exception 'Une réservation annulée ou terminée ne peut pas être modifiée';
    end if;
    return new;
end;
$$ language plpgsql;


create constraint trigger completed_or_cancelled_reservation_cant_be_updated
    after UPDATE on reservations
    deferrable initially deferred
    for each row
execute procedure completed_or_cancelled_reservation_cant_be_updated();

create constraint trigger cant_updated_reservation_cpl_ccl_reservation_tables
    after UPDATE on reservation_tables
    deferrable initially deferred
    for each row
execute procedure cpl_or_ccd_res_cant_be_updated_reserv_tables()