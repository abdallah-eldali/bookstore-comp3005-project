--TEST
create table basket(
    customer_email varchar(50),
    isbn           int,
    quantity       int,

    primary key (customer_email, isbn),
    foreign key (customer_email) references customer
        on delete cascade,
    foreign key (isbn) references book
        on delete cascade
);