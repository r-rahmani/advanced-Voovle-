create or replace function add_permission_override (target_email_address varchar(50), is_permitted boolean)
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
        lowered_target_username varchar(50);
        target_user "user";
    begin

        --checking for foofle.com
        if target_email_address not like '%@foofle.com' then
                raise exception 'Wrong Email address "%". An email address must end with "@foofle.com"', target_email_address;
        end if;

        --lowering up the username
        lowered_target_username = lower(substring(target_email_address, 0, length(target_email_address) - 10));

        --checking for "deleted_account"
        if lowered_target_username = 'deleted_account' then
            raise exception 'No such user found!';
        end if;

        --checking if lowered_target_username actually exists
        select *
        into target_user
        from "user" u
        where u.username = lowered_target_username;

        if target_user.username is null then
            raise exception 'No such user found.';
        end if;

        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --checking if the target_user is not the user himself/herself!
        if target_user.username = logged_in_username then
            raise exception 'You can not define a permission on yourself!';
        end if;

        --checking if a permission for the target user was not set before
        if exists(select * from permission_override po
            where (po.owner_username, po.searching_username) = (logged_in_username, lowered_target_username)) then

            raise exception 'You have already defined a permission override to that user!';
        end if;

        --adding the permission override
        insert into permission_override values (logged_in_username, lowered_target_username, add_permission_override.is_permitted);
        return 'Permission override successfully added!'::varchar;

    end
    $$ language plpgsql;