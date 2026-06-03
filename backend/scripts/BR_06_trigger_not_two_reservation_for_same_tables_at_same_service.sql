create or replace function not_two_reservations_for_same_tables_at_same_services() returns trigger as
$$
declare
    service int;
    day int;
    date_of_reservation timestamp;
    restaurant_id int;
    start_of_service time;
    end_of_service time;
begin
    select restaurant, datetime into restaurant_id, date_of_reservation
    from reservations
    where id = new.reservation;
    select extract(isodow from date_of_reservation) into day;
    select public.services.id, public.services.start_time, public.services.end_time into service, start_of_service, end_of_service
    from services
    where day_of_week = day and date_of_reservation::time between start_time and end_time and restaurant_id = services.restaurant;

    if ((select reservations.status from reservations where id = new.reservation) = ('confirmed') or ((select reservations.status from reservations where id = new.reservation) = ('completed'))) then
        if exists(select id
                  from reservation_tables
                      join reservations on reservations.id = reservation_tables.reservation
                  where reservations.restaurant = restaurant_id
                    and reservations.datetime::time between start_of_service and end_of_service
                    and reservations.datetime::date = date_of_reservation::date
                    and (status = 'confirmed' or status = 'completed')
                    and reservation_tables."table" = new."table"
                    and reservation_tables.reservation != new.reservation)


        then
            raise exception 'Une reservation est déjà présente à cette table pour ce service pour cette date';
        end if;
    end if;
    return new;
end;
$$ language plpgsql;


create or replace function not_two_reservations_for_same_tables_at_same_services_res() returns trigger as
$$
declare
    service int;
    day int;
    start_of_service time;
    end_of_service time;
begin

    select extract(isodow from new.datetime) into day;
    select public.services.id, public.services.start_time, public.services.end_time into service, start_of_service, end_of_service
    from services
    where day_of_week = day and new.datetime::time between start_time and end_time and new.restaurant = services.restaurant;

    if (new.status) = ('confirmed') or (new.status = ('completed')) then
        if exists(select id
                  from reservation_tables
                           join reservations on reservations.id = reservation_tables.reservation
                  where reservation_tables."table" in (select "table" from reservation_tables where reservation = new.id)
                  and reservations.restaurant = new.restaurant
                    and reservations.datetime::time between start_of_service and end_of_service
                    and reservations.datetime::date = new.datetime::date
                    and (status = 'confirmed' or status = 'completed')
                    and reservation_tables.reservation != new.id)
        then
            raise exception 'Une reservation est déjà présente à cette table pour ce service pour cette date';
        end if;
    end if;
    return new;
end;
$$ language plpgsql;


create trigger trg_not_two_reservations_for_same_tables_at_same_services
    before INSERT or UPDATE on reservation_tables
    for each row
    execute procedure not_two_reservations_for_same_tables_at_same_services();

create trigger trg_not_two_reservations_for_same_tables_at_same_services_res
    before UPDATE on reservations
    for each row
    execute procedure not_two_reservations_for_same_tables_at_same_services_res()