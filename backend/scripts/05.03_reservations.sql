
-- Jo
drop type if exists reservation_info cascade;
create type reservation_info as (
    id int,
    client int,
    restaurant int,
    datetime timestamp,
    number_of_guests int,
    status status_type,
    special_requests text,
    client_name varchar
);

-- Jo
drop type if exists reservation_details cascade;
create type reservation_details as (
    id int,
    client int,
    restaurant int,
    restaurant_name varchar,
    datetime timestamp,
    number_of_guests int,
    status status_type,
    special_requests text,
    client_name varchar,
    client_email varchar,
    client_phone varchar,
    table_numbers int[],
    table_capacities int[]
);

-- Manu
drop type if exists client_reservation_info cascade;
create type client_reservation_info as (
    id int,
    status status_type,
    restaurant_name varchar,
    restaurant_city varchar,
    datetime timestamp,
    number_of_guests int
);

create or replace function get_reservations_manager(restaurant_id int)
    returns setof reservation_details as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à accéder à ces réservations';
    end if;

    if not exists(select 1 from restaurant_managers where restaurant_managers.restaurant = restaurant_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
    end if;
    return query select reservations.id,
                        reservations.client,
                        reservations.restaurant,
                        restaurants.name,
                        reservations.datetime,
                        reservations.number_of_guests,
                        reservations.status,
                        reservations.special_requests,
                        users.full_name,
                        users.email,
                        users.phone,
                        array_agg(tables.table_number order by tables.table_number) filter (where tables.id is not null),
                        array_agg(tables.capacity order by tables.table_number) filter (where tables.id is not null)
                         from reservations
                          join users on reservations.client = users.id
                          join restaurants on reservations.restaurant = restaurants.id
                          left join reservation_tables on reservation_tables.reservation = reservations.id
                          left join tables on tables.id = reservation_tables."table"
                 where reservations.restaurant = restaurant_id
                 group by reservations.id, users.full_name, users.email, users.phone, restaurants.name, reservations.datetime
                 order by reservations.datetime DESC, reservations.id DESC;
end;
$$ language plpgsql security definer;

grant execute on function get_reservations_manager(int) to authenticated;

create or replace function get_client_reservations(
    status_filter status_type default null
)
    returns setof client_reservation_info
    language plpgsql
    security definer
as $$
declare
    uid int := auth.id();
    user_role text := auth.role();
begin
    if uid is null then
        raise exception 'Vous devez être connecté';
    end if;

    if user_role != 'client' then
        raise exception 'Vous n''êtes pas autorisé. Rôle détecté: [%], ID détecté: [%]', user_role, uid;
    end if;

    return query
        select reserv.id,
               reserv.status,
               resto.name,
               resto.city,
               reserv.datetime,
               reserv.number_of_guests
        from reservations reserv
                 join users on reserv.client = users.id
                 join restaurants resto on resto.id = reserv.restaurant
        where (status_filter is null or reserv.status = status_filter)
        and users.id = uid
        order by reserv.datetime desc, reserv.id desc;
end;
$$;

grant execute on function get_client_reservations(status_type) to authenticated;

create or replace function get_reservation_manager(reservation_id int)
    returns setof reservation_details as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à accéder à ces réservations';
end if;

    if not exists(select 1 from restaurant_managers join reservations on reservations.restaurant = restaurant_managers.restaurant where reservations.id = reservation_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
end if;
return query select     reservations.id,
                        reservations.client,
                        reservations.restaurant,
                        restaurants.name,
                        reservations.datetime,
                        reservations.number_of_guests,
                        reservations.status,
                        reservations.special_requests,
                        users.full_name,
                        users.email,
                        users.phone,
                        array_agg(tables.table_number order by tables.table_number) filter (where tables.id is not null),
                        array_agg(tables.capacity order by tables.table_number) filter (where tables.id is not null)
                 from reservations
                     join users on reservations.client = users.id
                     join restaurants on reservations.restaurant = restaurants.id
                     left join reservation_tables on reservation_tables.reservation = reservations.id
                     left join tables on tables.id = reservation_tables."table"
                 where reservations.id = reservation_id
                 group by reservations.id, users.full_name, users.email, users.phone, restaurants.name;
end;
$$ language plpgsql security definer;

--                      left join car pas forcément de résultat pour les réservations sans table associée
--                      group by obligatoire pour les fonctions aggrégées
--                      array_agg afin de retourner un tableau de numéros de tables et un tableau de capacité de tables

grant execute on function get_reservation_manager(int) to authenticated;



create or replace function cancel_reservation_manager(reservation_id int) returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à annuler cette réservation';
    end if;

    if not exists(select 1 from restaurant_managers join reservations on reservations.restaurant = restaurant_managers.restaurant where reservations.id = reservation_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
    end if;
    delete from reservation_tables where reservation = reservation_id;
    update reservations set status = 'cancelled' where id = reservation_id;
end;
$$ language plpgsql security definer;

grant execute on function cancel_reservation_manager(int) to authenticated;

create or replace function confirm_reservation_manager(reservation_id int, table_ids int[]) returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à confirmer cette réservation';
    end if;

    if not exists(select 1 from restaurant_managers join reservations on reservations.restaurant = restaurant_managers.restaurant where reservations.id = reservation_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
    end if;
    insert into reservation_tables(reservation, "table")
    select reservation_id, unnest(table_ids);
    update reservations set status = 'confirmed' where reservations.id = reservation_id;
end;
$$ language plpgsql security definer;
-- unnest permet de transformer un tableau en plusieurs lignes

grant execute on function confirm_reservation_manager(int, int[]) to authenticated;

create or replace function complete_reservation_manager(reservation_id int, date_simulated timestamp) returns void as
$$
declare
    reservation_date timestamp;
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vousn''êtes pas autorisé à compléter cette réservation';
    end if;

    if not exists(select 1 from restaurant_managers join reservations on reservations.restaurant = restaurant_managers.restaurant where reservations.id = reservation_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
    end if;
    select datetime from reservations where id = reservation_id into reservation_date;
    if date_simulated < reservation_date then
        raise exception 'La date doit être postérieure à la date de la réservation';
    end if;
    update reservations set status = 'completed' where reservations.id = reservation_id;
end;
$$ language plpgsql security definer;

grant execute on function complete_reservation_manager(int, timestamp) to authenticated;

insert into reservations(client, restaurant, datetime, number_of_guests, status, special_requests) values ('3', '1', '2024-12-24 20:00:00', 4, 'pending', 'Table près de la fenêtre');