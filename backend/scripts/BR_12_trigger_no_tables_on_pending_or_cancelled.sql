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
 create or replace function check_no_tables_on_pending_or_cancelled()
 returns trigger as
 $$
 begin
     if exists(select r.id, r.status
                from reservations r
                join reservation_tables rt on r.id = rt.reservation
                join tables t on t.id = rt."table"
                where r.status = 'pending'::status_type OR r.status = 'cancelled'::status_type) then
     raise exception 'Une réservation en attente ou annulée ne peut être associée à aucune une table.';
     end if;

 return null;
 end;
 $$ language plpgsql security definer;
/* --------------------------------------------------------------------------------------
 * ANALYSE (Etape 4) - Triggers associés
 * --------------------------------------------------------------------------------------
 * - trigger_validate_reservations_no_tables_on_pending_or_cancelled (UPDATE sur reservations)
 * - trigger_validate_reservation_tables_no_link_on_pending_or_cancelled (INSERT sur reservation_tables, contrainte différée)
 * - trigger_validate_tables_no_link_on_pending_or_cancelled (INSERT/UPDATE sur tables)
 * ======================================================================================
 */


create trigger trigger_validate_reservations_no_tables_on_pending_or_cancelled
        after update of status
        on reservations
        for each row
    execute function check_no_tables_on_pending_or_cancelled();

create constraint trigger trigger_validate_reservation_tables_no_link_pending_cancelled
        after insert
        on reservation_tables
        deferrable initially deferred
        for each row
execute function check_no_tables_on_pending_or_cancelled();






