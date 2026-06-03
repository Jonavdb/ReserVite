/*
    Une réservation ne peut pas être créée dans le passé
    (ne doit être vérifié qu'au moment de la création).
    (on prend en compte le temps simulé s'il est défini, sinon on prend le temps réel.)
*/

-- TESTS
-- Table "réservations"
-- INSERT
-- (cas positif)
/*
  cas 1 : insérer une réservation dans le futur
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

        -- test sur la réservation fictive
        raise notice 'insérer une réservation dans le futur (cas valide)';
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-09-07 13:00:00', 10)
        returning id into v_reservation_id;
    end;
$test$;
rollback;

-- (cas negatif)
/*
  cas 1 : insérer une réservation dans le passé
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

        -- test sur la réservation fictive
        raise notice 'insérer une réservation dans le passé (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests)
                    values (' || v_user_id || ', ' || v_restaurant_id || ', ''2022-01-03 13:00:00'', 10)',
                'raise_exception'
                );
        end;
$test$;
rollback;