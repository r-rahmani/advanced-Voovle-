create or replace function cc_recipient_notification_trigger() returns trigger
as $$
    declare
        email_sender_username varchar(50);
    begin
        --getting the sender
        select sender_username
        into email_sender_username
        from email e
        where e.id = new.email_id;

        insert into notification (time_created, username, content)
        values (now(), new.cc_recipient_username, format('You have an email from %s!', email_sender_username || '@voovle.com'));
        return null;
    end;
$$ language plpgsql;

create trigger cc_recipient_notification_trigger after insert
    on cc_recipient for each row
    execute function cc_recipient_notification_trigger();