--returns true if the customer exists, false otherwise
create or replace function check_customer(email varchar(50), pass varchar(50))
	returns boolean
	language plpgsql
as
$$
begin
	return ((select count(*) from customer where customer_email=email and password=pass) = 1);
end;
$$;