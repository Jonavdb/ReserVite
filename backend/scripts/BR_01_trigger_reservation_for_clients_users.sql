create or replace function reservation_only_for_user_with_role() returns trigger as
$$
declare
    role_client role_type;
begin
    select users.role into role_client
    from users
    where id = new.client;

    if role_client != 'client' then
        raise exception 'Un utilisateur doit avoir le rôle de client pour faire une reservation';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_reservation_only_for_user_with_role
    before INSERT or update on reservations
    FOR each row
    execute PROCEDURE reservation_only_for_user_with_role();
