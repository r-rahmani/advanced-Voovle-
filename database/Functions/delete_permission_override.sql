create or replace function delete_permission_override (target_email_address varchar(50))
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
        lowered_target_username varchar(50);
        target_user "user";
    begin
         --checking for voovle.com
        if target_email_address not like '%@voovle.com' then
                raise exception 'Wrong Email address "%". An email address must end with "voovle.com"', target_email_address;
        end if;

        --lowering up the username
        lowered_target_username = lower(substring(target_email_address, 0, length(target_email_address) - 10));


        --checking if  lowered_target_username actually exists
        select *
        into target_user
        from "user" u
        where u.username =  lowered_target_username;

        if target_user.username is null then
            raise exception 'No such user found.';
        end if;

        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --deleting the permission override
        delete from permission_override po
            where (po.owner_username, po.searching_username) = (logged_in_username,  lowered_target_username);

        --checking the result
        if FOUND = true then
            return 'Permission override successfully deleted!'::varchar;
        else
            raise exception 'There is no permission override for that user!';
        end if;

    end
    $$ language plpgsql;