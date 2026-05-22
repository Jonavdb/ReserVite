create or replace function get_services_for_restaurant(restaurant_id int)
    returns setof services as
$$
begin
    perform auth.check_logged();
    if (auth.role() != 'manager') then
        raise exception 'Vous n''etes pas autorise à accéder à ces tables';
end if;
    if not exists(select 1 from restaurant_managers where restaurant_managers.restaurant = restaurant_id and restaurant_managers.manager = auth.id()) then
        raise exception 'Vous n''êtes pas manager de ce restaurant';
end if;
return query select * from services s where s.restaurant = restaurant_id;
end
$$ language plpgsql security definer;

grant execute on function get_services_for_restaurant(int) to authenticated;


