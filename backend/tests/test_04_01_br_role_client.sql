begin;
do
$test$
    begin
        raise notice 'TEST : Un utilisateur qui fait une reservation doit avoir le rôle de client(cas valide)';
        insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (6,4, '2024-12-07 19:00:00', 2,  null);
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST : Un utilisateur qui fait une reservation doit avoir le rôle de client(cas invalide)';
        perform should_fail($$
            insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (2,4, '2024-12-07 19:00:00', 2,  null);
        $$, 'raise_exception');
    end
$test$;
rollback;
