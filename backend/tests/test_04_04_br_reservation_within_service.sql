-- TEST RESERVATIONS INSERT
begin;
do
$test$
    begin
        raise notice 'OK : INSERT une réservation couverte par les services';
        insert into reservations(client, restaurant, datetime, number_of_guests, status, special_requests)
        values (3, 2, '2026-04-14 13:00:00', 3, 'confirmed', null);
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'KO : INSERT une réservation NON couverte par les services';
        perform should_fail($$
        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
        values (3, 2, '2026-04-14 15:00:00', 3, 'confirmed', null);
        $$, 'raise_exception');
        end;
$test$;
rollback;

-- TEST RESERVATIONS UPDATE
begin;
do
$test$
    begin
        raise notice 'OK : UPDATE une réservation couverte par les services';
        update reservations set datetime = '2026-04-14 13:00:00' where id = '21';
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'KO : UPDATE une réservation NON couverte par les services';
        perform should_fail($$
        update reservations set datetime = '2026-04-14 15:00:00' where id = '21';
        $$, 'raise_exception');
    end;
$test$;
rollback;

-- TEST SERVICES UPDATE
begin;
do
$test$
    declare
        _fictif_id int;
    begin
        raise notice 'OK : UPDATE une réservation couverte par les services.';

        -- Insérer un service fictif pour le test
        insert into services(restaurant, day_of_week, start_time, end_time)
        values (8, 7, '18:00:00', '21:00:00')
        returning id into _fictif_id;

        update services set start_time = '19:00:00' where id = _fictif_id;
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'KO : UPDATE un service dont une réservation existe déjà.';
        perform should_fail($$
        update services set end_time = '19:30:00' where id = '20';
        $$, 'raise_exception');
    end;
$test$;
rollback;


