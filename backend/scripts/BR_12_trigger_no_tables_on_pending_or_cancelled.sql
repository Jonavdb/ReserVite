/*
 * ======================================================================================
 * GESTION DES ASSOCIATIONS DES RESERVATIONS A DES TABLES
 * ======================================================================================
 *
 * OBJECTIF :
 * Une réservation en attente ou annulée ne peut être associée à aucune une table.
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 1) - Listing des tables concernées
 * --------------------------------------------------------------------------------------
 * Tables : reservations, reservations_tables, tables
 *
 * Événements :
 * Table "réservations"
 * INSERT : non
 * UPDATE : oui, si une reservation associée à une table est mise en 'pending' ou 'cancelled'
 * DELETE : non
 * Table "réservation_tables"
 * INSERT : oui, si la réservation introduite est 'pending' ou 'cancelled'
 * UPDATE : non, car update interdit
 * DELETE : non
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 2) - Requête de contrôle
 * --------------------------------------------------------------------------------------
 * Note : En temps normal, aucune réservation ne doit être affichée par cette requête.
 *
 * select r.id, r.status
 * from reservations r
 * left join reservation_tables rt on r.id = rt.reservation
 * left join tables t on t.id = rt."table"
 * where r.status = 'pending'::status_type OR r.status = 'cancelled'::status_type;
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 3) - Fonction trigger
 * --------------------------------------------------------------------------------------
 */
 -- check_res_no_tables_on_pending_or_cancelled
create or replace function check_res_no_tables_on_pending_or_cancelled()
    RETURNS TRIGGER AS $$
BEGIN
    -- Ici NEW.status existe !
    IF NEW.status IN ('pending', 'cancelled') THEN
        -- On regarde si des tables sont déjà liées dans l'autre table
        IF EXISTS (SELECT 1 FROM reservation_tables WHERE reservation = NEW.id) THEN
            RAISE EXCEPTION 'BR: Impossible de passer en % car des tables sont déjà liées.', NEW.status;
        END IF;
    END IF;

    RETURN NEW; -- Important : autorise la modification
END;
$$ LANGUAGE plpgsql;

 -- check_rt_no_tables_on_pending_or_cancelled
 create or replace function check_rt_no_tables_on_pending_or_cancelled()
     RETURNS TRIGGER AS $$
 DECLARE
     v_status status_type; -- ou status_type selon ton type exact
 BEGIN
     -- On doit récupérer le statut depuis l'autre table
     SELECT status INTO v_status
     FROM reservations
     WHERE id = NEW.reservation;

     -- Maintenant on peut tester la variable locale v_status
     IF v_status IN ('pending', 'cancelled') and exists(select * from reservation_tables rt where rt.reservation = new.reservation) then
         RAISE EXCEPTION 'BR: Impossible d''assigner une table à une réservation en statut %.', v_status;
     END IF;

     RETURN NEW; -- Important : autorise l'ajout de la ligne
 END;
 $$ LANGUAGE plpgsql;


/* --------------------------------------------------------------------------------------
 * ANALYSE (Etape 4) - Triggers associés
 * --------------------------------------------------------------------------------------
 * - trigger_validate_reservations_no_tables_on_pending_or_cancelled (UPDATE sur reservations)
 * - trigger_validate_reservation_tables_no_link_on_pending_or_cancelled (INSERT sur reservation_tables, contrainte différée)
 * - trigger_validate_tables_no_link_on_pending_or_cancelled (INSERT/UPDATE sur tables)
 * ======================================================================================
 */


create trigger trigger_validate_reservations_no_tables_on_pending_or_cancelled
        before update of status
        on reservations
        for each row
    execute function check_res_no_tables_on_pending_or_cancelled();

create constraint trigger trigger_validate_reservation_tables_no_link_pending_cancelled
        after insert
        on reservation_tables
        deferrable initially deferred
        for each row
execute function check_rt_no_tables_on_pending_or_cancelled();






