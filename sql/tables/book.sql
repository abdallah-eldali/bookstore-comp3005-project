create table book(
    isbn            serial,
    title           varchar(75) not null,
    number_pages    int not null,
    quantity        int not null,          -- how many copies of book we have remaining
    price           decimal(6,2) not null, -- price for customer to buy book from store.  max price: 9999.99
    cost            decimal(6,2) not null, -- price for owner to buy book from publisher. max cost: 9999.99 
    percent_sale    decimal(3,2) not null, -- percentage of sale profit given to publisher [0.00, 1.00)
    publisher_email varchar(50),
    cover_image     bytea default null,

    -- checks on the table
    check (price > 0 and number_pages > 0 and quantity > 0 and cost > 0),
    check (percent_sale < 1.00 and percent_sale >= 0.00), 
    check (price > cost), -- we need to be making a profit

    -- setting up keys
    primary key (isbn),
    foreign key (publisher_email) references publisher (publisher_email)
        on delete cascade
);