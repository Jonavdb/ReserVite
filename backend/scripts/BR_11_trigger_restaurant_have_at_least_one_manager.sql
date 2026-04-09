create or replace function restaurant_have_at_least_one_manager() returns trigger as
$$
declare
number_of_manager int;
begin
select count(*) from restaurant_managers where restaurant = old.restaurant into number_of_manager;
if number_of_manager <= 1 then
        raise exception 'Un restaurant doit avoir au moins un manager';
end if;
return old;
end;
$$ language plpgsql;

create trigger trg_restaurant_have_at_least_one_manager
before DELETE on restaurant_managers
for each row
execute procedure restaurant_have_at_least_one_manager();