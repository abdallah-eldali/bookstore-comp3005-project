--TODO: test this
create table owner(
    owner_email varchar(50),

    primary key (owner_email),
    foreign key (owner_email) references user_account (user_email)
        on delete cascade
);