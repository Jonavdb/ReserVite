/*
 * ======================================================================================
 * GESTION DES TRANSITIONS DE STATUS DES RESERVATIONS
 * ======================================================================================
 *
 * OBJECTIF :
 * Une nouvelle réservation doit avoir le status pending.
 * Une réservation existante ne peut pas revenir "en arrière" dans son cycle de vie.
 * Transitions autorisées :
 *  pending     ->   confirmed
 *  pending     ->   cancelled
 *  confirmed   ->   completed
 *  confirmed   ->   cancelled
 *
 * --------------------------------------------------------------------------------------
 * ANALYSE (Etape 1) - Listing des tables concernées
 * --------------------------------------------------------------------------------------
 * Tables : reservations
 *
 * Événements :
 * Table réservations
 * INSERT : oui si une nouvelle réservation a un statut différent de pending
 * UPDATE : oui si modifie la colonne status pour revenir "en arriere"
 * DELETE : non
 * --------------------------------------------------------------------------------------