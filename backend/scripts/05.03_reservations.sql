
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
drop type if exists restaurant_info cascade;
create type restaurant_info as (
   id int,
   _name varchar,
   address varchar,
   city varchar,
   phone varchar
);

-- Manu
drop type if exists client_reservation_info cascade;
create type client_reservation_info as (
    id int,
    status status_type,
    datetime timestamp,
    number_of_guests int,
    special_requests text,
    restaurant restaurant_info
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
               reserv.datetime,
               reserv.number_of_guests,
               reserv.special_requests,
               ROW(
                   resto.id,
                   resto.name,
                   resto.address,
                   resto.city,
                   resto.phone
                   )::restaurant_info -- conversion du ROW en type restaurant_info
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

create or replace function count_reservations_outside_new_slot(restaurant_id int, new_day_of_week int, new_start_time time, new_end_time time, service_id int)
    returns int as
$$
declare
    count int;
begin
    select count(*) into count
    from reservations r join services s on s.id = service_id
    where r.restaurant = restaurant_id
    and extract(isodow from r.datetime) = s.day_of_week
    and r.datetime::time between s.start_time and s.end_time
    and r.status not in('cancelled'::status_type)
    and (extract(isodow from r.datetime) != new_day_of_week or r.datetime::time not between new_start_time and new_end_time);
    return count;

end;
$$  language plpgsql security definer;

grant execute on function count_reservations_outside_new_slot(int, int, time, time, int) to authenticated;


create or replace function get_client_reservation_by_id(resid int)
    returns client_reservation_info
as $$
declare
    uid int := auth.id();
    user_role text := auth.role();
    res client_reservation_info;
begin
    if uid is null then
        raise exception 'Vous devez être connecté';
    end if;

    if user_role != 'client' then
        raise exception 'Vous n''êtes pas autorisé. Rôle détecté: [%], ID détecté: [%]', user_role, uid;
    end if;
    select * into res from get_client_reservations(null) where id = resId;

    if res is null then
        raise exception 'Réservation introuvable. ID :[%]', resId;
    end if;

    return res;
end;
$$ language plpgsql security definer;
grant execute on function get_client_reservation_by_id(int) to authenticated;


CREATE OR REPLACE FUNCTION get_slots_available_for_potential_reservation(
    p_resdate timestamp,
    p_restaurant_id int,
    p_ignore_res_id int DEFAULT NULL
)
    RETURNS time[]
AS $$
DECLARE
    v_available_slots time[];
BEGIN
    -- on récupère le résultat de la fonction et on met tout dans un array de 'time'
    -- pour avoir les heures des créneaux disponibles
    SELECT ARRAY(
                   WITH
                       -- 1. on récupère le nombre total de chaises (la capacité totale) du restaurant en paramètre
                       restaurant_capacity as (
                           SELECT COALESCE(SUM(capacity), 0) as max_seats
                           FROM tables t
                           WHERE t.restaurant = p_restaurant_id
                       ),
                       -- 2. on récupère tous les débuts de créneaux horaires du restaurant en paramètre au jour de la date en paramètre
                       -- exemple : 2/6/2026 => jour : MARDI de 18:00 à 20:00 slot duration 30 (ie 30 minutes)
                       -- => creneaux le mardi : 18:00 - 18:30 - 19:00 - 19:30
                       all_slots as (
                           SELECT generated_time::time as slot_time
                           FROM restaurants resto
                                    JOIN services s ON s.restaurant = resto.id
                                    CROSS JOIN LATERAL generate_series(
                                   p_resdate::date + s.start_time,
                                   p_resdate::date + s.end_time - (resto.slot_duration * interval '1 minute'),
                                   resto.slot_duration * interval '1 minute'
                                                       ) as generated_time
                           WHERE resto.id = p_restaurant_id
                             AND s.day_of_week = EXTRACT(isodow from p_resdate)
                       ),
                       -- 3. on récupère le nombre total de convives ayant réservé pour ce jour
                       -- (en excluant la réservation en cours de modification si p_ignore_res_id est fourni)
                       booked_today as (
                           SELECT COALESCE(SUM(number_of_guests), 0) as booked_count
                           FROM reservations r
                           WHERE r.restaurant = p_restaurant_id
                             AND r.datetime::date = p_resdate::date
                             AND r.status IN ('pending', 'confirmed')
                             AND (p_ignore_res_id IS NULL OR r.id != p_ignore_res_id)
                       )
                   -- 4. on filtre : de tous les créneaux ON RETIRE tous les créneaux si le total des convives du jour atteint ou dépasse la capacité maximale de chaises du restaurant
                   -- ce qui nous donne une liste de tous les débuts de créneaux horaires libres du restaurant en paramètre
                   -- à la date en paramètre
                   SELECT a.slot_time
                   FROM all_slots a
                            CROSS JOIN restaurant_capacity rc
                            CROSS JOIN booked_today bt
                   WHERE bt.booked_count < rc.max_seats
                   ORDER BY a.slot_time
           ) INTO v_available_slots;

    RETURN v_available_slots;
END;
$$ language plpgsql security definer;

GRANT EXECUTE ON FUNCTION get_slots_available_for_potential_reservation(timestamp, int, int) TO authenticated;


CREATE OR REPLACE FUNCTION check_capacity_for_potential_reservation(
    p_target_timestamp timestamp,
    p_restaurant_id int,
    p_requested_guests int,
    p_ignore_res_id int DEFAULT NULL
)
    RETURNS boolean
AS $$
DECLARE
    v_total_capacity int;
    v_booked_guests int;
BEGIN
    -- 1. On récupère la capacité totale du restaurant (somme des places de toutes les tables)
    SELECT COALESCE(SUM(capacity), 0) INTO v_total_capacity
    FROM tables
    WHERE restaurant = p_restaurant_id;

    -- 2. On additionne TOUS les convives qui ont réservé pour CE JOUR (statut pending ou confirmed)
    SELECT COALESCE(SUM(number_of_guests), 0) INTO v_booked_guests
    FROM reservations
    WHERE restaurant = p_restaurant_id
      AND datetime::date = p_target_timestamp::date
      AND status IN ('pending', 'confirmed')
      AND (p_ignore_res_id IS NULL OR id != p_ignore_res_id);

    -- 3. On vérifie s'il reste assez de places globales par rapport à ce qui est demandé
    RETURN (v_total_capacity - v_booked_guests) >= p_requested_guests;
END;
$$ language plpgsql security definer;

GRANT EXECUTE ON FUNCTION check_capacity_for_potential_reservation(timestamp, int, int, int) TO authenticated;


create or replace function create_reservation(
    p_restaurant_id int,
    p_reservation_time timestamp,
    p_nb_guests int,
    p_special_requests text
)
    returns void
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

    insert into reservations (
        client,
        restaurant,
        datetime,
        number_of_guests,
        special_requests
    )
    values (
               uid,
               p_restaurant_id,
               p_reservation_time,
               p_nb_guests,
               nullif(trim(p_special_requests), '')
           );
end;
$$ language plpgsql security definer;

grant execute on function create_reservation(int, timestamp, int, text) to authenticated;


create or replace function update_reservation(
    p_reservation_id int,
    p_reservation_time timestamp,
    p_nb_guests int,
    p_special_requests text
)
    returns void
as $$
declare
    uid int := auth.id();
    user_role text := auth.role();
begin
    if uid is null then
        raise exception 'Vous devez être connecté';
    end if;

    if user_role != 'client' then
        raise exception 'Vous n''êtes pas autorisé.';
    end if;

    if not exists(select 1 from reservations where id = p_reservation_id and client = uid) then
        raise exception 'Réservation introuvable ou vous n''en êtes pas le propriétaire.';
    end if;

    update reservations
    set datetime = p_reservation_time,
        number_of_guests = p_nb_guests,
        special_requests = nullif(trim(p_special_requests), '')
    where id = p_reservation_id and client = uid;

    if exists(select 1 from reservations where id = p_reservation_id and status = 'confirmed') then
        delete from reservation_tables where reservation = p_reservation_id;
        update reservations set status = 'pending' where id = p_reservation_id;
    end if;
end;
$$ language plpgsql security definer;

grant execute on function update_reservation(int, timestamp, int, text) to authenticated;