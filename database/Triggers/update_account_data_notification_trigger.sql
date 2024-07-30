create or replace function update_account_data_notification_trigger() returns trigger
as $$
    begin
        insert into notification (time_created, username, content)
        values (now(), new.username, 'You have successfully updated your account data!');
        return null;
    end;
$$ language plpgsql;

create trigger update_account_data_notification_trigger after update
    on "user" for each row
    execute function update_account_data_notification_trigger();