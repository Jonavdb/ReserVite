
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
    returns setof reservation_info as
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
                        reservations.datetime,
                        reservations.number_of_guests,
                        reservations.status,
                        reservations.special_requests,
                        users.full_name
                 from reservations join users on reservations.client = users.id
                 where restaurant = restaurant_id
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