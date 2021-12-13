
--returns the sum of all sales between day1 and day2 (inclusive)
--this is used for the owner to know the sum of all the sales between two dates
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