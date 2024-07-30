create or replace function delete_sent_email_notification_trigger() returns trigger
as $$
    begin
        if old.is_deleted_by_sender != new.is_deleted_by_sender then
            insert into notification (time_created, username, content)
            values (now(), new.sender_username, 'You have successfully deleted a sent email!');
        end if;
        return null;
    end;
$$ language plpgsql;

create trigger delete_sent_email_notification_trigger after update
    on email for each row
    execute function delete_sent_email_notification_trigger();