-- Ali
drop type if exists restaurants_manager_info cascade;
create type restaurants_manager_info as (
    id int,
    name varchar,
    city varchar,
    rating double precision,
    price_range int,
    last_reservation_date timestamp,
    pending_reservation_count bigint
);

drop function if exists get_restaurants_manager;
create or replace function get_restaurants_manager() returns setof restaurants_manager_info as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''êtes pas autorisé à accéder à la liste des restaurants!';
    end if;

    return query with
        -- le with va créer une "table temporaire" nommée restaurant_last_res
        -- dont le résultat sera accessible dans la requete principale (après le with)
     restaurant_last_res as (
        select r.restaurant, max(r.datetime) as max_res_date -- on récupère la date la plus récente de la table réservations
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
        resto.id,
        resto.name,
        resto.city,
        resto.rating,
        resto.price_range,
        rlr.max_res_date,
        coalesce(rp.pending_count, 0)::bigint
    from restaurants resto

    join restaurant_managers rm on rm.restaurant = resto.id
    join users u on u.id = rm.manager

    left join restaurant_last_res rlr on resto.id = rlr.restaurant
    left join restaurant_pending rp on resto.id = rp.restaurant

    where u.id = auth.id()

    order by (rlr.max_res_date is null) asc, -- les restaurants SANS résa apparaîssent après
    rlr.max_res_date desc,                   -- tri par date de réservation la plus récente (décroissant)
    resto.name asc;                          -- en cas d'égalité, ordre alpha du nom
end;
$$ language plpgsql security definer;

grant execute on function get_restaurants_manager() to authenticated;

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