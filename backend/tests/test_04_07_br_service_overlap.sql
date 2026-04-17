begin;
do
$test$
    declare
        v_test_resto_id int;

    begin
        -- insérer une valeur pour pouvoir tester le chevauchement plus bas
        insert into restaurants (name, address, city, phone)
        values ('Resto Test', '1 rue du Test', 'TestVille', '000')
        returning id into v_test_resto_id;

        -- OK
        raise notice 'insertion normale';
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_test_resto_id, 1, '12:00:00', '14:00:00');

        -- OK (service de 19h à 22h le même jour)
        raise notice 'OK (service de 19h à 22h le même jour)';
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '19:00:00', '22:00:00');

        -- KO
        raise notice 'KO (service qui commence PENDANT le premier (13h-15h))';
        perform should_fail($$
            insert into services(restaurant, day_of_week, start_time, end_time)
            values (1, 1, '13:00:00', '15:00:00');
        $$, 'raise_exception');

        raise notice 'KO (service qui englobe le premier (11h-15h)';
        perform should_fail($$
           insert into services (restaurant, day_of_week, start_time, end_time)
            values ($1, 1, '13:00:00', '15:00:00');
        $$, 'raise_exception', v_test_resto_id);
    end;
$test$;
rollback;