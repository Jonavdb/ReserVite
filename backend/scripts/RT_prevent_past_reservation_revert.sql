create or replace function prevent_past_reservation_revert() returns trigger as
$$
    declare
        _current_time timestamp;
    begin
        -- comme demandé dans l'énoncé on prend en compte le temps simulé s'il est défini, sinon on prend le temps réel
        select coalesce(simulated_time, now()) into _current_time
        from system_time;

        -- on ne vérifie la règle QUE si on passe de confirmed à pending
        if old.status = 'confirmed' and new.status = 'pending' then
            -- la date de résa doit être strictement dans le futur
            if new.datetime <= _current_time then
                raise exception 'Règle temporelle: impossible de repasser la réservation en "pending" car elle est déjà passée ou en cours.';
            end if;
        end if;

        return new;
    end;
$$ language plpgsql;

drop trigger if exists trg_prevent_past_reservation_revert on reservations;

create trigger trg_prevent_past_reservation_revert
before update of status
on reservations
for each row
execute procedure prevent_past_reservation_revert();