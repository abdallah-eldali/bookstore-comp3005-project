create table author(
    author_id serial,
    name      varchar(20) not null,

    primary key (author_id)
);

create table publisher(
    publisher_email varchar(50),
    name            varchar(50) not null,
    card_number     varchar(50) not null,
    full_address    varchar(50) not null,
    phone_number    varchar(50) not null,

    --phone_number should always be 10 characters long 
	--(assuming only Canadian phone numbers allowed)
	check (length(phone_number) = 10 and phone_number ~ '^\d*$'),
    -- first check length (supposedly can be 8 digits long), second check
    -- is to make sure the card_number only contains digits no letters
    check(length(card_number) = 8 and card_number ~ '^\d*$'),

    primary key (publisher_email)
);


create table customer(
    customer_email  varchar(50),
    name         varchar(50) not null,
    password     varchar(50) not null,
    card_number  varchar(50) not null,
    full_address varchar(50) not null,
    phone_number varchar(50) not null,

    --phone_number should always be 10 characters long 
	--(assuming only Canadian phone numbers allowed)
	check (length(phone_number) = 10 and phone_number ~ '^\d*$'),
    -- first check length (supposedly can be 8 digits long), second check
    -- is to make sure the card_number only contains digits no letters
    check(length(card_number) = 8 and card_number ~ '^\d*$'),

    primary key (customer_email)
);

create table owner(
    owner_email  varchar(50),
    name         varchar(50) not null,
    password     varchar(50) not null,
    card_number  varchar(50) not null,
    full_address varchar(50) not null,
    phone_number varchar(50) not null,

    --phone_number should always be 10 characters long 
	--(assuming only Canadian phone numbers allowed)
	check (length(phone_number) = 10 and phone_number ~ '^\d*$'),
    -- first check length (supposedly can be 8 digits long), second check
    -- is to make sure the card_number only contains digits no letters
    check(length(card_number) = 8 and card_number ~ '^\d*$'),
    
    primary key (owner_email)
);

create table order_table(
    order_id       serial,
    customer_email varchar(50) not null,
    full_address   varchar(50) not null,
    card_number    varchar(16) not null,
    order_date     date not null default current_date, -- we can extract day month year info from date type

    primary key (order_id),
    foreign key (customer_email) references customer
        on delete set null
);

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

create table book_author(
    author_id int,
    isbn      int,

    primary key (author_id, isbn),
    foreign key (author_id) references author
        on delete cascade,
    foreign key (isbn) references book
        on delete cascade
);

create table book_genre(
    isbn       int,
    genre_type varchar(20),

    primary key(isbn, genre_type),
    foreign key (isbn) references book
        on delete cascade
);


create table basket(
    customer_email varchar(50),
    isbn           int,
    quantity       int not null,

    check (quantity > 0),

    primary key (customer_email, isbn),
    foreign key (customer_email) references customer
        on delete cascade,
    foreign key (isbn) references book
        on delete cascade
);

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
