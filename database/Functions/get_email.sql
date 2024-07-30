create or replace function get_email (requested_email_id integer)
returns table (
    id integer,
    sender_email varchar(50),
    recipients_username text,
    cc_recipients_username text,
    subject varchar(50),
    content varchar(512),
    time_sent timestamp
)
as $$
    declare
        logged_in_username varchar(50);
        email_record email;
        recipient_text text;
        cc_recipient_text text;
        actually_found boolean;
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
            raise exception 'You do not have an email with this ID!';
        end if;


        --producing recipients
        recipient_text = get_recipients_text(requested_email_id);

        --producing cc_recipients
        cc_recipient_text = get_cc_recipients_text(requested_email_id);

        actually_found = false;

        --if sender
        if email_record.sender_username = logged_in_username and
            email_record.is_deleted_by_sender = false then

            actually_found = true;
            return query select email_record.id, (email_record.sender_username || '@voovle.com')::varchar, recipient_text, cc_recipient_text,
                                    email_record.subject, email_record.content, email_record.time_sent;
        end if;

        --if recipient
        update recipient r
        set is_read_by_recipient = true
        where (r.email_id, r.recipient_username, r.is_deleted_by_recipient) = (email_record.id, logged_in_username, false);

        if FOUND = true then
            actually_found = true;
            return query select email_record.id, (email_record.sender_username || '@voovle.com')::varchar, recipient_text, cc_recipient_text,
                                email_record.subject, email_record.content, email_record.time_sent;

        end if;

        --if cc recipient
        update cc_recipient ccr
        set is_read_by_cc_recipient = true
        where (email_id, cc_recipient_username, is_deleted_by_cc_recipient) = (email_record.id, logged_in_username, false);

        if FOUND = true then
            actually_found = true;
            return query select email_record.id, (email_record.sender_username || '@voovle.com')::varchar, recipient_text, cc_recipient_text,
                                email_record.subject, email_record.content, email_record.time_sent;

        end if;

        --return error
        if actually_found = false then
            raise exception 'You do not have an email with this ID!';
        end if;

    end

$$ language plpgsql;