drop type if exists tables_available cascade;
create type tables_available as (
    table_id int,
    table_number int,
    table_restaurant int,
    table_capacity int,
    table_is_available boolean
);

create or replace function get_tables(restaurant_id int)
    returns setof tables_available as
$$
begin
    perform auth.check_logged();

    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorisé à accéder à ces tables!';
    end if;

    if not exists(select 1 from restaurant_managers where restaurant_managers.restaurant = restaurant_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant !';
    end if;

    return query
        select t.id, t.table_number, t.restaurant, t.capacity, false
        from tables t
        where t.restaurant = restaurant_id
        order by t.capacity asc, t.table_number asc;
end;
$$ language plpgsql security definer;

grant execute on function get_tables(int) to authenticated;

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
                                      and reservation_datetime::time between s.start_time and s.end_time
                                      and r.datetime::time between s.start_time and s.end_time)
                 )
                 from tables t
                 where t.restaurant = restaurant_id;
end
$$ language plpgsql security definer;

grant execute on function get_availables_tables(int, timestamp) to authenticated;

create or replace function get_specific_table(table_id int)
    returns tables_available as
$$
declare
    result tables_available;
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces services';
    end if;

    select t.id, t.table_number, t.restaurant, t.capacity into result
    from tables t
    where t.id = table_id;

    return result;
end;
$$ language plpgsql security definer;

grant execute on function  get_specific_table(int) to authenticated;

create or replace function create_table(restaurant_id int, new_capacity int, new_number int)
    returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorisé à insérer un table!';
    end if;

    insert into tables(restaurant, table_number, capacity) values (restaurant_id, new_number, new_capacity);
end;
$$ language plpgsql security definer;

grant execute on function create_table(int, int, int) to authenticated;

create or replace function update_table(table_id int, new_capacity int, new_number int)
    returns void as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces tables!';
    end if;

    update tables
    set table_number = new_number,
        capacity = new_capacity
    where id = table_id;
end;

$$ language plpgsql security definer;

grant execute on function update_table(int, int, int) to authenticated;

drop function if exists check_table_capacity(int, int);
create or replace function check_table_capacity(table_id int, new_capacity int)
    returns boolean as
$$
declare
    res_record record;
    other_tables_capacity int;
    required_capacity int;
begin
    -- boucle sur toutes les réservations qui utilisent actuellement CETTE table
    for res_record in
        select r.id, r.number_of_guests
        from reservations r
                 join reservation_tables rt on r.id = rt.reservation
        where rt."table" = table_id
        loop
            -- calcule la capacité totale de toutes les AUTRES tables de cette réservation
            select coalesce(sum(t.capacity), 0)
            into other_tables_capacity
            from tables t
                     join reservation_tables rt on t.id = rt."table"
            where rt.reservation = res_record.id
              and t.id != table_id;

            -- calcule combien de places CETTE table doit absolument fournir
            required_capacity := res_record.number_of_guests - other_tables_capacity;

            -- si la nouvelle capacité est inférieure à ce qui est strictement nécessaire, on bloque tout
            if new_capacity < required_capacity then
                return false;
            end if;
        end loop;

    -- si la boucle se termine sans avoir bloqué, c'est que la nouvelle capacité est suffisante pour tout le monde
    return true;
end;
$$ language plpgsql security definer;

grant execute on function check_table_capacity(int, int) to authenticated;