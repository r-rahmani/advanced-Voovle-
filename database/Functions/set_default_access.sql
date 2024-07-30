create or replace function set_default_access (accessed_by_default boolean)
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        update "user" u set
            accessed_by_default = set_default_access.accessed_by_default
        where u.username = logged_in_username;

        return 'Success!'::varchar;
    end
$$ language plpgsql;