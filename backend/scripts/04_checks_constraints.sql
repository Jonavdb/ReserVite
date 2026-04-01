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
