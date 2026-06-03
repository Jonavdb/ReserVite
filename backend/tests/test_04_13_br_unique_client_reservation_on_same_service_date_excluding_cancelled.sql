/*
    Un client ne peut pas avoir deux réservations en attente, confirmées ou terminées
    pour une même date et un même service.
 */

 -- TESTS
-- Table "réservations"
-- INSERT
-- (cas positif)
/*
  cas 1 : insérer une réservation pour une date et un service non alloués
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

        -- test sur la réservation fictive
        raise notice 'TEST : on insère une réservation pour une date et un service non alloués (cas valide)';
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;
    end;
$test$;
rollback;

/*
  cas 2 : insérer une réservation pour une date et un service avec deux reservations à la même date dont 1 est cancelled,
            donc ne compte pas
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
        v_reservation2_id int;
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

        -- on crée une réservation
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (v_user_id, v_restaurant_id, '2026-05-04 12:30:00', 10, 'pending'::status_type)
        returning id into v_reservation_id;

        -- on l'annule
        update reservations set status = 'cancelled'::status_type where id = v_reservation_id;

        -- test sur la réservation fictive
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (v_user_id,  v_restaurant_id,'2026-05-04 13:00:00', 11, 'pending'::status_type)
        returning id into v_reservation2_id;
    end;
$test$;
rollback;



-- (cas negatif)
/*
  cas 1 : insérer une réservation pour une date et un service déjà alloués
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
        v_reservation2_id int;
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

        -- on crée une première réservation
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10, 'pending'::status_type)
        returning id into v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : on insère une réservation pour une date et un service déjà alloués (cas invalide)';
        perform should_fail(
                'insert into reservations (client, restaurant, datetime, number_of_guests, status)
                    values (' || v_user_id || ', ' || v_restaurant_id || ', ''2026-05-04 13:00:00'', 10, ''pending''::status_type)',
                'raise_exception'
                );
    end;
$test$;
rollback;

-- UPDATE
-- (cas positif)
/*
  cas 1 : associer pour unne réservation à une date et un service donnée,
  à un client n'en a aucune à cette date et ce service
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
        raise notice 'TEST : associer pour unne réservation à une date et un service donnée,
                            à un client qui n''en a aucune à cette date et ce service (cas valide)';
        update reservations set client = v_user_id where id = v_reservation_id;

    end;
$test$;
rollback;

/*
  cas 2 : associer pour unne réservation à une date et un service donnée,
  un restaurant qui n'a pas de client ayant fait une réservation à cette date et ce service
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
        values (v_user_id, v_restaurant_id, '2026-05-11 13:00:00', 10)
        returning id into v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : associer pour unne réservation à une date et un service donnée,
                     un restaurant qui n''a pas de client ayant fait une réservation à cette date et ce service (cas valide)';
        update reservations set restaurant = v_restaurant_id where id = v_reservation_id;
    end;
$test$;
rollback;

/*
    cas 3 : pour un client donnée, mettre une date de réservation qui ne coincide pas avec une autre réservation de client à cette même date et ce
    même service
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
        values (v_user_id, v_restaurant_id, '2026-05-11 13:00:00', 10)
        returning id into v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : pour un client donnée, mettre une date de réservation qui ne coincide pas avec une autre
                    réservation de client à cette même date et ce même service (cas valide)';
        update reservations set datetime = '2026-05-11 13:00:00' where id = v_reservation_id;
    end;
$test$;
rollback;

/*
    cas 4 : réservation mise en attente, et il n'y a aucune autre réservation de ce client faite à cette date et ce service
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
        values (v_user_id, v_restaurant_id, '2026-05-11 13:00:00', 10)
        returning id into v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : réservation mise en attente, et il n''y a aucune autre réservation de ce client
            faite à cette date et ce service (cas valide)';
        update reservations set status = 'pending'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

/*
    cas 5 : réservation confirmé, et il n'y a aucune autre réservation de ce client faite à cette date et ce service
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
        values (v_user_id, v_restaurant_id, '2026-05-11 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- test sur la réservation fictive
        raise notice 'TEST : réservation confirmée, et il n''y a aucune autre réservation de ce client
            faite à cette date et ce service (cas valide)';
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

/*
    cas 6 : réservation complété, et il n'y a aucune autre réservation de ce client faite à cette date et ce service
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
        values (v_user_id, v_restaurant_id, '2026-05-11 13:00:00', 10)
        returning id into v_reservation_id;


        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on la lie à une réservation
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);

        -- on confirme
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;

        -- test sur la réservation fictive
        raise notice 'TEST : réservation complété, et il n''y a aucune autre réservation de ce client
            faite à cette date et ce service (cas valide)';
        update reservations set status = 'completed'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

/*
    cas 7 : réservation annulée, jamais d'erreur déclenchée dans ce cas là
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
        values (v_user_id, v_restaurant_id, '2026-05-11 13:00:00', 10)
        returning id into v_reservation_id;


        -- test sur la réservation fictive
        raise notice 'TEST : réservation annulée, jamais d''erreur déclenchée dans ce cas là (cas valide)';
        update reservations set status = 'cancelled'::status_type where id = v_reservation_id;
    end;
$test$;
rollback;

-- (cas negatif)
/*
  cas 1 : associer pour unne réservation à une date et un service donnée,
  un client a déjà une réservation à cette date et ce service
 */

