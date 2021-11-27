create table entity(
    --since email -> name and is also a superkey
    email varchar(50),
    name  varchar(20) not null,

    primary key (email)
);