create or replace function get_notifications ()
returns table (
    time_created timestamp,
    content varchar(512)
)
as $$
    declare
        logged_in_username varchar(50);
    begin

        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --getting notifications
        return query select n.time_created, n.content
        from notification n
        where n.username = logged_in_username
        order by n.time_created desc;

    end;
$$ language plpgsql;