/*
    Le nombre de convives d'une réservation confirmée ou terminée ne peut pas
    dépasser la capacité totale des tables associées à la réservation.
 */

-- TESTS
-- table "réservations"
-- INSERT
-- (cas positif)
/*
    cas 1 : insérer une réservation <pending> avec plusieurs guests
 */


-- (cas negatif)
/*
    cas 1 : insérer une réservation confirmée
*/

/*
    cas 2 : insérer une réservation completed
*/

-- UPDATE
-- (cas positif)
/*
    cas 1 : mettre un nombre de guests valide à une réservation <confirmed>
 */

/*
    cas 2 : confirmer une réservation (déjà liée à une table) avec un nombre de guests suffisants
*/

-- (cas negatif)
/*
    cas 1 : mettre un nombre de guests invalide à une réservation <confirmed>
*/

/*
    cas 2 : confirmer une réservation (déjà liée à une table) avec un nombre de guests insuffisants
*/

/*
=============================================================================================================================
=============================================================================================================================
*/


-- table "réservation_tables"
-- DELETE
-- (cas positif)
/*
    cas 1 : supprimer le lien à une table d.une réservation <confirmed> sans que  la capacité totale des tables associées soit excédée
 */

/*
    cas 2 : supprimer le lien à une table d.une réservation <completed> sans que  la capacité totale des tables associées soit excédée
*/


-- (cas negatif)
/*
    cas 1 : supprimer le lien à une table d.une réservation <confirmed> en faisant excéder la capacité total des tables associées
*/

/*
    cas 2 : supprimer le lien à une table  d.une réservation <completed> en faisant excéder la capacité total des tables associées
*/

/*
=============================================================================================================================
=============================================================================================================================
 */
-- table "tables"
-- UPDATE
-- (cas positif)
/*
    cas 1 : modifier la capacité d.une table d.une réservation confirmée sans que la capacité
            totale des tables de la réservation soit excédée
 */

/*
    cas 2 : modifier la capacité d.une table d.une réservation completed sans que la capacité
            totale des tables de la réservation soit excédée
*/

-- (cas negatif)
/*
    cas 1 : modifier la capacité d.une table d.une réservation confirmée en excedant la capacité
            totale des tables de la réservation
*/

/*
    cas 2 :  modifier la capacité d.une table d.une réservation completed en excedant la capacité
            totale des tables de la réservation
*/


-- DELETE
-- (cas positif)
/*
    cas 1 : supprimer une table d.une réservation confirmed sans que la capacité
            totale des tables de la réservation soit excédée
 */

/*
    cas 2 :  supprimer une table d.une réservation completed sans que la capacité
             totale des tables de la réservation soit excédée
*/

-- (cas negatif)
/*
    cas 1 : supprimer une table d.une réservation confirmed en excedant la capacité
            totale des tables de la réservation
*/

/*
    cas 2 : supprimer une table d.une réservation completed en excedant la capacité
            totale des tables de la réservation
*/
