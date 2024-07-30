create or replace function login (
    email_address varchar(50),
    password varchar(50)
)
returns varchar(50)
as $$
    declare
        lowered_username varchar(50);
        existing_user "user";
        hashed_password varchar(50);
    begin

        --checking for voovle.com
        if email_address not like '%@voovle.com' then
                raise exception 'Wrong Email address "%". An email address must end with "@voovle.com"', email_address;
        end if;

        --lowering up the username
        lowered_username = lower(substring(email_address, 0, length(email_address) - 10));

        --checking for "deleted_account"
        if lowered_username = 'deleted_account' then
            raise exception 'No such user exists!';
        end if;

        select *
        into existing_user
        from "user" as u
        where u.username = lowered_username;

        if existing_user.username is not null then
            --checking the password
            hashed_password = md5(password);
            if hashed_password = existing_user.password then
                --adding a record into login_log
                insert into login_log values (now(), existing_user.username);
                return format('Successfully logged in as "%s"!', email_address)::varchar;
            else
                --return error
                raise exception 'Wrong password!';
            end if;
        else
            --return error
            raise exception 'Username not found!';
        end if;
    end
$$ language plpgsql;