create or replace function get_inbox (page_number integer, page_size integer)
returns table (
    is_read boolean,
    id integer,
    sender_username varchar(50),
    subject varchar(50),
    content varchar(512),
    time_sent timestamp
)
as $$
    declare
        logged_in_username varchar(50);
    begin
        --getting the current username from login-log
        logged_in_username  = get_logged_in_username();

        --getting emails
        return query select *
        from
        (
            --received emails
            select r.is_read_by_recipient, e.id, e.sender_username, e.subject, (substring(e.content, 0, 20) || '...')::varchar, e.time_sent
            from email e
            inner join recipient r
                on e.id = r.email_id
            where r.recipient_username = logged_in_username and r.is_deleted_by_recipient = false

            union

            --cc emails
            select  cr.is_read_by_cc_recipient, e.id, e.sender_username, e.subject, (substring(e.content, 0, 20) || '...')::varchar, e.time_sent
            from email e
            inner join cc_recipient cr
                on e.id = cr.email_id
            where cr.cc_recipient_username = logged_in_username and cr.is_deleted_by_cc_recipient = false

            ) as all_emails
        order by time_sent desc
        offset page_size * (page_number - 1)
        limit page_size;

    end;
$$ language plpgsql;