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
    client_phone varchar
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

create or replace function get_user_reservations(
    status_filter status_type default null -- paramètre optionnel
)
returns setof reservation_info
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
        select reservations.id,
            reservations.client,
            reservations.restaurant,
            reservations.datetime,
            reservations.number_of_guests,
            reservations.status,
            reservations.special_requests,
            users.full_name
        from reservations join users on reservations.client = users.id
            and reservations.client = uid
            and (status_filter is null or status = status_filter)
        order by reservations.datetime DESC, reservations.id DESC;
end;
$$;

grant execute on function get_user_reservations(status_type) to authenticated;


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
                        users.phone
                 from reservations
                     join users on reservations.client = users.id
                     join restaurants on reservations.restaurant = restaurants.id
                 where reservations.id = reservation_id;
end;
$$ language plpgsql security definer;

grant execute on function get_reservation_manager(int) to authenticated;