create or replace function delete_received_email_notification_trigger() returns trigger
as $$
    begin
        if old.is_deleted_by_recipient != new.is_deleted_by_recipient then
            insert into notification (time_created, username, content)
            values (now(), new.recipient_username, 'You have successfully deleted a received email!');
        end if;
        return null;
    end;
$$ language plpgsql;

create trigger delete_received_email_notification_trigger after update
    on recipient for each row
    execute function delete_received_email_notification_trigger();