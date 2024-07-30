create or replace function get_cc_recipients_text (email_id integer)
returns text
as $$
    declare
        cc_recipient_record recipient;
        cc_recipient_text text;
    begin
        --producing recipients
        for cc_recipient_record in
            select * from
            cc_recipient cr
            where cr.email_id = get_cc_recipients_text.email_id
        loop
            cc_recipient_text = format('%s, %s@voovle.com', cc_recipient_text, cc_recipient_record.recipient_username);
        end loop;

        cc_recipient_text = substring(cc_recipient_text, 3);
        return cc_recipient_text;
    end;
$$ language plpgsql;