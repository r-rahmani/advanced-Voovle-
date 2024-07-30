create or replace function get_own_account_data ()
returns table(
    username varchar(50),
    sign_up_date date,
    account_phone_number char(11),
    address varchar(512),
    first_name varchar(30),
    last_name varchar(30),
    phone_number char(11),
    birth_date date,
    nickname varchar(30),
    national_id varchar(10)
)
as $$
    declare
        logged_in_username varchar(50);
    begin
        --getting the current username from login_log
        logged_in_username = get_logged_in_username();

        --getting user data from "user" table
        return query select u.username, u.sign_up_date, u.account_phone_number, u.address,
               u.first_name, u.last_name, u.phone_number, u.birth_date,
               u.nickname, u.national_id
        from "user" u
        where u.username = logged_in_username;

    end
    $$ language plpgsql;