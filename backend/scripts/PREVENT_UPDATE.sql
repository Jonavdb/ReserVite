create or replace function prevent_update() returns trigger as
$$
begin
    raise exception 'Interdit de modifier une table d''association';
end;
$$ language plpgsql security definer;

create or replace trigger tgr_prevent_update
    before update
    on reservation_tables
    for each row
execute procedure prevent_update();

create or replace trigger tgr_prevent_update
    before update
    on restaurant_managers
    for each row
execute procedure prevent_update();