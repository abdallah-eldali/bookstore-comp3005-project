create table user_account(
    user_email varchar(50),
    password   varchar(50) not null,

    primary key (user_email),
    foreign key (user_email) references entity (email)
        on delete cascade
);