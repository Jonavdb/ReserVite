/*
    Un client ne peut pas avoir deux réservations en attente, confirmées ou terminées
    pour une même date et un même service.
 */

 -- TESTS
-- Table "réservations"
-- INSERT
-- (cas positif)
/*
  cas 1 : insérer une réservation pour une date et un service non alloués
 */


-- (cas negatif)
/*
  cas 1 : insérer une réservation pour une date et un service déjà alloués
 */

-- UPDATE
-- (cas positif)
/*
  cas 1 : associer pour unne réservation à une date et un service donnée,
  un client n'en a aucune à cette date et ce service
 */

/*
  cas 2 : associer pour unne réservation à une date et un service donnée,
  un restaurant qui n'a pas de client ayant fait une réservation à cette date et ce service
 */

/*
    cas 3 : pour un client donnée, mettre une date de réservation qui ne coincide pas avec une autre réservation de client à cette même date et ce
    même service
*/

/*
    cas 4 : réservation mise en attente, et il n'y a aucune autre réservation de ce client faite à cette date et ce service
*/

/*
    cas 5 : réservation confirmé, et il n'y a aucune autre réservation de ce client faite à cette date et ce service
*/

/*
    cas 6 : réservation complété, et il n'y a aucune autre réservation de ce client faite à cette date et ce service
*/

/*
    cas 7 : réservation annulée, jamais d'erreur déclenchée dans ce cas là
 */


-- (cas negatif)
/*
  cas 1 : associer pour unne réservation à une date et un service donnée,
  un client a déjà une réservation à cette date et ce service
 */

/*
  cas 2 : associer pour unne réservation à une date et un service donnée,
  un restaurant qui a déjà un client ayant fait une réservation à cette date et ce service
 */

/*
    cas 3 : pour un client donnée, mettre une date de réservation qui coincide  avec une autre réservation de client à cette même date et ce
    même service
*/

/*
    cas 4 : réservation mise en attente, et il y'a une autre réservation de ce client faite à cette date et ce service
*/

/*
    cas 5 : réservation confirmé, et il y'a une autre réservation de ce client faite à cette date et ce service
*/

/*
    cas 6 : réservation complété, et il y'a une autre réservation de ce client faite à cette date et ce service
*/


/*
  ==================================================================================================
  ==================================================================================================
  ==================================================================================================
  ==================================================================================================
 */

-- Table "services"
-- UPDATE
-- (cas positif)
/*
  cas 1 : mettre un restaurant qui n'a pas d'autre réservations à ce service
 */



-- (cas negatif)
/*
  cas 1 : mettre un restaurant qui a dejà autre réservations à ce service
 */

