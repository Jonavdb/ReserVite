/*
 -- =============================================
-- TEST CASE: [Brief description]
-- AUTHOR: [Name]
-- =============================================
ROLLBACK;
BEGIN;

-- 1. THE TRUTH SERUM
-- No hiding behind deferred checks.
SET CONSTRAINTS ALL IMMEDIATE;

-- 2. SETUP PHASE
-- Create the bare minimum (Client, Restau, etc.)
-- [Variables and Setup Logic]

-- 3. THE "ACT" PHASE
-- If this fails where it shouldn't, someone's trigger is broken.
-- If this succeeds where it should fail, YOUR trigger is broken.
-- [Target SQL Command or PERFORM should_fail(...)]

-- 4. THE CLEANUP
ROLLBACK;
 */


/*
   Une réservation en attente ou annulée ne peut être associée à aucune une table..
*/

-- TESTS
-- table "reservations"
-- UPDATE
-- (cas positif)
/*
 cas 1 : annuler une nouvelle reservation
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


        -- test sur la réservation fictive
        raise notice 'TEST : on annule une nouvelle réservation (cas valide)';
        update reservations set status = 'cancelled'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

/*
cas 2 : annuler une réservation confirmée
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

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme la réservation
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on supprime la liaison entre la réservation fictive et ses tables
        delete from reservation_tables where reservation = v_reservation_id;


        -- test sur la réservation fictive
        raise notice 'TEST : on annule une réservation confirmée (cas valide)';
        update reservations set status = 'cancelled'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

-- (cas negatif)
/*
cas 1 : mettre en cancelled une réservation déjà associées à une/des tables
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

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);



        -- test sur la réservation fictive
        raise notice 'TEST : on met une réservation avec au moins une table, en <cancelled> (cas invalide)';
        perform should_fail(
                'update reservations set status = ''cancelled''::status_type where id = ' || v_reservation_id,
                'raise_exception'
                );

    end;
$test$;
rollback;
/*
cas 2 :
mettre en pending une réservation déjà associées à une/des tables
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

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- test sur la réservation fictive
        raise notice 'TEST : on met une réservation avec au moins une table, en <pending> (cas invalide)';
        perform should_fail(
                'update reservations set status = ''pending''::status_type where id = ' || v_reservation_id,
                'raise_exception'
                );

    end;
$test$;
rollback;

-- table "reservation_tables"
-- INSERT
-- cas positif
/*
   cas 1 : lier une reservation confirmed à une table
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

        -- bypass
        ALTER TABLE restaurants DISABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

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

        -- on crée une autre table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+3), 999)
        returning id into v_table2_id;

        -- test sur la réservation fictive
        raise notice 'TEST : on lie une réservation confirmée à une table (cas valide)';
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);
    end;
$test$;
rollback;
/*
   cas 2 : lier une reservation completed à une table
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

        -- on la lie à la réservation fictive
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirma la réservation
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;


        -- on la complète
        update reservations set status = 'completed'::status_type where id = v_reservation_id;


        -- on crée une autre table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+3), 999)
        returning id into v_table2_id;

        -- test sur la réservation fictive
        raise notice 'TEST : on lie une réservation completed à une table (cas valide)';
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);
    end;
$test$;
rollback;
-- cas negatif
/*
 cas 1 : lier une reservation pending à une table
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


        -- test sur la réservation fictive
        perform should_fail(
                'insert into reservation_tables (reservation, "table") values (' || v_reservation_id || ', ' || v_table_id || ')',
                'raise_exception'
                );

    end;
$test$;
rollback;

/*
 cas 2 : lier une reservation cancelled à une table
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


        -- on la met en attente
        update reservations set status = 'cancelled'::status_type where id = v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- test sur la réservation fictive
        perform should_fail(
                'insert into reservation_tables (reservation, "table") values (' || v_reservation_id || ', ' || v_table_id || ')',
                'raise_exception'
                );

    end;
$test$;
rollback;
