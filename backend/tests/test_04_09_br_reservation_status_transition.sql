/*
    Une nouvelle réservation doit avoir le status pending.
    Une réservation existante ne peut pas revenir "en arrière" dans son cycle de vie.
    Transitions autorisées :
       pending     ->   confirmed
       pending     ->   cancelled
       confirmed   ->   completed
       confirmed   ->   cancelled
    La transition confirmed -> pending est autorisée dans certains cas (voir règles temporelles).
*/

-- TESTS
-- Table "reservations"
-- INSERT
-- (cas positif)
/*
  cas 1 : insérer une réservation en attente
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        raise notice 'insérer une réservation en attente (cas valide)';
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;
    end;
$test$;
rollback;

-- (cas negatif)
/*
  cas 1 : insérer une réservation confirmée
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        raise notice 'insérer une réservation confirmée (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests, status)
                 values (' || v_user_id || ', ' || v_restaurant_id || ', ''2026-05-04 13:00:00'', 10, ''confirmed''::status_type)',
                'raise_exception'
                );
    end;
$test$;
rollback;

/*
  cas 2 : insérer une réservation complété
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;

        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        raise notice 'insérer une réservation complété (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests, status)
                 values (' || v_user_id || ', ' || v_restaurant_id || ', ''2026-05-04 13:00:00'', 10, ''completed''::status_type)',
                'raise_exception'
                );
    end;
$test$;
rollback;


/*
  cas 3 : insérer une réservation cancelled
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;

        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        raise notice 'insérer une réservation cancelled (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests, status)
                 values (' || v_user_id || ', ' || v_restaurant_id || ', ''2026-05-04 13:00:00'', 10, ''cancelled''::status_type)',
                'raise_exception'
                );
    end;
$test$;
rollback;

-- UPDATE
-- (cas positif)
/*
  cas 1 : faire la transition : pending -> confirmed
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);


        -- test sur la réservation fictive
        raise notice 'TEST : pending -> confirmed (cas valide)';
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

    end;
$test$;
rollback;

/*
  cas 2 : faire la transition : pending -> cancelled
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);


        -- test sur la réservation fictive
        raise notice 'TEST : pending -> cancelled (cas valide)';
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

    end;
$test$;
rollback;

/*
    cas 3 : faire la transition : confirmed -> cancelled
*/

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);


        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservatuin
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme la réservation
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- ..
        delete from reservation_tables where reservation = v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : confirmed -> cancelled (cas valide)';
        update reservations set status = 'cancelled'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

/*
    cas 4 : faire la transition : confirmed -> completed
*/

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on la confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;


        -- test sur la réservation fictive
        raise notice 'TEST : confirmed -> completed (cas valide)';
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

    end;
$test$;
rollback;

/*
  cas 5 : mettre une réservation de confirmed à pending pour une réservation dans le futur
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on la confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;


        -- on supprime le lien
        delete from reservation_tables where reservation = v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : confirmed -> pending (cas valide)';
        update reservations set status = 'pending'::status_type where id = v_reservation_id;

    end;
$test$;
rollback;


-- (cas negatif)
/*
  cas 1 : mettre une réservation complété en attente
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;


        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on la confirme, on complète
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;


        -- test sur la réservation fictive
        raise notice 'TEST : mettre une réservation completé en attente (cas invalide)';
        perform should_fail(
                'update reservations set status = ''pending''::status_type where id = ' || v_reservation_id,
                'raise_exception'
                );

    end;
$test$;
rollback;

/*
  cas 2 : mettre une réservation complété à confirmée
 */

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
        v_reservation_id int;
        v_table_id int;
        v_table2_id int;
        v_table_number int := 4;
    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;

        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on la confirme, on complète
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;


        -- test sur la réservation fictive
        raise notice 'TEST : mettre une réservation completé en attente (cas invalide)';
        perform should_fail(
                'update reservations set status = ''confirmed''::status_type where id = ' || v_reservation_id,
                'raise_exception'
                );

    end;
$test$;
rollback;


