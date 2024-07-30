create or replace function send_email (email_subject varchar(50), email_content varchar(512), variadic email_addresses varchar(50)[])
returns varchar(50)
as $$
    declare
        item varchar(53);
        at_least_one_recipient_found boolean;
        recipient_username varchar(50);
        recipient "user";
        email_id integer;
        logged_in_username varchar(50);
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        at_least_one_recipient_found = false;

        --validation recipients
        foreach item in array email_addresses
        loop

            --checking for voovle.com
            if item not like '%@voovle.com' then
                raise exception 'Wrong Email address "%". An email address must end with "voovle.com"', item;
            end if;

            --handling cc recipients
            if substring(item, 0, 4) = 'cc:' then
                recipient_username = lower(substring(item, 4, length(item) - 14));
            else
                recipient_username = lower(substring(item, 0, length(item) - 10));
            end if;

            --checking for "deleted_account"
            if recipient_username = 'deleted_account' then
                raise exception 'Username "%" does not exist.', recipient_username;
            end if;

            --checking if the username exists
            select *
            into recipient
            from "user" u
            where u.username = recipient_username;

            if recipient.username is null then
                raise exception 'Username "%" does not exist.', recipient_username;
            end if;

            if substring(item, 0, 4) != 'cc:' then
                at_least_one_recipient_found = true;
            end if;

        end loop;

        --checking of the user has entered at least one recipient
        if at_least_one_recipient_found = false then
            raise exception 'You must enter at least one recipient!';
        end if;

        --creating email record
        insert into email (sender_username, subject, content, time_sent, is_deleted_by_sender, is_read_by_sender)
        values (logged_in_username, email_subject, email_content, now(), false, false);
        email_id = currval(pg_get_serial_sequence('email','id'));

        --creating recipient and cc_recipient records
        foreach item in array email_addresses
        loop
            --handling cc recipients
            if substring(item, 0, 4) = 'cc:' then
                recipient_username = lower(substring(item, 4, length(item) - 14));
                insert into cc_recipient values (email_id, recipient_username, false, false);
            else
                recipient_username = lower(substring(item, 0, length(item) - 10));
                insert into recipient values (email_id, recipient_username, false, false);
            end if;

        end loop;

        return 'Email successfully sent!'::varchar;

    end;
$$ language plpgsql;