-- TEST
create table order(
    order_id       serial,
    customer_email varchar(50),
    full_address   varchar(50),
    card_number    varchar(16),
    order_date     date not null default current_date, -- we can extract day month year info from date type

    primary key (order_id),
    foreign key (customer_email) references customer
        on delete set null,
    foreign key (card_number) references billing
        on delete set null,
    foreign key (full_address) references address
        on delete set null
);