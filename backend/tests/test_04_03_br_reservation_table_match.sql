begin;
do
$test$
    begin
        raise notice 'TEST : Les tables associées à une réservation doivent appartenir au restaurant de la réservation. (cas valide)';
--         delete from reservation_tables where reservation = 81 and "table" = 1;
        insert into reservation_tables(reservation, "table") values (81, 1);
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST : Les tables associées à une réservation doivent appartenir au restaurant de la réservation. (cas invalide)';
        perform should_fail($$
            insert into reservation_tables(reservation, "table") values (1, 5);
        $$, 'raise_exception');
    end;
$test$;
rollback;