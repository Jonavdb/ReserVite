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
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : insérer une réservation avec status <pending> (cas valide)';
        insert into reservations(id, client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (23, 6, 4, '20260501 19:00:00'::timestamp, 10,
                'pending'::status_type, null);
    end;
$test$;
rollback;

-- (cas negatif)
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : insérer une réservation avec un status different de <pending> (cas invalide)';
        perform should_fail($$
           insert into reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
            values (23, 6, 4,'20260501 19:00:00'::timestamp, 2, 'cancelled'::status_type, null);
        $$, 'raise_exception');
    end;
$test$;
rollback;

-- UPDATE
-- cas positif
rollback;
begin;
do
$test$
    begin
        -- erreur fix en rendant le trigger table restaurant mismatch en initially deferred
        raise notice 'TEST : modifier le status d.une reservation : pending -> confirmed (cas valide)';
        --  1.augmenter capacité table 1 du restaurant 2 à 100
        update tables set capacity = 100 where table_number = 1 and restaurant = 2;
        --  2.lier reservation 2 à table 1 du restaurant 2
        insert into reservation_tables (reservation, "table") values (2, 1);
        --  3.changer de pending à confirmed
        update reservations set status = 'confirmed'::status_type where id = 2;
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier le status d.une reservation : pending -> cancelled (cas valide)';
        --  changer de pending à cancelled
        update reservations set status = 'cancelled'::status_type where id = 2;
    end;
$test$;
rollback;


rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier le status d.une reservation : confirmed -> cancelled (cas valide)';
        --  changer de confirmed à cancelled
        update reservations set status = 'cancelled'::status_type where id = 3;
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier le status d.une reservation : confirmed -> completed (cas valide)';
        --  changer de confirmed à completed
        update reservations set status = 'completed'::status_type where id = 3;
    end;
$test$;
rollback;

-- cas negatif
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier une reservation de <completed> à <pending> (cas invalide)';
        perform should_fail($$
          update reservations set status = 'pending'::status_type where id = 12
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier une reservation de <completed> à <confirmed> (cas invalide)';
        perform should_fail($$
          update reservations set status = 'confirmed'::status_type where id = 12
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier une reservation de <completed> à <cancelled> (cas invalide)';
        perform should_fail($$
          update reservations set status = 'cancelled'::status_type where id = 12
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier une reservation de <cancelled> à <pending> (cas invalide)';
        perform should_fail($$
          update reservations set status = 'pending'::status_type where id = 8
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier une reservation de <cancelled> à <confirmed> (cas invalide)';
        perform should_fail($$
          update reservations set status = 'confirmed'::status_type where id = 8
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier une reservation de <cancelled> à <completed> (cas invalide)';
        perform should_fail($$
          update reservations set status = 'cancelled'::status_type where id = 8
        $$, 'raise_exception');
    end;
$test$;
rollback;


