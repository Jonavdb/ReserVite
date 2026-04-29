begin;
do
$test$
    begin
        raise notice 'TEST : Une reservation completé ou annulée ne peut pas être modifiée (cas valide)';
        Update reservations set datetime = '2024-12-07 19:00:00' where id = '22';
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST : Une reservation completé ou annulée ne peut pas être modifiée(cas invalide)';
        perform should_fail($$
            Update reservations set datetime = '2024-12-07 19:00:00' where id = '18';
        $$, 'raise_exception');
    end
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'TEST : Une reservation completé ou annulée ne peut pas être modifiée(cas invalide)';
        insert into reservation_tables(reservation, "table")  VALUES (22, 11);
        Update reservations set status = 'completed' where id = '22';
        perform should_fail($$
            Update reservations set datetime = '2024-12-07 19:00:00' where id = '22';
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST : Une reservation completé ou annulée ne peut pas être modifiée(cas invalide)';
        perform should_fail($$
            Delete from reservation_tables where reservation = '12';
        $$, 'raise_exception');
    end
$test$;
rollback;




