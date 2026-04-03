begin;
do
$test$
    begin
        raise notice 'TEST : Une reservation doit se faire dans un créneau(cas valide)';
        insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (6,4, '2024-12-07 19:15:00', 2,  null);
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST : Une reservation doit se faire dans un créneau(cas invalide)';
        perform should_fail($$
            insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (6,4, '2024-12-07 19:10:00', 2,  null);
        $$, 'raise_exception');
    end
$test$;
rollback;
