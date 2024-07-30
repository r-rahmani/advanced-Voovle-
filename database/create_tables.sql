create table "user" (
   username varchar(50),
   password text,
   sign_up_date date,
   account_phone_number char(11),
   address varchar(512),
   first_name varchar(30),
   last_name varchar(30),
   phone_number char(11),
   birth_date date,
   nickname varchar(30),
   national_id varchar(10),
   accessed_by_default boolean,
   primary key (username)
);

insert into "user" values (
            'deleted_account', 'A~Zo6gQ~]h40.E;fgQ~Zo..s41F\LG/',
            null::date, null::char, null::varchar, null::varchar, null::varchar,
            null::char, null::date, null::varchar, null::varchar, null::boolean
);

create table email (
    id serial,
    sender_username varchar(50),
    subject varchar(50),
    content varchar(512),
    time_sent timestamp,
    is_deleted_by_sender boolean,
    is_read_by_sender boolean,
    primary key (id),
    foreign key (sender_username) references "user" (username)
);

create table cc_recipient (
    email_id integer,
    cc_recipient_username varchar(50),
    is_deleted_by_cc_recipient boolean,
    is_read_by_cc_recipient boolean,
    primary key (email_id, cc_recipient_username),
    foreign key (email_id) references email (id),
    foreign key (cc_recipient_username) references "user" (username)
);

create table recipient (
    email_id integer,
    recipient_username varchar(50),
    is_deleted_by_recipient boolean,
    is_read_by_recipient boolean,
    primary key (email_id, recipient_username),
    foreign key (email_id) references email (id),
    foreign key (recipient_username) references "user" (username)
);

create table notification (
    id serial,
    time_created timestamp,
    username varchar(50),
    content varchar(512),
    primary key (id),
    foreign key (username) references "user" (username)
);

create table permission_override (
    owner_username varchar(50),
    searching_username varchar(50),
    is_permitted boolean,
    primary key (owner_username, searching_username),
    foreign key (owner_username) references "user" (username),
    foreign key (searching_username) references "user" (username)
);

create table login_log (
    time timestamp,
    username varchar(50),
    primary key (time, username),
    foreign key (username) references "user" (username)
);