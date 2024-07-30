create or replace function get_permission_overrides ()
returns table (
    searching_username varchar(50),
    is_permitted boolean
)
as $$
    declare
        logged_in_username varchar(50);
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        return query select po.searching_username, po.is_permitted
        from permission_override po
        where po.owner_username = logged_in_username;

    end
    $$ language plpgsql;