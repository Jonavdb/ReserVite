drop type if exists tables_available cascade;
create type tables_available as (
    table_id int,
    table_number int,
    table_restaurant int,
    table_capacity int,
    table_is_available boolean
);


create or replace function get_availables_tables(restaurant_id int, reservation_datetime timestamp)
    returns setof tables_available as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces tables';
    end if;
    if not exists(select 1 from restaurant_managers where restaurant_managers.restaurant = restaurant_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
    end if;
    return query select t.id, t.table_number, t.restaurant, t.capacity, t.id not in (
                 select t.id
                 from tables t join reservation_tables rt on t.id = rt."table"
                               join public.reservations r on rt.reservation = r.id
                 where t.restaurant = restaurant_id
                       and r.datetime::date = reservation_datetime::date
                       and r.status in ('confirmed'::status_type, 'completed'::status_type)
                       and exists(select 1
                                  from services s
                                  where s.restaurant = restaurant_id
                                  and reservation_datetime between s.start_time and s.end_time
                                  and r.datetime between s.start_time and s.end_time)
                 )
                 from tables t
                 where t.restaurant = restaurant_id;
end
$$ language plpgsql security definer;

