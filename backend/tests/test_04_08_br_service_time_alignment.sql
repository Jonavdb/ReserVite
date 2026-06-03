begin;
do
$test$
    declare
        test_resto_id int;
    begin
        -- ----------------------------------------------------------------
        -- RESTAURANT AVEC CRÉNEAUX DE 30 MINUTES
        -- ----------------------------------------------------------------
        insert into restaurants (id, name, address, city, phone, description, rating, price_range, slot_duration)
        values (default, 'Resto Demi Heure', 'Rue de demi heure', 'Bruxelles', '+32 2 123 45 67',
                'Restaurant gastronomique belge', 4.5, 3, 30)
        returning id into test_resto_id;

        -- OK : Service aligné sur 30 min
        raise notice 'OK : Service de 12h00 à 14h00 (Aligné sur 30 min)';
        insert into services (id, restaurant, day_of_week, start_time, end_time)
        values (default, test_resto_id, 1, '12:00:00', '14:00:00');

        -- KO : Début non aligné
        raise notice 'KO : Début à 19h15 (Non aligné sur 30 min)';
        perform should_fail($$
            insert into services (id, restaurant, day_of_week, start_time, end_time)
            values (101, 1, 1, '19:15:00', '22:30:00');
        $$, 'raise_exception');

        -- ----------------------------------------------------------------
        -- RESTAURANT AVEC CRÉNEAUX DE 15 MINUTES
        -- ----------------------------------------------------------------
        insert into restaurants (id, name, address, city, phone, description, rating, price_range, slot_duration)
        values (default, 'Resto Quart dHeure', 'Rue du quart dheure', 'Bruxelles', '+32 2 123 45 67',
                'Restaurant gastronomique belge', 4.5, 3, 15)
        returning id into test_resto_id;

        -- KO : Fin non alignée
        raise notice 'KO : Fin à 22h20 (Non aligné sur 15 min)';
        perform should_fail($$
            insert into services (id, restaurant, day_of_week, start_time, end_time)
            values (102, 1, 1, '19:15:00', '22:20:00');
        $$, 'raise_exception');

    end;
$test$;
rollback;