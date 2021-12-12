

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

    check (price > 0 and number_pages > 0 and quantity >= 0 and cost > 0),
    check (percent_sale < 1.00 and percent_sale >= 0.00), 
    check (price > cost), -- we need to be making a profit

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

--------------------------------------------------------------------------------------

-- VIEWS:

create view customer_book_view(isbn, title, number_pages, price, publisher, author, genre, quantity) as
	select isbn, 
		   title,
		   number_pages,
		   price,
		   name as publisher,
		   array(select name from book_author natural join author where isbn=book.isbn) as author,
		   array(select genre_type from book_genre where isbn=book.isbn) as genre,
		   quantity
	from book join publisher using(publisher_email);

--------

create or replace function sale_on_day(day date)
	returns float
	language plpgsql
as
$$
begin

	return (select sum(book_order.quantity * book.price)
		    from book_order, book
		    where book_order.isbn = book.isbn and book_order.order_id in (select order_id
																		  from order_table
																		  where order_date = day));
	
	
end;
$$;

create view sale_per_day(day, sales) as 
	select distinct order_date, sale_on_day(order_date)
	from order_table;

--------------------------------------------------------------------------------------

-- Triggers:

create or replace function check_basket_max_quantity()
    returns trigger
    language plpgsql
as
$$
begin
    if new.quantity > (select quantity from book where isbn=new.isbn) then
        raise exception 'new row for relation "basket" violates constraint where quantity must be lower or equal to the book quantity';
    end if;

    return new;
end;
$$;

create trigger basket_max_quantity
before insert or update on basket
for each row 
execute procedure check_basket_max_quantity();

--------

-- Check if the customer_email is not in owner or publisher
create or replace function check_customer_not_owner_or_publisher()
    returns trigger
    language plpgsql
as
$$
begin
    if new.customer_email in (select owner_email from owner) or new.customer_email in (select publisher_email from publisher) then
        raise exception 'customer_email already exists in owner or publisher';
    end if;
    return new;
end;
$$;

create trigger customer_not_owner_or_publisher
before insert on customer
for each row
execute procedure check_customer_not_owner_or_publisher();

--------

create or replace function check_order_new_books()
    returns trigger
    language plpgsql
as
$$
begin
    if new.quantity <= 10 then
        new.quantity := greatest(11, 
                        new.quantity + (
                            select sum(book_order.quantity) 
                            from (order_table natural join book_order)
                            where isbn = new.isbn                               AND
                                order_date >= current_date - interval '1 month' AND
                                order_date <= current_date
                        ) 
        );

    end if;
    return new;
end;
$$;

create trigger potentially_order_books
before insert or update on book
for each row 
execute procedure check_order_new_books();

--------

-- Check if owner_email is not in customer or publisher

create or replace function check_owner_not_customer_or_publisher()
    returns trigger
    language plpgsql
as
$$
begin
    if new.owner_email in (select customer_email from customer) or new.owner_email in (select publisher_email from publisher) then
        raise exception 'owner_email already exists in customer or publisher';
    end if;
    return new;
end;
$$;

create trigger owner_not_customer_or_publisher
before insert on owner
for each row
execute procedure check_owner_not_customer_or_publisher();

--------

--This is a trigger used to check if a publisher email is not in a customer table
--and vice versa

--Check if a publisher is not a customer 

create or replace function check_publisher_not_customer_or_owner()
    returns trigger
    language plpgsql
as
$$
begin
    if new.publisher_email in (select customer_email from customer) or new.publisher_email in (select owner_email from owner) then
        raise exception 'publisher_email already exists in customer or owner';
    end if;
    return new;
end
$$;

create trigger publisher_not_customer_or_owner
before insert on publisher
for each row
execute procedure check_publisher_not_customer_or_owner();

--------------------------------------------------------------------------------------

-- FUNCTIONS:

create or replace function check_customer(email varchar(50), pass varchar(50))
	returns boolean
	language plpgsql
as
$$
begin
	return ((select count(*) from customer where customer_email=email and password=pass) = 1);
end;
$$;

create or replace function check_owner(email varchar(50), pass varchar(50))
	returns boolean
	language plpgsql
as
$$
begin
	return ((select count(*) from owner where owner_email=email and password=pass) = 1);
end;
$$;

--------

create or replace function sales_between_day(day1 date, day2 date)
	returns float
	language plpgsql
as
$$
begin

	return(select sum(sales) as total_sales
	from sale_per_day
	where day1 <= day and day <= day2);
	
end;
$$;

--------------------------------------------------------------------------------------
