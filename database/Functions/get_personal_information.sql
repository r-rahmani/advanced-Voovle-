create or replace function get_personal_data (target_email_address varchar(50))
returns table (
    username varchar(50),
    address varchar(512),
    first_name varchar(30),
    last_name varchar(30),
    phone_number char(11),
    birth_date date,
    nickname varchar(30),
    national_id varchar(10))
as $$
    declare
        logged_in_username varchar(50);
        lowered_target_username varchar(50);
        permission_override_record permission_override;
        is_permitted boolean;
        target_user "user";
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

          --checking for voovle.com
        if target_email_address not like '%@voovle.com' then
                raise exception 'Wrong Email address "%". An email address must end with "voovle.com"', target_email_address;
        end if;

        --lowering up the username
        lowered_target_username = lower(substring(target_email_address, 0, length(target_email_address) - 10));


        --checking if the user is not searching himself/herself!
        if lowered_target_username = logged_in_username then
            raise exception 'You are searching yourself! Please use the function "get_own_account_data" instead.';
        end if;

        --checking for "deleted_account"
        if lowered_target_username = 'deleted_account' then
            raise exception 'No such user exists!';
        end if;

        --getting target_user
        select *
        into target_user
        from "user" u
        where u.username = lowered_target_username;

        --if target_user doesn't exist
        if target_user.username is null then
            raise exception 'No such user exists.';
        end if;

        --searching in "permission override" table
        select *
        into permission_override_record
        from permission_override po
        where (lowered_target_username, logged_in_username) = (po.owner_username, po.searching_username);

        if permission_override_record.owner_username is not null then
            is_permitted = permission_override_record.is_permitted;
        else --checking the default permission
            is_permitted = target_user.accessed_by_default;
        end if;

        if is_permitted is true then
            --notifying the target user
            insert into notification (time_created, username, content)
            values (now(), lowered_target_username, format(
                'User "%s" asked your personal information and access was granted!', logged_in_username));

            --returning the result
            return query select target_user.username,
                                target_user.address,
                                target_user.first_name,
                                target_user.last_name,
                                target_user.phone_number,
                                target_user.birth_date,
                                target_user.nickname,
                                target_user.national_id;

        else
            --notifying the target user
            insert into notification (time_created, username, content)
            values (now(), lowered_target_username, format(
                'User "%s" asked your personal information and access was denied!', logged_in_username));

            raise exception 'Permission denied!';
        end if;

    end
    $$ language plpgsql;