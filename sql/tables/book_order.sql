-- Test
create table book_order(
    isbn       int,
    order_id   int,
    quantity   int default 0,

    primary key(isbn, order_id),
    foreign key (isbn) references book
        on delete cascade,
    foreign key (order_id) references order_table
        on delete cascade
);