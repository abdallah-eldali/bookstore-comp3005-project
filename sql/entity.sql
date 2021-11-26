--TODO: Test this
create table entity(
    --since email -> name and is also a superkey
    email varchar(50) unique not null,
    name  varchar(20) not null,

    primary key (entity)
);