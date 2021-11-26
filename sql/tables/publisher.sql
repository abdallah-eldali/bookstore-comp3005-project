--TODO: test this
create table publisher(
    publisher_email varchar(50),

    primary key (publisher_email),
    foreign key (publisher_email) references entity (email)
        on delete cascade
);