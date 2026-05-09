/*
    Le nombre de convives d'une réservation confirmée ou terminée ne peut pas
    dépasser la capacité totale des tables associées à la réservation.
 */

-- TESTS
-- table "réservations"
-- INSERT
-- (cas positif)
/*
    cas 1 : insérer une réservation <pending> avec plusieurs guests
 */
rollback;
begin;
set constraints all immediate;
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

        -- bypass
        ALTER TABLE restaurants DISABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);

        -- end bypass
        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;


        -- test sur la réservation fictive
        raise notice 'TEST : créer une réservation avec plusieurs guests (cas valide)';
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
set constraints all immediate;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
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

        -- end bypass
        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- test sur la réservation fictive
        raise notice 'TEST : créer une réservation confirmée (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests, status)
                 values (' || v_user_id || ', ' || v_restaurant_id || ', ''2026-05-04 13:00:00'', 10, ''confirmed''::status_type)',
                'raise_exception'
                );
    end;
$test$;
rollback;


/*
    cas 2 : insérer une réservation completed
*/

rollback;
begin;
set constraints all immediate;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_service_id int;
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

        -- end bypass
        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- test sur la réservation fictive
        raise notice 'TEST : créer une réservation completed (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests, status)
                 values (' || v_user_id || ', ' || v_restaurant_id || ', ''2026-05-04 13:00:00'', 10, ''completed''::status_type)',
                'raise_exception'
                );
    end;
$test$;
rollback;

-- UPDATE
-- (cas positif)
/*
    cas 1 : mettre un nombre de guests valide à une réservation <confirmed>
 */
rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservatuin
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme la réservation
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;


        -- test sur la réservation fictive
        raise notice 'TEST : mettre un nombre de guests valides à une réservation confirmée (cas valide)';
        update reservations set number_of_guests = 60 where id = v_reservation_id;
    end;
$test$;
rollback;
/*
    cas 2 : confirmer une réservation (déjà liée à une table) avec un nombre de guests suffisants
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservatuin
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;


        -- test sur la réservation fictive
        raise notice 'TEST : confirmer une réservation (déjà liée à une table) avec un nombre de guests suffisants (cas valide)';
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

-- (cas negatif)
/*
    cas 1 : mettre un nombre de guests invalide à une réservation <confirmed>
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservatuin
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme la réservation
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;


        -- test sur la réservation fictive
        raise notice 'TEST : mettre un nombre de guests invalide à une réservation confirmée (cas invalide)';
        perform should_fail(
                'update reservations set number_of_guests = 2000 where id = ' || v_reservation_id,
                'raise_exception'
                );
    end;
$test$;
rollback;


/*
    cas 2 : confirmer une réservation (déjà liée à une table) avec un nombre de guests insuffisants
    cas 2 : confirmer une réservation (déjà liée à une table) avec un nombre de guests invalide
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 2000)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;


        -- test sur la réservation fictive
        perform should_fail(
                'update reservations set status = ''confirmed''::status_type where id = ' || v_reservation_id,
                'raise_exception'
                );
    end;
$test$;
rollback;

/*
=============================================================================================================================
=============================================================================================================================
*/


-- table "réservation_tables"
-- DELETE
-- (cas positif)
/*
    cas 1 : supprimer le lien à une table d.une réservation <confirmed> sans que  la capacité totale des tables associées soit excédée
 */
rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservation_tables DISABLE TRIGGER cant_updated_reservation_cpl_ccl_reservation_tables;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on crée une deuxieme table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+4), 9)
        returning id into v_table2_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);

        -- on confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- test sur la réservation fictive
        raise notice 'TEST : supprimer le lien à une réservation confirmed sans que la capacité totale soit excédée (cas valide)';
        delete from reservation_tables where "table" = v_table2_id;
    end;
$test$;
rollback;

/*
    cas 2 : supprimer le lien à une table d.une réservation <completed> sans que  la capacité totale des tables associées soit excédée
*/
rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservation_tables DISABLE TRIGGER cant_updated_reservation_cpl_ccl_reservation_tables;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on crée une deuxieme table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+4), 9)
        returning id into v_table2_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);

        -- on confirme et on complete
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- test sur la réservation fictive
        raise notice 'TEST : supprimer le lien à une réservation completed sans que la capacité totale soit excédée (cas valide)';
        delete from reservation_tables where "table" = v_table2_id;
    end;
$test$;
rollback;
-- (cas negatif)
/*
    cas 1 : supprimer le lien à une table d.une réservation <confirmed> en faisant excéder la capacité total des tables associées
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on la confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- test sur la réservation fictive
        raise notice 'supprimer le lien à une table d.une réservation <confirmed>';
        perform should_fail(
                'delete from reservation_tables where reservation = ' || v_reservation_id,
                'raise_exception'
                );
    end;
$test$;
rollback;
/*
    cas 2 : supprimer le lien à une table  d.une réservation <completed> en faisant excéder la capacité total des tables associées
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservation_tables DISABLE TRIGGER cant_updated_reservation_cpl_ccl_reservation_tables;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on la confirme, puis complete
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservations ENABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- test sur la réservation fictive
        raise notice 'supprimer le lien à une table d.une réservation <completed>';
        perform should_fail(
                'delete from reservation_tables where reservation = ' || v_reservation_id,
                'raise_exception'
                );
    end;
$test$;
rollback;
/*
=============================================================================================================================
=============================================================================================================================
 */
