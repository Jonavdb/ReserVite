/*
    Le nombre de convives d'une réservation confirmée ou terminée ne peut pas
    dépasser la capacité totale des tables associées à la réservation.
*/
                                            -- TESTS POSITIFS
-- Table réservations
    -- INSERT :
rollback;
begin;
do
$test$
begin
    raise notice 'TEST : insérer une réservation <pending> avec plusieurs guests (cas valide)';
    insert into reservations(id, client, restaurant, datetime, number_of_guests, status, special_requests)
    VALUES (23, 6, 4, '20260501 19:00:00'::timestamp, 10,
            'pending'::status_type, null);
end;
$test$;
rollback;

    -- UPDATE :
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : mettre un nombre de guests valide à une réservation <confirmed> (cas valide)';
        update reservations set number_of_guests = 3 where id = 11;
    end;
$test$;
rollback;

-- Table réservation_tables
    -- DELETE :
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : supprimer une table d.une réservation <confirmed> sans que  la capacité totale des tables associées soit excédée (cas valide)';
        update tables set capacity = 15 where table_number = 3; -- on augmente artificiellement la capacité totale
        delete from reservation_tables where reservation = 7 and "table" = 3; -- on supprime cette table de la réservation
    end;
$test$;
rollback;

-- Table tables
    -- UPDATE :
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier la capacité d.une table d.une réservation (confirmed ou completed) sans que la capacité '
            ' totale des tables de la réservation soit excédée (cas valide)';
        update tables set capacity = 3 where table_number = 1 and restaurant = 1;
    end;
$test$;
rollback;

    -- DELETE :
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : supprimer une table d.une réservation (confirmed ou completed) sans que la capacité '
            ' totale des tables de la réservation soit excédée (cas valide)';
        UPDATE reservations SET status = 'pending'
                            WHERE id != 7
                            and status != 'completed'::status_type
                            and status != 'cancelled'::status_type;
        -- je mets toutes les réservations en 'pending' sauf celles 'cancelled' et 'completed' pour isoler la réservation 7
        -- la réservation 7 (nb guests : 8) a 2 tables du restaurant 1 : table 2 (capacité 4) et table 3 (capacité 6)
        update tables set capacity = 999 where table_number = 3 and restaurant = 1; -- je mets une grosse capacité a la table 3
        delete from tables where table_number = 2 and restaurant = 1; -- je supprime la table 2, et normalement la capacité totale reste valide
    end;
$test$;
rollback;


                                            -- TESTS NEGATIFS
-- Table réservations
    -- INSERT :
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : insérer une réservation <confirmed> -> capacité totale table 0 (cas invalide)';
        perform should_fail($$
           insert into reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
            values (23, 6, 4,'20260501 19:00:00'::timestamp, 2, 'confirmed'::status_type, null);
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : insérer une réservation <completed> -> capacité totale table 0 (cas invalide)';
        perform should_fail($$
           insert into reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
            values (23, 6, 4,'20260501 19:00:00'::timestamp, 2, 'completed'::status_type, null);
        $$, 'raise_exception');
    end;
$test$;
rollback;

    -- UPDATE
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : mettre un nombre de guests trop élevé à une réservation <confirmed> (cas invalide)';
        perform should_fail($$
           update reservations set number_of_guests = 999 where id = 6;
        $$, 'raise_exception');
    end;
$test$;
rollback;

rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : mettre une réservation <pending> non liée à des tables en <confirmed> (cas invalide)';
        perform should_fail($$
           update reservations set status = 'confirmed'::status_type where id = 5;
        $$, 'raise_exception');
    end;
$test$;
rollback;

-- Table réservation_tables
    -- DELETE :
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : supprimer une table d.une réservation <confirmed> rendant la capacité totale inférieure au nombre de guests (cas invalide)';
        perform should_fail($$
          delete from reservation_tables where (reservation = 7 and reservation_tables."table" = 2)
        $$, 'raise_exception');
    end;
$test$;
rollback;

-- Table tables
    -- UPDATE
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : modifier la capacité d.une table d.une réservation (confirmed ou completed) en faisant en sorte que '
            'la capacité totale des tables de la réservation soit excédée (cas invalide)';
        perform should_fail($$
            update tables set capacity = 1 where table_number = 1 and restaurant = 1;
            $$);
    end;
$test$;
rollback;

    -- DELETE
rollback;
begin;
do
$test$
    begin
        raise notice 'TEST : supprimer une table d.une réservation (confirmed ou completed) en rendant la capacité '
            ' totale des tables de la réservation insuffisante (cas invalide)';
        UPDATE reservations SET status = 'pending'
        WHERE id != 7
          and status != 'completed'::status_type
          and status != 'cancelled'::status_type;
        -- je mets toutes les réservations en 'pending' sauf celles 'cancelled' et 'completed' pour isoler la réservation 7
        -- la réservation 7 (nb guests : 8) a 2 tables du restaurant 1 : table 2 (capacité 4) et table 3 (capacité 6)
        PERFORM should_fail($$
        DELETE FROM tables
        WHERE table_number = 3 AND restaurant = 1;
    $$, 'P0001'); -- je supprime la table 3 -> capacité totale devient invalide
    end;
$test$;
rollback;
