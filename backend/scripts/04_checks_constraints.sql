alter table users
    add constraint ck_users_name_length
        check (length(trim(full_name)) >= 3);

alter table users
    add constraint ck_password_format
        check (
            (length(password) >= 8
            and password ~ '[A-Z]'
            and password ~ '[0-9]'
            and password ~ '[a-z]'
            and password ~ '[,;.:?!&/$%@#]')
            or password ~ '^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$');

create or replace function can_not_change_role()
    returns TRIGGER as
    $$
    BEGIN
        if new.role != old.role then
            Raise EXCEPTION 'Le rôle d''un utilisateur ne peut pas être modifié';
        end if;

        return new;
    end;
    $$ language plpgsql;

create trigger trg_can_not_change_role
BEFORE UPDATE of role on users
FOR each row
EXECUTE PROCEDURE can_not_change_role();

alter table restaurants
    add constraint ck_restaurant_note
        check(rating >= 0.0 and rating <= 5.0);

alter table restaurants
    add constraint ck_restaurant_rating
        check(price_range >= 1 and price_range <= 4);

alter table restaurants
    add constraint ck_restaurant_phone
        check(
            replace(phone, ' ', '') ~ '^(0|\+32|0032)[0-9]{8,9}$');
-- Je remplace au cas où les espaces sont présents en les enlevant et ma regex vérifie que ça commence par 0 ou +32 ou 0032
-- et qu'ensuite on a entre 8 et 9 chiffres dépendant de si c'est un fix ou un mobile

alter table restaurants
    add constraint ck_restaurant_name
        check(length(name) => 5);

alter table users
    add constraint ck_users_phone
        check(
            replace(phone, ' ', '') ~ '^(0|\+32|0032)[0-9]{8,9}$');
