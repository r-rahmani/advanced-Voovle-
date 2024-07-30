create or replace function sign_up (
    requesting_username varchar(50),
    password varchar(50),
    --sign_up_date date, generated automatically
    account_phone_number char(11),
    address varchar(512),
    first_name varchar(30),
    last_name varchar(30),
    --phone_number char(11), same as account_phone_number
    birth_date date,
    nickname varchar(30),
    national_id varchar(10),
    accessed_by_default boolean
)
returns varchar(50)
as $$
    declare
        lowered_username varchar(50);
        existing_user "user";
        hashed_password text;
    begin

        --checking validation of inputs
        if requesting_username not like('______%') then
            raise exception 'Username must be at least 6 characters.';
        end if;

        if password not like('______%') then
            raise exception 'Password must be at least 6 characters.';
        end if;

        lowered_username = lower(requesting_username);

        --checking for voovle.com
        if requesting_username like '%@voovle.com' then
            raise exception 'Do not write @voovle.com at the end of username.';
        end if;

        --checking for "deleted_account"
        if lowered_username = 'deleted_account' then
            raise exception 'Username is invalid!';
        end if;

        --checking if the username already exists
        select *
        into existing_user
        from "user" as u
        where u.username = lowered_username;

        if existing_user.username is null then
            --create user
            hashed_password = md5(password);
            insert into "user" values (
                   lowered_username,
                   hashed_password,
                   now(),
                   sign_up.account_phone_number,
                   sign_up.address,
                   sign_up.first_name,
                   sign_up.last_name,
                   sign_up.account_phone_number,
                   sign_up.birth_date,
                   sign_up.nickname,
                   sign_up.national_id,
                   sign_up.accessed_by_default
            );
            return 'Success!'::varchar;
        else
            --return error
            raise exception 'Username already exists!';
        end if;
    end
$$ language plpgsql;