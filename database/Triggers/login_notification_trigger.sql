create or replace function login_notification_trigger() returns trigger
as $$
    begin
        insert into notification (time_created, username, content)
        values (now(), new.username, 'You have successfully logged in!');
        return null;
    end;
$$ language plpgsql;

create trigger login_notification_trigger after insert
    on login_log for each row
    execute function login_notification_trigger();