/*rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_user2_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_restaurant2_id int;
        v_service_id int;
        v_service2_id int;
        v_reservation_id int;
        v_reservation2_id int;
        v_table_id int;
        v_table_number int := 4;


    begin
        -- on crée un user (client)
        insert into users (email, password, full_name)
        values ('manu@manu.fr', 'MySecureP@ss2026', 'client,')
        returning id into v_user_id;

        -- on crée un deuxieme user (client)
        insert into users (email, password, full_name)
        values ('manu@manuuuu.fr', 'MySecureP@ss2026', 'client2,')
        returning id into v_user2_id;

        -- on crée un user (manager)
        insert into users (email, password, full_name)
        values ('manager@manu.fr', 'MySecureP@ss2026', 'manager,')
        returning id into v_manager_id;

        -- on crée un restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannah', 'rue akhira', 'heaven', '0470 12 34 56')
        returning id into v_restaurant_id;

        -- on crée un deuxieme restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannahhh', 'rue akhiraaaa', 'heavenaa', '0471 12 34 56')
        returning id into v_restaurant2_id;


        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);


        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée un deuxieme service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant2_id, 1, '12:00:00', '14:00:00')
        returning id into v_service2_id;


        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- on crée une deuxieme réservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user2_id, v_restaurant2_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation2_id;

        -- on crée une table
        insert into tables (restaurant, table_number, capacity)
        values (v_restaurant_id, v_table_number, 999)
        returning id into v_table_id;

        -- on lie les réservations
        insert into reservation_tables (reservation, "table") values (v_reservation_id, v_table_id);
        insert into reservation_tables (reservation, "table") values (v_reservation2_id, v_table_id);

        -- on confirme les deux réservations
        update reservations set status = 'confirmed'::status_type where id = v_reservation_id;
        update reservations set status = 'confirmed'::status_type where id = v_reservation2_id;

        -- ..
        update reservations set client = v_user_id where id = v_reservation2_id;

        -- test sur la réservation fictive
        raise notice 'TEST : associer pour unne réservation à une date et un service donnée,
                         un client a déjà une réservation à cette date et ce service(cas invalide)';
        perform should_fail(
                'update reservations set restaurant = '|| v_reservation2_id || ' where id =  '|| v_reservation_id || ';',
                'raise_exception'
                );
    end;
$test$;
rollback;*/

/*
  cas 2 : associer pour unne réservation à une date et un service donnée,
  un restaurant qui a déjà un client ayant fait une réservation à cette date et ce service
 */

/*rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_restaurant2_id int;
        v_service_id int;
        v_service2_id int;
        v_reservation_id int;
        v_reservation2_id int;
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

        -- on crée un deuxieme restaurant
        insert into restaurants (name, address, city, phone)
        values ('jannahhh', 'rueeee akhira', 'hhheaven', '0471 12 34 56')
        returning id into v_restaurant2_id;

        -- on crée un restaurant manager
        insert into restaurant_managers (restaurant, manager)
        values (v_restaurant_id, v_manager_id);


        -- on crée un service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 1, '12:00:00', '14:00:00')
        returning id into v_service_id;

        -- on crée un deuxieme service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant2_id, 1, '12:00:00', '14:00:00')
        returning id into v_service2_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- on crée une deuxieme réservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant2_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation2_id;


        -- test sur la réservation fictive
        raise notice 'TEST : associer pour unne réservation à une date et un service donnée,
                    un restaurant qui a déjà un client ayant fait une réservation à cette date et ce service (cas invalide)';
        perform should_fail(
                'update reservations set restaurant = '|| v_restaurant_id || ' where id =  '|| v_reservation2_id || ';',
                'raise_exception'
                );
    end;
$test$;
rollback;*/


