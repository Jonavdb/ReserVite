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
 * ANALYSE (Etape 2) - Requête de contrôle (pas besoin)
 * --------------------------------------------------------------------------------------
 * (Etape 3) - Fonction trigger
 */
create or replace function check_reservation_status_transition()
returns trigger as
    $$
    begin
        -- 1. Erreur : status pas 'pending' à la création
        if (tg_op = 'INSERT') then
            if new.status != 'pending'::status_type then
                RAISE EXCEPTION 'Une nouvelle réservation doit avoir le status pending';
            end if;
        end if;

        -- 2. Erreur : transition non autorisée
        if (tg_op) = 'UPDATE' then
            -- uniquement si le status change
            if old.status != new.status then
                -- on vérifie si la transition est autorisée
                if not (
                (
                    old.status = 'pending'::status_type and new.status = 'confirmed'::status_type or
                    old.status = 'pending'::status_type and new.status = 'cancelled'::status_type) or
                    old.status = 'confirmed'::status_type and new.status = 'completed'::status_type or
                    old.status = 'confirmed'::status_type and new.status = 'cancelled'::status_type

                ) then
                    RAISE EXCEPTION 'Transition de [%] à [%] interdite.',
                        old.status,
                        new.status;
                end if;
            end if;
        end if;
        return new;
    end;
    $$ language plpgsql security definer;
 ----------------------------------------------------------------------------------------
/* ANALYSE (Etape 4) - Triggers associés
 * --------------------------------------------------------------------------------------
 * - trigger_validate_reservation_status_transition (INSERT/UPDATE sur reservations)
 * ======================================================================================
 */
 create trigger trigger_validate_reservation_status_transition
        before insert or update of status
        on reservations
        for each row
    execute function check_reservation_status_transition();


