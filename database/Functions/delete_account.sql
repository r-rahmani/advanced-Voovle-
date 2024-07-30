create or replace function delete_account ()
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
        email_row email;
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --deleting login logs
        delete from login_log ll
        where ll.username = logged_in_username;

        --deleting permission overrides related to this user
        delete from permission_override po
        where po.searching_username = logged_in_username
            or po.owner_username = logged_in_username;

        --deleting notifications
        delete from notification n
        where n.username = logged_in_username;

        --deleting user from recipient
        delete from recipient r
        where r.recipient_username = logged_in_username;

        --deleting user from cc_recipient
        delete from cc_recipient cr
        where cr.cc_recipient_username = logged_in_username;

        --now we change the emails sent by the user, to be sent by "deleted_account"
        update email e
        set sender_username = 'deleted_account'
        where e.sender_username = logged_in_username;

        --and finally, deleting the user
        delete from "user" u
        where u.username = logged_in_username;

        return 'Account successfully deleted!'::varchar;

    end;
$$ language plpgsql;