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

/* --------------------------------------------------------------------------------------
 * ANALYSE (Etape 3) - Fonction trigger
 * --------------------------------------------------------------------------------------