
--This view is used to show the customer the important information about a book, like the publishers name, genres, authors, etc.
--i.e.: hide unecessary info like percent sale and cost of the book since the customer doesn't need to know those...
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