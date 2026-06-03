/*
 * ======================================================================================
 * GESTION DE LA CREATION D'UNE RESERVATION DANS LE PASSÉ
 * ======================================================================================
 *
 * OBJECTIF :
 * Une réservation ne peut pas être créée dans le passé
 * (ne doit être vérifié qu'au moment de la création).
 * (on prend en compte le temps simulé s'il est défini, sinon on prend le temps réel.)
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 1) - Listing des tables concernées
 * --------------------------------------------------------------------------------------
 * Tables : reservations
 *
 * Événements :
 * Table "réservations"
 * INSERT : oui, si la date de création est supérieure à la date de réservation
 * UPDATE : non
 * DELETE : non
 -----------------------------------------------------------------------
 * ANALYSE (Etape 2) - Requête de contrôle - X
 * -----------------------------------------------------------------------
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 3) - Fonction trigger
 * --------------------------------------------------------------------------------------
 */
create or replace function check_no_reservation_created_in_the_past()
    returns trigger as
$$
declare
    v_now timestamp; --
begin
    if (tg_op = 'INSERT') then
        -- on récupère la date simulée s'il elle existe..
        select simulated_time from system_time limit 1 into v_now;

        -- sinon on récupère la date actuelle
        if v_now is null then
            v_now := now();
        end if;

        -- erreur : reservation insérée dans le pass"
        if (new.datetime < v_now) then
            raise exception 'Une réservation ne peut pas être créée dans le passé';
        end if;
    end if;

    return new;
end;
$$ language plpgsql security definer;

----------------------------------------------------------------------------------------
/* ANALYSE (Etape 4) - Triggers associés
 * --------------------------------------------------------------------------------------
 * - trigger_validate_no_reservation_created_in_the_past (INSERT/UPDATE sur reservations)
 * ======================================================================================
 */
create trigger trigger_validate_no_reservation_created_in_the_past
    before insert
    on reservations
    for each row
execute function check_no_reservation_created_in_the_past();
