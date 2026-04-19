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

create or replace function restaurant_have_at_least_one_manager_on_restaurants() returns trigger as
$$
declare
    number_of_manager int;
begin
    select count(*) from restaurant_managers where restaurant = new.id into number_of_manager;
    if number_of_manager < 1 then
        raise exception 'un restaurant doit avoir au moins un manager';
    end if;
return new;
end;
$$ language plpgsql;

create or replace function restaurant_have_at_least_one_manager_on_users() returns trigger as
$$
begin
    if tg_op = 'DELETE' or (tg_op = 'UPDATE' and old.role = 'manager' and new.role != 'manager') then
        if exists(select * from restaurant_managers rm1 where manager = old.id and (select count(*) from restaurant_managers rm2 where rm2.restaurant = rm1.restaurant) = 1) then
            raise exception 'un restaurant doit avoir au moins un manager';
        end if;
    end if;
return old;
end;
$$ language plpgsql;

create trigger trg_restaurant_have_at_least_one_manager
before DELETE on restaurant_managers
for each row
execute procedure restaurant_have_at_least_one_manager();


create constraint trigger trg_restaurant_have_at_least_one_manager_on_restaurant
 after insert
on restaurants
deferrable initially deferred
for each row
execute procedure restaurant_have_at_least_one_manager_on_restaurants();

create trigger trg_restaurant_have_at_least_one_manager_on_users
before DELETE or UPDATE on users
for each row
execute procedure restaurant_have_at_least_one_manager_on_users();