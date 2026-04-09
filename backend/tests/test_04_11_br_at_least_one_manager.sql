begin;
do
$test$
begin
        raise notice 'TEST : Les restaurants doivent avoir au moins 1 manager (cas valide)';

        insert into restaurant_managers(restaurant, manager) VALUES (6,2);
        delete from users where id = 5;
end;
$test$;
rollback;

begin;
do
$test$
begin
        raise notice 'TEST : Les restaurants doivent avoir au moins 1 manager (cas invalide)';
        perform should_fail($$
                    delete from users where id = 5;
        $$, 'raise_exception');
end;
$test$;
rollback;