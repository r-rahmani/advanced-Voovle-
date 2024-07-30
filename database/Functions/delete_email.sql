create or replace function delete_email (requested_email_id integer)
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
        email_record email;
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --getting the email
        select *
        into email_record
        from email e
        where e.id = requested_email_id;

        if email_record.id is null then
            --error
            raise exception 'Email not found!';
        end if;


        --if sender
        update email e
        set is_deleted_by_sender = true
        where (e.id, e.sender_username, e.is_deleted_by_sender) = (email_record.id, logged_in_username, false);

        if FOUND = true then
            return 'Email successfully deleted!'::varchar;
        end if;

        --if recipient
        update recipient r
        set is_deleted_by_recipient = true
        where (r.email_id, r.recipient_username, is_deleted_by_recipient) = (email_record.id, logged_in_username, false);

        if FOUND = true then
            return 'Email successfully deleted!'::varchar;
        end if;

        --if cc recipient
        update cc_recipient ccr
        set is_deleted_by_cc_recipient = true
        where (email_id, cc_recipient_username, is_deleted_by_cc_recipient) = (email_record.id, logged_in_username, false);

        if FOUND = true then
            return 'Email successfully deleted!'::varchar;
        end if;

        --return error
        raise exception 'You do not have an email with this ID!';

    end;

$$ language plpgsql;