/*
 * ======================================================================================
 * GESTION DES RESERVATIONS SUR LE MEME SERVICE ET A LA MEME DATE
 * ======================================================================================
 *
 * OBJECTIF :
 * Un client ne peut pas avoir deux réservations en attente, confirmées ou terminées
 * pour une même date et un même service.
 *
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 1) - Listing des tables concernées
 * --------------------------------------------------------------------------------------
 * Tables : reservations, services
 *
 * Événements :
 * Table "réservations"
 * INSERT : oui, si le client a deja une reservation (canelled non inclus) à cette date et à ce même service
 * UPDATE : oui, sur les colonnes :
 *              client : peut entrainer une réservation dupliquée pour une même date et un même service
 *              restaurant : peut entrainer une réservation dupliquée pour une même date et un même service
 *              datetime : peut entrainer une réservation dupliquée pour une même date et un même service
 *              status : peut entrainer une réservation dupliquée pour une même date et un même service
 * DELETE : non
 * Table "services"
 * INSERT : non, car il n'y aura jamais de reservation déja faite pour une
            date à un service qui n'existait pas de base
 * UPDATE : oui, sur la colonne restaurant
 * DELETE : non
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 2) - Requête de contrôle (ne doit rien retourner)
 * --------------------------------------------------------------------------------------
 *
 * select count(*) as nb_reservations_same_time
 * from reservations r
 * join users c on c.id = r.client
 * join restaurants res on res.id = r.restaurant
 * join services s on s.restaurant = res.id
 * where r.status = 'pending'::status_type
 *   OR r.status = 'confirmed'::status_type
 *   OR r.status = 'completed'::status_type
 * group by c.id, r.datetime, s.id having count(*) > 1;

 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 3) - Fonction trigger
 * --------------------------------------------------------------------------------------
 */
create or replace function check_unique_client_reservation_same_service_excl_cancelled()
    returns trigger as
$$
begin
    if NEW.status not in ('pending', 'confirmed', 'completed') then
        return NEW; -- on sort direct, la règle ne s'applique pas aux annulations
    end if;

    if exists (
        select 1
        from reservations r
                 join services s on s.restaurant = r.restaurant
        where r.client = NEW.client
          and r.id is distinct from NEW.id -- important si c'est une UPDATE
          and r.status in ('pending', 'confirmed', 'completed')
          and r.datetime::date = NEW.datetime::date
          and s.day_of_week = extract(isodow from NEW.datetime)
          and NEW.datetime::time between s.start_time and s.end_time
          and r.datetime::time between s.start_time and s.end_time
    ) then
        raise exception 'Un client ne peut pas avoir deux réservations actives pour le même service.';
    end if;

    return NEW;
end;
$$ language plpgsql security definer;

/* ANALYSE (Etape 4) - Triggers associés
 * --------------------------------------------------------------------------------------
 * - trg_val_res_unique_client_same_service_excl_cancelled (INSERT/UPDATE sur reservations)
 * - trg_val_svc_unique_client_same_service_excl_cancelled (UPDATE sur service)
 * ======================================================================================
 */

create trigger trg_val_res_unique_client_same_service_excl_cancelled
        before insert or update of client, restaurant, datetime, status
        on reservations
        for each row
    execute function check_unique_client_reservation_same_service_excl_cancelled();

create trigger trg_val_svc_unique_client_same_service_excl_cancelled
        before update of restaurant
        on services
        for each row
    execute function check_unique_client_reservation_same_service_excl_cancelled();

