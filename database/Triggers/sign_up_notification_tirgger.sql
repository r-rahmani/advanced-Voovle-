create or replace function sign_up_notification_trigger() returns trigger
as $$
    begin
        insert into notification (time_created, username, content)
        values (now(), new.username, format('Hello %s, welcome to Voovle!', new.username));
        return null;
    end;
$$ language plpgsql;

create trigger sign_up_notification_trigger after insert
    on "user" for each row
    execute function sign_up_notification_trigger();