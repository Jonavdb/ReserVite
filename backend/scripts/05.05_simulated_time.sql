drop function if exists get_current_date();
create or replace function get_current_date()
    returns timestamp
as $$
declare
    v_current_date timestamp;
begin
    select simulated_time into v_current_date from system_time limit 1;

    if v_current_date is null then
        v_current_date := now();
    end if;

    return v_current_date;
end;
$$ language plpgsql security definer;
grant execute on function get_current_date() to authenticated;

drop function if exists set_current_date(new_date timestamp);
create or replace function set_current_date(new_date timestamp)
    returns bool
as $$
begin
    update system_time set simulated_time = new_date;
    return true;
end;
$$ language plpgsql security definer;
grant execute on function set_current_date(timestamp) to authenticated;




