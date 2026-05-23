create type deletable_services as (
    id int,
    restaurant int,
    day_of_week int,
    start_time time,
    end_time time,
    gap int,
    can_be_deleted boolean
);





create or replace function get_services_for_restaurant(restaurant_id int)
    returns setof deletable_services as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces services';
end if;
    if not exists(select 1 from restaurant_managers where restaurant_managers.restaurant = restaurant_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
end if;
return query select s.id, s.restaurant, s.day_of_week, s.start_time, s.end_time, rest.slot_duration,
             not exists(
                select 1
                from reservations r
                where r.restaurant = restaurant_id
                and extract(isodow from r.datetime) = s.day_of_week
                and r.datetime::time between s.start_time and s.end_time
                and r.status not in ('cancelled'::status_type)
             ) as can_be_deleted
             from services s join restaurants rest on s.restaurant = rest.id
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
        raise exception 'Vous n''etes pas autorise à accéder à ces services';
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
        raise exception 'Vous n''etes pas autorise à accéder à ces services';
    end if;
    select s.id, s.restaurant, s.day_of_week, s.start_time, s.end_time, rest.slot_duration,
           not exists(select 1
                      from reservations r
                      where r.restaurant = restaurant_id
                        and extract(isodow from r.datetime) = s.day_of_week
                        and r.datetime::time between s.start_time and s.end_time
                        and r.status not in ('cancelled'::status_type)
                      )
    into result
    from services s join restaurants rest on s.restaurant = rest.id
    where s.id = service_id;
    return result;
end;
$$ language plpgsql security definer;

grant execute on function  get_specific_service(int, int) to authenticated;


create or replace function update_service(service_id int, new_day_of_week int, new_start_time time, new_end_time time)
    returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces services';
    end if;
    update services
    set day_of_week = new_day_of_week,
        start_time = new_start_time,
        end_time = new_end_time
    where id = service_id;
end;

$$ language plpgsql security definer;

grant execute on function update_service(int, int, time, time) to authenticated;

create or replace function count_impacted_services(restaurant_id int, new_day_of_week int, new_start_time time, new_end_time time, service_id int)
    returns int as
$$
declare
    count int;
begin
    select count(*) into count
    from services s
    where s.restaurant = restaurant_id
      and s.day_of_week = new_day_of_week
      and start_time < new_end_time
      and end_time > new_start_time
      and (s.id != service_id or service_id = -1);
    return count;

end;
$$  language plpgsql security definer;

grant execute on function count_impacted_services(int, int, time, time, int) to authenticated;

create or replace function create_service(restaurant_id int, new_day_of_week int, new_start_time time, new_end_time time)
    returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces services';
    end if;
    insert into services (restaurant, day_of_week, start_time, end_time) values (restaurant_id, new_day_of_week, new_start_time, new_end_time);
end;
$$ language plpgsql security definer;

grant execute on function create_service(int, int, time, time) to authenticated;

