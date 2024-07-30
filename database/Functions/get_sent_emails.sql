create or replace function get_sent_emails (page_number integer, page_size integer)
returns table (
    id integer,
    sender_username varchar(50),
    recipients_username text,
    cc_recipients_username text,
    subject varchar(50),
    content varchar(512),
    time_sent timestamp
)
as $$
    declare
        logged_in_username varchar(50);
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --getting emails
        return query select e.id, e.sender_username, get_recipients_text(e.id),
                            get_cc_recipients_text(e.id), e.subject, (substring(e.content, 0, 20) || '...')::varchar, e.time_sent
        from email e
        where e.sender_username = logged_in_username and e.is_deleted_by_sender = false
        order by time_sent desc
        offset page_size * (page_number - 1)
        limit page_size;

    end;
$$ language plpgsql;