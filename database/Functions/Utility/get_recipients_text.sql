create or replace function get_recipients_text (email_id integer)
returns text
as $$
    declare
        recipient_record recipient;
        recipient_text text;
    begin
        --producing recipients
        for recipient_record in
            select * from
            recipient r
            where r.email_id = get_recipients_text.email_id
        loop
            recipient_text = format('%s, %s@voovle.com', recipient_text, recipient_record.recipient_username);
        end loop;

        recipient_text = substring(recipient_text, 3);
        return recipient_text;
    end;
$$ language plpgsql;