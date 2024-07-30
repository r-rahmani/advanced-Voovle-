create or replace function get_default_access ()
returns boolean
as $$
    declare
        logged_in_username varchar(50);
        result boolean;
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        select accessed_by_default
        into result
        from "user" u
        where u.username = logged_in_username;

        return result;
    end
$$ language plpgsql;