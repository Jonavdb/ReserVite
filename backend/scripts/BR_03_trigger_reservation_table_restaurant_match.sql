-- Les tables associées à une réservation doivent appartenir au restaurant de la réservation.

create or replace function reservation_table_restaurant_match() returns trigger as
$$
declare
    _restaurant_from_reservation int;
    _table_from_reservation int;
begin
    select r.restaurant into _restaurant_from_reservation
    from reservations r
    where id = new.reservation;

    select t.restaurant into _table_from_reservation
    from tables t
    where id = new."table";

    if _restaurant_from_reservation != _table_from_reservation then
        raise exception 'La table % n''appartient pas au restaurant de la réservation', NEW."table";
    end if;

    return new;
end;
$$ language plpgsql;

drop trigger if exists reservation_table_restaurant_match on reservation_tables;

create constraint trigger trg_reservation_table_restaurant_match
    after insert or update
    on reservation_tables
    deferrable initially deferred
    for each row
execute procedure reservation_table_restaurant_match();