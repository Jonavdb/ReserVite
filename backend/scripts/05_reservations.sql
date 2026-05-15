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


create or replace function get_reservations(restaurant_id int)
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

grant execute on function get_reservations to authenticated;