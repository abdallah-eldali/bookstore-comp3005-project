
--This function is to get all the sales made in a specific date
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

--This view is used to show the report of sales per day. For all the dates in the order_table
--we calculate the sales it produce on those specified dates using the function above
create view sale_per_day(day, sales) as 
	select distinct order_date, sale_on_day(order_date)
	from order_table;
