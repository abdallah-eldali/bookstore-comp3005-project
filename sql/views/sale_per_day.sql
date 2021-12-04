create or replace function sale_on_day(day date)
	returns decimal(10,2)
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

--Maybe we need to change this to a view as materialized doesn't update as often...
create view sale_per_day(day, sales) as 
	select distinct order_date, sale_on_day(order_date)
	from order_table;
