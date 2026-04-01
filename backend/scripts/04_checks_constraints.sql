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

