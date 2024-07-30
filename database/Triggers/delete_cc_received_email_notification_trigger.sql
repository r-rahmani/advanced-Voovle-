create or replace function delete_cc_received_email_notification_trigger() returns trigger
as $$
    begin
        if old.is_deleted_by_cc_recipient != new.is_deleted_by_cc_recipient then
            insert into notification (time_created, username, content)
            values (now(), new.cc_recipient_username, 'You have successfully deleted a cc_received email!');
        end if;
        return null;
    end;
$$ language plpgsql;

create trigger delete_cc_received_email_notification_trigger after update
    on cc_recipient for each row
    execute function delete_cc_received_email_notification_trigger();