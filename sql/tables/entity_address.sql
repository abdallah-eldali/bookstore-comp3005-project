--TEST
create table entity_address(
    email        varchar(50),
    full_address varchar(50),

    primary key (email, full_address),
    foreign key (email) references entity
        on delete cascade,
    foreign key (full_address) references address
        on delete cascade
);