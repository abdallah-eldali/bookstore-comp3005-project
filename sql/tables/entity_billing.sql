--TEST
create table entity_billing(
    email       varchar(50),
    card_number varchar(16),

    primary key (email, card_number),
    foreign key (email) references entity,
    foreign key (card_number) references billing
);