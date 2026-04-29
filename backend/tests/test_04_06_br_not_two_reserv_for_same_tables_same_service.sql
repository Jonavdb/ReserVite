begin;
do
$test$
declare
    my_id int;
    begin
        raise notice 'TEST : Une reservation en cours ou terminée ne peut pas exister pour la même table et le même services 2 fois(cas valide)';
        insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (6,4, '2024-12-07 19:15:00', 2,  null) returning id into my_id;
        insert into reservation_tables (reservation, "table") VALUES (my_id, '10');
    end;
$test$;
rollback;

begin;
do
$test$
declare
    my_id int;
    my_id_2 int;
    begin
        raise notice 'TEST : Une reservation en cours ou terminée ne peut pas exister pour la même table et le même services 2 fois(cas invalide)';
        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests) values (4,4, '2024-12-06 19:00:00', 1,  'pending', null) returning id into my_id;
        insert into reservation_tables (reservation, "table") VALUES (my_id, '10');
        update reservations set status = 'confirmed' where id = my_id;
        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests) values (6,4, '2024-12-06 19:00:00', 1,  'pending', null) returning id into my_id_2;
        insert into reservation_tables(reservation, "table") VALUES (my_id_2, '11');
        update reservations set status = 'confirmed' where id = my_id_2;
        perform should_fail($$
            update reservation_tables set "table" = '10' where reservation = $$ || my_id_2 || $$ ;$$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    declare
        my_id int;
        my_id_2 int;
begin
    raise notice 'TEST : Une reservation en cours ou terminée ne peut pas exister pour la même table et le même services 2 fois(cas valide)';
    insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests) values (4,4, '2024-12-06 19:00:00', 3,  'pending', null) returning id into my_id;
    insert into reservation_tables (reservation, "table") VALUES (my_id, '10');
    insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests) values (3,4, '2024-12-06 19:00:00', 3,  'pending', null) returning id into my_id_2;
    insert into reservation_tables (reservation, "table") VALUES (my_id_2, '10');
    update reservations set status = 'confirmed' where id = my_id_2;

end;
$test$;
rollback;

begin;
do
$test$
    declare
        my_id int;
        my_id_2 int;
    begin
        raise notice 'TEST : Une reservation en cours ou terminée ne peut pas exister pour la même table et le même services 2 fois(cas invalide)';
        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests) values (4,4, '2024-12-06 19:00:00', 3,  'pending', null) returning id into my_id;
        insert into reservation_tables (reservation, "table") VALUES (my_id, '10');
        update reservations set status ='confirmed' where id = my_id;
        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests) values (3,4, '2024-12-06 19:00:00', 3,  'pending', null) returning id into my_id_2;
        insert into reservation_tables (reservation, "table") VALUES (my_id_2, '10');
        perform should_fail($$
             update reservations set status = 'confirmed' where id = $$ || my_id_2 || $$ ;$$, 'raise_exception');
    end;
$test$;
rollback;

