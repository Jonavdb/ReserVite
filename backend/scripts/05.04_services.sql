create type deletable_services as (
    id int,
    restaurant int,
    day_of_week int,
    start_time time,
    end_time time,
    can_be_deleted boolean
);





create or replace function get_services_for_restaurant(restaurant_id int)
    returns setof deletable_services as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces tables';
end if;
    if not exists(select 1 from restaurant_managers where restaurant_managers.restaurant = restaurant_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
end if;
return query select s.id, s.restaurant, s.day_of_week, s.start_time, s.end_time,
             not exists(
                select 1
                from reservations r
                where r.restaurant = restaurant_id
                and extract(isodow from r.datetime) = s.day_of_week
                and r.datetime::time between s.start_time and s.end_time
                and r.status not in ('cancelled'::status_type)
             ) as can_be_deleted
             from services s
             where s.restaurant = restaurant_id;
end
$$ language plpgsql security definer;

grant execute on function get_services_for_restaurant(int) to authenticated;

create or replace function delete_service(service_id int)
    returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces tables';
    end if;
    delete from services s where s.id = service_id;
end;

$$ language plpgsql security definer;

grant execute on function delete_service(int) to authenticated;

create or replace function get_specific_service(service_id int, restaurant_id int)
    returns deletable_services as
$$
declare
    result deletable_services;
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces tables';
    end if;
    select s.id, s.restaurant, s.day_of_week, s.start_time, s.end_time,
           not exists(select 1
                      from reservations r
                      where r.restaurant = restaurant_id
                        and extract(isodow from r.datetime) = s.day_of_week
                        and r.datetime::time between s.start_time and s.end_time
                        and r.status not in ('cancelled'::status_type)
                      )
    into result
    from services s
    where s.id = service_id;
    return result;
end;
$$ language plpgsql security definer;

grant execute on function  get_specific_service(int, int) to authenticated;




