--These are the queries being used within the application (i.e.: all the queries used in database.ts)
--NOTE: the $# are just parameters that passed to the queries in database.ts functions

--This is used to check if a customer exists in the customer table
--returns true if so, false otherwise
select check_customer(customer_email, password);

--This is used to check if an owner exists in the owner table
--returns true if so, false otherwise
select check_owner(owner_email, password);

--These two queries are used to register (insert) customer and owner into their
--respective tables
insert into owner(owner_email, name, password, card_number, full_address, phone_number)
values (owner_email, name, password, card_number, full_address, phone_number);

insert into customer(customer_email, name, password, card_number, full_address, phone_number)
values (customer_email, name, password, card_number, full_address, phone_number);

--Gets the table of all the books in the book table with their genres and authors as arrays
--this is used to show the customer the relevant information of books
select *
from customer_book_view;

--Here, we build-up the 'where' clause depending on what the user is searching on
select *
from customer_book_view
${whereQuery};

--This is used to check a book is already in a customer's basket
select count(*)
from basket
where isbn=isbn and customer_email=email;

--If there is a book already in the basket (checked from above) then we just update 
--the quantity of it to a new quantity
update basket set quantity = newQuantity
where isbn=isbn and customer_email=customer_email;

--If the book isn't in the customer's basket, then insert it
insert into basket(isbn, customer_email, quantity)
values(isbn, customer_email, quantity);

--This gets the basket of a customer to display in the application
select *
from basket
where customer_email=email;

--This is used to delete a customer's basket after they make an order
delete from basket
where customer_email=email;

--This is used to create an order when a customer checkout their basket
insert into order_table(order_id, customer_email, full_address, card_number, order_date)
values(default, customer_email, full_address, card_number, default)
returning order_id;

--This is to get the list of books and their quantities of a specific user to create the order
select isbn, quantity
from basket
where customer_email=email;

--This query is used multiple times for every book and its quantity queried from the above query
insert into book_order(order_id, isbn, quantity)
values(order_id, isbn, quantity);

--This is used to update the quantity of the book that has been ordered
update book
set quantity=quantity-ordered_quantity
where isbn=isbn;

--This is used to check if a customer's basket is empty
select count(*)
from basket
where customer_email=email;

--This query retrieves the customer's address 
--(used if they don't specify a different address in the checkout)
select full_address
from customer
where customer_email=email;

--This query retrieves the customer's billing 
--(used if they don't specify a different billing in the checkout)
select card_number
from customer
where customer_email=email;

--Gets the order of a specific customer to be displayed in the application
select order_id, full_address, card_number, order_date, isbn, quantity
from order_table natural join book_order
where customer_email=email;

--This is used to get all the sales per day to be displayed to the owner
select *
from sale_per_day;

--Used to delete a specific book
delete from book
where isbn=book_isbn;

--Gets all the emails of publishers in the table
select publisher_email
from publisher;

--Create a new publisher
insert into publisher(publisher_email, name, card_number, full_address, phone_number)
values($1, $2, $3, $4, $5);

--Create a new author and return the ID of the newly created author
insert into author(name)
values($1)
returning author_id;

--Create a new genre and link it to a book (this is used to add genres to books)
insert into book_genre(isbn, genre_type)
values($1, $2);

--Adds and author to a book
insert into book_author(author_id, isbn)
values($1, $2);

--Create a new book and return the ISBN of the newly created book
insert into book(title, number_pages, quantity, price, cost, percent_sale, publisher_email)
values($1, $2, $3, $4, $5, $6, $7)
returning isbn;

--Return a number which is all the sales between two dates (inclusive)
--NOTE: sales_between_day is a function declared in the DDL
select sales_between_day($1, $2);