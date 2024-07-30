create or replace function update_account_data (
    account_phone_number varchar(11),
    address varchar(512),
    first_name varchar(30),
    last_name varchar(30),
    phone_number varchar(11),
    birth_date varchar(10),
    nickname varchar(30),
    national_id varchar(10)
)
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
        logged_in_user "user";

        new_account_phone_number char(11);
        new_address varchar(512);
        new_first_name varchar(30);
        new_last_name varchar(30);
        new_phone_number char(11);
        new_birth_date date;
        new_nickname varchar(30);
        new_national_id varchar(10);

    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --get user
        select *
        into logged_in_user
        from "user" u
        where u.username = logged_in_username;

        --handling unchanged values
        if account_phone_number = 'null' then
            new_account_phone_number = logged_in_user.account_phone_number;
        else
            new_account_phone_number = account_phone_number;
        end if;

        if address = 'null' then
            new_address = logged_in_user.address;
        else
            new_address = address;
        end if;

        if first_name = 'null' then
            new_first_name = logged_in_user.first_name;
        else
            new_first_name = first_name;
        end if;

        if last_name = 'null' then
            new_last_name = logged_in_user.last_name;
        else
            new_last_name = last_name;
        end if;

        if phone_number = 'null' then
            new_phone_number = logged_in_user.phone_number;
        else
            new_phone_number = phone_number;
        end if;

        if birth_date = 'null' then
            new_birth_date = logged_in_user.birth_date;
        else
            new_birth_date = birth_date;
        end if;

        if nickname = 'null' then
            new_nickname = logged_in_user.nickname;
        else
            new_nickname = nickname;
        end if;

        if national_id = 'null' then
            new_national_id = logged_in_user.national_id;
        else
            new_national_id = national_id;
        end if;

        --updating
        update "user" u set
            account_phone_number = new_account_phone_number,
            address = new_address,
            first_name = new_first_name,
            last_name = new_last_name,
            phone_number = new_phone_number,
            birth_date = new_birth_date,
            nickname = new_nickname,
            national_id = new_national_id
        where u.username = logged_in_username;

        return 'Success!'::varchar;
    end
$$ language plpgsql;