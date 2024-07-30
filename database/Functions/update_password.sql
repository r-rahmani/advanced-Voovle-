create or replace function update_password (
    old_password varchar(50),
    new_password varchar(50)
)
returns varchar(50)
as $$
    declare
        logged_in_username varchar(50);
        actual_hashed_old_password text;
        hashed_new_password text;
    begin
        --getting the current username from login-log
        logged_in_username = get_logged_in_username();

        --getting actual old password
        select u.password
        into actual_hashed_old_password
        from "user" u
        where u.username = logged_in_username;

        --checking if old password is correct
        if actual_hashed_old_password != md5(old_password) then
            raise exception 'Old password is not correct!';
        end if;

        --validating new_password
        if new_password not like('______%') then
            raise exception 'Password must be at least 6 characters.';
        end if;

        hashed_new_password = md5(new_password);

        --checking if the old and new password are the same
        if hashed_new_password = actual_hashed_old_password then
            raise exception 'New password can not be the same as the old one!';
        end if;

        --updating the password
        update "user" u
        set password = hashed_new_password
        where u.username = logged_in_username;

        return 'Password successfully changed!'::varchar;

    end
$$ language plpgsql;