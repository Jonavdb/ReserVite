/*
 * ======================================================================================
 * GESTION DE LA CAPACITÉ DES RÉSERVATIONS
 * ======================================================================================
 *
 * OBJECTIF :
 * Le nombre de convives d'une réservation confirmée ou terminée ne peut pas
 * dépasser la capacité totale des tables associées à la réservation.
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 1) - Listing des tables concernées
 * --------------------------------------------------------------------------------------
 * Tables : reservations, reservation_tables, tables
 *
 * Événements :
 * Table reservations :
 * INSERT : Oui, au cas où le status est directement 'confirmed' ou 'completed'.
 * UPDATE : Oui, sur les colonnes status et number_of_guests.
 * DELETE : Non, car on supprime les tables associées en cascade.
 * Table reservation_tables :
 * INSERT : Non, car l'ajout d'une table augmente la capacité.
 * UPDATE : Non, car update est interdit.
 * DELETE : Oui, au cas où on supprime une table d'une réservation confirmée/completed (différé pour suppression tables associées avant annulation).
 * Table tables :
 * INSERT : Non, car la capacité d'une nouvelle table n'affecte pas les réservations existantes.
 * UPDATE : Oui, sur la colonne capacity, car cela peut réduire la capacité totale.
 * DELETE : Oui, car la suppression d'une table réduit la capacité totale.
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 2) - Requête de contrôle
 * --------------------------------------------------------------------------------------
 * select r.id, r.number_of_guests, coalesce(sum(t.capacity), 0)
 * from reservations r
 * left join reservation_tables rt on rt.reservation = r.id
 * left join tables t on t.id = rt.table
 * where r.status in ('confirmed'::status_type, 'completed'::status_type)
 * group by r.id, r.number_of_guests
 * having r.number_of_guests > coalesce(sum(t.capacity), 0);
 *
 * Note : En temps normal, aucune réservation ne doit être affichée par cette requête.
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 3) - Fonction trigger
 * --------------------------------------------------------------------------------------
 * create or replace function check_reservation_capacity()
 * returns trigger as
 * $$
 * begin
 * if exists(select r.id, r.number_of_guests, coalesce(sum(t.capacity), 0)
 * from reservations r
 * left join reservation_tables rt on rt.reservation = r.id
 * left join tables t on t.id = rt.table
 * where r.status in ('confirmed'::status_type, 'completed'::status_type)
 * group by r.id, r.number_of_guests
 * having r.number_of_guests > coalesce(sum(t.capacity), 0)) then
 * raise exception 'Le nombre de convives dépasse la capacité totale.';
 * end if;
 *
 * return null;
 * end;
 * $$ language plpgsql security definer;
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 4) - Triggers associés
 * --------------------------------------------------------------------------------------
 * - trigger_validate_reservation_capacity (INSERT/UPDATE sur reservations)
 * - trigger_validate_reservation_tables_capacity (DELETE sur reservation_tables, contrainte différée)
 * - trigger_validate_tables_capacity (UPDATE/DELETE sur tables)
 * ======================================================================================
 */

create or replace function check_reservation_capacity()
    returns trigger as
$$
begin
   if exists(select r.id, r.number_of_guests, coalesce(sum(t.capacity), 0)
         from reservations r
             left join reservation_tables rt on rt.reservation = r.id
             left join tables t on t.id = rt.table
         where r.status in ('confirmed'::status_type, 'completed'::status_type)
         group by r.id, r.number_of_guests
         having r.number_of_guests > coalesce(sum(t.capacity), 0)) then
      raise exception 'Le nombre de convives dépasse la capacité totale.';
   end if;

   return null;
end;
$$ language plpgsql security definer;

create trigger trigger_validate_reservation_capacity
         after insert or update of number_of_guests, status
         on reservations
         for each row
    execute function check_reservation_capacity();

create constraint trigger trigger_validate_reservation_tables_capacity
         after delete
         on reservation_tables
         deferrable initially deferred
         for each row
    execute function check_reservation_capacity();

create trigger trigger_validate_tables_capacity
         after update of capacity or delete
         on tables
         for each row
    execute function check_reservation_capacity();
