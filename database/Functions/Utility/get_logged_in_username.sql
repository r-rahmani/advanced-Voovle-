create or replace function get_logged_in_username()
returns varchar(50)
as $$
    declare
        result varchar(50);
    begin
        select ll.username
        into result
        from login_log as ll
        order by time desc
            limit 1;

        return result;
    end;
$$ language plpgsql;