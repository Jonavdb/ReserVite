begin;
do
$test$
    declare
        v_test_resto_id int;
        v_test_resto_id_2 int;

    begin
        -- insérer une valeur pour pouvoir tester le chevauchement plus bas
        insert into restaurants (name, address, city, phone)
        values ('Resto Test', '1 rue du Test', 'TestVille', '+32 2 123 45 68')
        returning id into v_test_resto_id;

        -- OK
        raise notice 'OK (insertion normale)';
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_test_resto_id, 1, '12:00:00', '14:00:00');

        -- OK (service de 19h à 22h le même jour)
        raise notice 'OK (service de 19h à 22h le même jour)';
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_test_resto_id, 1, '19:00:00', '22:00:00')
        returning id into v_test_resto_id_2;

        -- KO
        raise notice 'KO (service qui commence PENDANT le premier (13h-15h))';
        perform should_fail($$
            insert into services(restaurant, day_of_week, start_time, end_time)
            values ($$ || v_test_resto_id || $$, 1, '13:00:00', '15:00:00');
        $$, 'raise_exception');

        -- KO
        raise notice 'KO (service qui englobe le premier (11h-15h)';
        perform should_fail($$
           insert into services (restaurant, day_of_week, start_time, end_time)
           values ($$ || v_test_resto_id || $$, 1, '11:00:00', '15:00:00');
        $$, 'raise_exception');

        -- KO
        raise notice 'KO (service qui commence AVANT et s''arrête PENDANT (11h-13h))';
        perform should_fail($$
            insert into services(restaurant, day_of_week, start_time, end_time)
            values ($$ || v_test_resto_id || $$, 1, '11:00:00', '13:00:00');
        $$, 'raise_exception');

        -- KO
        raise notice 'KO (heures strictement identiques)';
        perform should_fail($$
            insert into services(restaurant, day_of_week, start_time, end_time)
            values ($$ || v_test_resto_id || $$, 1, '12:00:00', '14:00:00');
        $$, 'raise_exception');

        -- KO
        raise notice 'KO (service à l''intérieur)';
        perform should_fail($$
            insert into services(restaurant, day_of_week, start_time, end_time)
            values ($$ || v_test_resto_id || $$, 1, '12:30:00', '13:30:00');
        $$, 'raise_exception');

        -- TESTS UPDATE

        -- OK
        raise notice 'OK (UPDATE pour une période valide (de 16h à 18h))';
        update services set start_time = '16:00:00', end_time = '18:00:00'
        where id = v_test_resto_id_2;

        -- OK
        raise notice 'OK (commence pile à la fin du premier)';
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_test_resto_id, 1, '14:00:00', '16:00:00');

        -- OK
        raise notice 'OK (finit pile au début du premier)';
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (v_test_resto_id, 1, '10:00:00', '12:00:00');

        -- KO
        raise notice 'KO (update qui commence AVANT et s''arrête PENDANT (11h-13h))';
        perform should_fail($$
            update services set start_time = '11:00:00', end_time = '13:00:00'
            where id = $$ || v_test_resto_id_2 || $$;
        $$, 'raise_exception');

        -- KO
        raise notice 'KO (UPDATE qui englobe un autre service)';
        perform should_fail($$
            update services set start_time = '11:00:00', end_time = '15:00:00'
            where id = $$ || v_test_resto_id_2 || $$
        $$, 'raise_exception');

        -- KO
        raise notice 'KO (UPDATE qui commence pendant un autre)';
        perform should_fail($$
            update services set start_time = '13:00:00', end_time = '15:00:00'
            where id = $$ || v_test_resto_id_2 || $$
        $$, 'raise_exception');
    end;
$test$;
rollback;