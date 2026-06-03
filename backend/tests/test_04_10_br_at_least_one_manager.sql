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

begin;
do
$test$
    declare
        id_new_restaurant int;
    begin
        raise notice 'TEST : Les restaurants doivent avoir au moins 1 manager (cas valide)';

        insert into restaurants (name, address, city, phone, description, rating, price_range) VALUES ('cheneeee', 'Rue de la Paix 44', 'Bruxelles', '+32 2 123 45 47', 'blablablabla', '5.0', '3') returning id into id_new_restaurant;
        insert into restaurant_managers (restaurant, manager) VALUES (id_new_restaurant, 2);
    end;
$test$;
rollback;


begin;
do
$test$
begin
    raise notice 'TEST : Les restaurants doivent avoir au moins 1 manager (cas invalide)';
    perform should_fail($$insert into restaurants (name, address, city, phone, description, rating, price_range) VALUES ('cheneeee', 'Rue de la Paix 44', 'Bruxelles', '+32 2 123 45 47', 'blablablabla', '5.0', '3');$$, 'raise_exception');
end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST : Les restaurants doivent avoir au moins 1 manager (cas invalide)';
        perform should_fail($$DELETE from users where id = '2';$$, 'raise_exception');
    end;
$test$;
rollback;