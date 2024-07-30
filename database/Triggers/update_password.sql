create or replace function update_password_notification_trigger() returns trigger
as $$
    begin
        if old.password != new.password then
            insert into notification (time_created, username, content)
            values (now(), new.username, 'You have successfully changed your password!');
        end if;
        return null;
    end;
$$ language plpgsql;

create trigger update_password_notification_trigger after update
    on "user" for each row
    execute function update_password_notification_trigger();