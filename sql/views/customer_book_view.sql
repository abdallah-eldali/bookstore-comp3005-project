-- Test

--Maybe it needs to be a view because it doesn't update as often...
create materialized view customer_book_view(isbn, title, number_pages, price, publisher, author, genre, quantity) as
	select isbn, 
		   title,
		   number_pages,
		   price,
		   name as publisher,
		   array(select name from book_author natural join author where isbn=book.isbn) as author,
		   array(select genre_type from book_genre where isbn=book.isbn) as genre,
		   quantity
	from book join publisher using(publisher_email);