-- table "tables"
-- UPDATE
-- (cas positif)
/*
    cas 1 : modifier la capacité d.une table d.une réservation confirmée sans que la capacité
            totale des tables de la réservation soit excédée
 */

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- test sur la réservation fictive
        raise notice 'TEST : modifier la capacité d.une table d.une réservation confirmée sans que la capacité totale de la réservation soit excédée (cas valide)';
        update tables set capacity = 80 where id = v_table_id;
    end;
$test$;
rollback;

/*
    cas 2 : modifier la capacité d.une table d.une réservation completed sans que la capacité
            totale des tables de la réservation soit excédée
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme, et on complète
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations ENABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- test sur la réservation fictive
        raise notice 'TEST : modifier la capacité d.une table d.une réservation completed sans que la capacité totale de la réservation soit excédée (cas valide)';
        update tables set capacity = 90 where id = v_table_id;
    end;
$test$;
rollback;
-- (cas negatif)
/*
    cas 1 : modifier la capacité d.une table d.une réservation confirmée en excedant la capacité
            totale des tables de la réservation
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;

        -- test sur la réservation fictive
        raise notice 'TEST : modifier la capacité d.une table d.une réservation confirmée en excedant la capacité totale de la table de la réservation (cas invalide)';
        perform should_fail(
                'update tables set capacity = 8 where id = ' || v_table_id,
                'raise_exception'
                );
    end;
$test$;
rollback;

/*
    cas 2 :  modifier la capacité d.une table d.une réservation completed en excedant la capacité
            totale des tables de la réservation
*/
rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme, puis complète
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations ENABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- test sur la réservation fictive
        raise notice 'TEST : modifier la capacité d.une table d.une réservation completed en excedant la capacité totale de la table de la réservation (cas invalide)';
        perform should_fail(
                'update tables set capacity = 8 where id = ' || v_table_id,
                'raise_exception'
                );
    end;
$test$;
rollback;

-- DELETE
-- (cas positif)
/*
    cas 1 : supprimer une table d.une réservation confirmed sans que la capacité
            totale des tables de la réservation soit excédée
 */

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 12)
        returning id into v_table_id;

        -- on crée une deuxieme table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+2), 12)
        returning id into v_table2_id;

        -- on les lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);

        -- on confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations ENABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- test sur la réservation fictive
        raise notice 'TEST : supprimer une table d.une réservation confirmed sans que la capacité totale des tables de la réservation soit excédée (cas valide)';
        delete from tables where id = v_table2_id;
    end;
$test$;
rollback;
/*
    cas 2 :  supprimer une table d.une réservation completed sans que la capacité
             totale des tables de la réservation soit excédée
*/

rollback;
begin;
set constraints all immediate;
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

        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservation_tables DISABLE TRIGGER cant_updated_reservation_cpl_ccl_reservation_tables;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 12)
        returning id into v_table_id;

        -- on crée une deuxieme table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+2), 12)
        returning id into v_table2_id;

        -- on les lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);

        -- on confirme, et on complete
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;


        -- test sur la réservation fictive
        raise notice 'TEST : supprimer une table d.une réservation confirmed sans que la capacité totale des tables de la réservation soit excédée (cas valide)';
        delete from tables where id = v_table2_id;
    end;
$test$;
rollback;

-- (cas negatif)
/*
    cas 1 : supprimer une table d.une réservation confirmed en excedant la capacité
            totale des tables de la réservation
*/

rollback;
begin;
set constraints all immediate;
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
        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 9)
        returning id into v_table_id;

        -- on crée une deuxieme table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+2), 9)
        returning id into v_table2_id;

        -- on les lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);

        -- on confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations ENABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- test sur la réservation fictive
        raise notice 'TEST :supprimer une table d.une réservation confirmed en excedant la capacité
            totale des tables de la réservation (cas invalide)';
        perform should_fail(
                'delete from tables where id = ' || v_table2_id,
                'raise_exception'
                );
    end;
$test$;
rollback;

/*
    cas 2 : supprimer une table d.une réservation completed en excedant la capacité
            totale des tables de la réservation
*/
rollback;
begin;
set constraints all immediate;
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
        ALTER TABLE restaurants ENABLE TRIGGER trg_restaurant_have_at_least_one_manager_on_restaurant;

        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- bypass
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables DISABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations DISABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 9)
        returning id into v_table_id;

        -- on crée une deuxieme table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, (v_table_number+2), 9)
        returning id into v_table2_id;

        -- on les lie à la réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table2_id);

        -- on confirme, puis on complète
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'completed'::status_type where id = v_reservation_id;

        -- on remet les règles avant le test
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_no_link_pending_cancelled;
        ALTER TABLE reservation_tables ENABLE TRIGGER trigger_validate_reservation_tables_capacity;
        ALTER TABLE reservations ENABLE TRIGGER completed_or_cancelled_reservation_cant_be_updated;

        -- test sur la réservation fictive
        raise notice 'TEST : supprimer une table d.une réservation completed en excedant la capacité
            totale des tables de la réservation (cas invalide)';
        perform should_fail(
                'delete from tables where id = ' || v_table2_id,
                'raise_exception'
                );
    end;
$test$;
rollback;