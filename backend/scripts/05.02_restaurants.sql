-- Petite carte d'informations du restaurant
drop type if exists restaurant_card_info cascade;
create type restaurant_card_info as (
    id int,
    name varchar,
    city varchar,
    rating double precision,
    price_range int,
    last_reservation_date timestamp,
    pending_reservation_count bigint
);

-- Informations détaillées du restaurant
drop type if exists restaurant_details cascade;
create type restaurant_details as (
                                      id int,
                                      name varchar,
                                      city varchar,
                                      rating double precision,
                                      description text,
                                      services timestamp
                                  );
-- Vues : création de vues réutilisables pour les calculs de la dernière resa + nb de pendings
-- elle a 3 colonnes : restaurant_id, max_res_date et pending_count, qu'on pourra réutiliser plus bas
drop view if exists v_restaurant_stats;
create or replace view v_restaurant_stats as
with restaurant_last_res as (
    select r.restaurant, max(r.datetime) as max_res_date
    from reservations r
    group by r.restaurant
),
     restaurant_pending as (
         select r.restaurant, count(*) as pending_count
         from reservations r
         where r.status = 'pending'
         group by r.restaurant
     )
select
    resto.id as restaurant_id,
    rlr.max_res_date,
    coalesce(rp.pending_count, 0)::bigint as pending_count
from restaurants resto

         left join restaurant_last_res rlr on resto.id = rlr.restaurant
         left join restaurant_pending rp on resto.id = rp.restaurant;


-- Get all restaurants
drop function if exists get_restaurants;
create or replace function get_restaurants() returns setof restaurant_card_info as
$$
begin
    perform auth.check_logged();

    return query
        select
            resto.id, resto.name, resto.city, resto.rating, resto.price_range,
            v.max_res_date, v.pending_count
        from restaurants resto
                 join v_restaurant_stats v on v.restaurant_id = resto.id;    -- on réutilise la vue ici
end;
$$ language plpgsql security definer;

grant execute on function get_restaurants() to authenticated;

---- Get manager's restaurants ----
drop function if exists get_restaurants_manager;
create or replace function get_restaurants_manager() returns setof restaurant_card_info as
$$
begin
    perform auth.check_logged();

    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à accéder à la liste des restaurants!';
    end if;

    return query
        select
            resto.id, resto.name, resto.city, resto.rating, resto.price_range,
            v.max_res_date, v.pending_count
        from restaurants resto
                 join restaurant_managers rm on rm.restaurant = resto.id
                 join v_restaurant_stats v on v.restaurant_id = resto.id    -- on réutilise la vue ici
        where rm.manager = auth.id()
        order by
            (v.max_res_date is null) asc, -- les restaurants SANS résa apparaîssent après
            v.max_res_date desc,                   -- tri par date de réservation la plus récente (décroissant)
            resto.name asc;                        -- en cas d'égalité, ordre alpha du nom
end;
$$ language plpgsql security definer;

grant execute on function get_restaurants_manager() to authenticated;


---- Search filter restaurant ----
drop function if exists find_restaurants_client;
create or replace function find_restaurants_client(search_term text default '') returns setof restaurant_card_info as
$$
begin
    perform auth.check_logged();

    return query
        -- calcule les stats uniquement pour le client connecté
        with client_stats as (
            select r.restaurant,
                   max(r.datetime) as max_res_date,
                   count(r.id) filter (where r.status = 'pending') as pending_count
            from reservations r
            where r.client = auth.id()
            group by r.restaurant
        )
        select
            resto.id, resto.name, resto.city, resto.rating, resto.price_range,
            c.max_res_date,
            coalesce(c.pending_count, 0)::bigint
        from restaurants resto
                 left join client_stats c on c.restaurant = resto.id

        where search_term is null
           or trim(search_term) = ''
           or lower(concat(resto.name, ' ', resto.address, ' ', resto.city, ' ', resto.description))
            like concat('%', lower(trim(search_term)), '%')

        order by resto.name asc;
    -- (Plus de LIMIT ici !)
end;
$$ language plpgsql security definer;

grant execute on function find_restaurants_client(text) to authenticated;

---- Get Restaurant Details ----
drop function if exists get_restaurant_details;
create or replace function get_restaurant_details(restaurant_id int)
    returns json as
$$
declare
    result json;
begin
    perform auth.check_logged();

    select json_build_object(
                   'id', resto.id,
                   'name', resto.name,
                   'address', resto.address,
                   'city', resto.city,
                   'rating', resto.rating,
                   'price_range', resto.price_range,
                   'description', resto.description,
                   'services', coalesce((
                                            select json_agg(
                                                           json_build_object(
                                                                   'day_of_week', s.day_of_week,
                                                                   'start_time', s.start_time,
                                                                   'end_time', s.end_time
                                                           ) order by s.day_of_week asc, s.start_time asc
                                                   )
                                            from services s
                                            where s.restaurant = resto.id
                                        ), '[]'::json)
           ) into result
    from restaurants resto
    where resto.id = restaurant_id;

    return result;
end;
$$ language plpgsql security definer;

grant execute on function get_restaurant_details(int) to authenticated;


create or replace function get_restaurant_gap(restaurant_id int) returns int as
$$
declare
    gap  int;
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à accéder à la liste des restaurants!';
    end if;
    select restaurants.slot_duration into gap from restaurants where id = restaurant_id;
    return gap;
end;
$$ language plpgsql security definer;

grant execute on function get_restaurant_gap(int) to authenticated;