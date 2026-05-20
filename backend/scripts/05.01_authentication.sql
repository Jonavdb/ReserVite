set search_path to public, auth;

/**************************************************************
 Fonctions qui permettent de faire le signup
 **************************************************************/
drop function if exists is_fullname_available(text);

create or replace function is_fullname_available(fullname text) returns bool as
$$
begin
    return not exists(
        select 1
        from users
        where lower(users.full_name) = lower(is_fullname_available.fullname)
    );
end;
$$ language plpgsql security definer;

grant execute on function is_fullname_available to anon;

drop function if exists is_email_available(text);

create or replace function is_email_available(email text) returns bool as
$$
begin
    return not exists(
        select 1
        from users
        where lower(users.email) = lower(is_email_available.email)
    );
end;
$$ language plpgsql security definer;

grant execute on function is_email_available to anon;

-- Une fonction signup qui permet de créer un nouvel utilisateur.
-- Elle prend en paramètre un fullname, un email et un mot de passe et retourne void.
-- Elle doit vérifier que le fullname et l'email ne sont pas déjà utilisés.
drop function if exists signup(text, text, text, text);

create or replace function signup(fullname text, email text, password text, phone text default null)
    returns void as
$$
begin
    if not is_fullname_available(signup.fullname) then
        raise exception 'Fullname % is already used.', signup.fullname;
    end if;

    if not is_email_available(signup.email) then
        raise exception 'Email % is already used.', signup.email;
    end if;

    -- On insère directement le fullname, l'email et le mot de passe
    insert into users(full_name, email, password, phone)
    values (signup.fullname, signup.email, signup.password, signup.phone);
end;
$$ language plpgsql security definer;

grant execute on function signup to anon;