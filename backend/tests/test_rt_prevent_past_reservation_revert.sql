begin;
do
$test$
    declare
        _test_reservation_id int;

    begin
        -- j'insère une résa dans le futur
        insert into reservations(client, restaurant, datetime, number_of_guests, status, special_requests)
        values (6, 4, '2067-12-06 19:00:00.000000', 4, 'confirmed', null)
        returning id into _test_reservation_id;

        raise notice 'OK : on passe de confirm a pending dans une réservation future';
        update reservations set status = 'pending' where id = _test_reservation_id;
        set constraints all immediate;

        raise notice 'KO : le statut d''une réservation peut passer de confirmed à pending uniquement si la réservation est dans le futur !';
        update reservations set status = 'pending' where id = 1;
    end;
$test$;
rollback;