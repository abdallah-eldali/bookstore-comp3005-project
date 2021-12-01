-- Test...when you update I will test

-- create materialized view customer_book_view(isbn, title, number_pages, author_name, price, publisher_name, quantity) as (
--     select isbn, title, number_pages, author.name, price, publisher.name, quantity
--     from ((book_author natural join author) natural join book) natural join publisher
-- ); 