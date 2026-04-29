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