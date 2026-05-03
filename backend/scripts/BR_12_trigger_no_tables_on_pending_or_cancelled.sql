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
 * UPDATE : oui, si on modifie la colonne status de 'confirmed' / 'completed' à 'pending' / 'cancelled'
 * DELETE : non
 * Table "réservation_tables"
 * INSERT : oui, si la réservation introduite est 'pending' ou 'cancelled'
 * UPDATE : non, car update interdit
 * DELETE : non
 * Table "tables"
 * INSERT : oui, si la table insérée est liée à un restaurant dont la réservation est 'pending' ou 'cancelled'
 * UPDATE : oui, si on modifie la colonne restaurant, et que c'est un restaurant dont la réservation est 'pending' ou 'cancelled'
 * DELETE : non
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 2) - Requête de contrôle
 * --------------------------------------------------------------------------------------
 * Note : En temps normal, aucune réservation ne doit être affichée par cette requête.
 */
 select r.id, r.status
 from reservations r
 join reservation_tables rt on r.id = rt.reservation
 where r.status = 'pending'::status_type OR r.status = 'cancelled'::status_type;