/*
    cas 3 : pour un client donnée, mettre une date de réservation qui coincide  avec une autre réservation de client à cette même date et ce
    même service
*/

/*rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_restaurant2_id int;
        v_service_id int;
        v_service2_id int;
        v_reservation_id int;
        v_reservation2_id int;
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

        -- on crée un deuxieme service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 2, '12:00:00', '14:00:00')
        returning id into v_service2_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- on crée une deuxieme réservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-05 13:00:00', 10)
        returning id into v_reservation2_id;

        -- test sur la réservation fictive
        raise notice 'TEST : pour un client donnée, mettre une date de réservation qui coincide avec une autre
             réservation de client à cette même date et ce même service (cas invalide)';
        perform should_fail(
                'update reservations set datetime = ''2026-05-04 13:00:00'' where id =  '|| v_reservation2_id || ';',
                'raise_exception'
                );
    end;
$test$;
rollback;*/

/*
    cas 4 : réservation mise en attente, et il y'a une autre réservation de ce client faite à cette date et ce service
*/

rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_restaurant2_id int;
        v_service_id int;
        v_service2_id int;
        v_reservation_id int;
        v_reservation2_id int;
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

        -- on crée un deuxieme service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 2, '12:00:00', '14:00:00')
        returning id into v_service2_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- on crée une deuxieme réservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-05 13:00:00', 10)
        returning id into v_reservation2_id;


        -- on annule la deuxieme
        update reservations set status = 'cancelled'::status_type where id = v_reservation2_id;

        -- on met la deuxieme reservation a la meme date que la première
        update reservations set datetime = '2026-05-04 13:00:00' where id = v_reservation2_id;

        -- test sur la réservation fictive
        raise notice 'TEST : réservation mise en attente, et il y''a une autre réservation de ce client faite
            à cette date et ce service (cas invalide)';
        perform should_fail(
                'update reservations set status = ''pending''::status_type where id =  '|| v_reservation2_id || ';',
                'raise_exception'
                );
    end;
$test$;
rollback;

/*
    cas 5 : réservation confirmé, et il y'a une autre réservation de ce client faite à cette date et ce service
*/

/*rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_restaurant2_id int;
        v_service_id int;
        v_service2_id int;
        v_reservation_id int;
        v_reservation2_id int;
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

        -- on crée un deuxieme service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 2, '12:00:00', '14:00:00')
        returning id into v_service2_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- on crée une deuxieme réservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-05 13:00:00', 10)
        returning id into v_reservation2_id;


        -- on confirme la deuxieme
        update reservations set status = 'confirmed'::status_type where id = v_reservation2_id;


        -- test sur la réservation fictive
        raise notice 'TEST : réservation confirmé, et il y''a une autre réservation de ce client faite
            à cette date et ce service (cas invalide)';
        perform should_fail(
                ' update reservations set datetime = ''2026-05-04 13:00:00'' where id = ' || v_reservation2_id ||  ';',
                'raise_exception'
                );
    end;
$test$;
rollback;*/

/*
    cas 6 : réservation complété, et il y'a une autre réservation de ce client faite à cette date et ce service
*/

/*rollback;
begin;
do
$test$
    declare
        v_user_id int;
        v_manager_id int;
        v_restaurant_id int;
        v_restaurant2_id int;
        v_service_id int;
        v_service2_id int;
        v_reservation_id int;
        v_reservation2_id int;
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

        -- on crée un deuxieme service
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_restaurant_id, 2, '12:00:00', '14:00:00')
        returning id into v_service2_id;

        -- on crée une reservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-04 13:00:00', 10)
        returning id into v_reservation_id;

        -- on crée une deuxieme réservation
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (v_user_id, v_restaurant_id, '2026-05-05 13:00:00', 10)
        returning id into v_reservation2_id;



        -- on confirme la deuxieme, et on la complete
        update reservations set status = 'confirmed'::status_type where id = v_reservation2_id;
        update reservations set status = 'completed'::status_type where id = v_reservation2_id;


        -- test sur la réservation fictive
        raise notice 'TEST : réservation complété, et il y''a une autre réservation de ce client faite
            à cette date et ce service (cas invalide)';
        perform should_fail(
                ' update reservations set datetime = ''2026-05-04 13:00:00'' where id = ' || v_reservation2_id ||  ';',
                'raise_exception'
                );
    end;
$test$;
rollback;*/
