--returns true if the user_account exists, false otherwise
create or replace function check_user(email varchar(50), pass varchar(50))
	returns boolean
	language plpgsql
as
$$
begin
	return ((select count(*) from user_account where user_account.user_email=email and user_account.password=pass) = 1);
end;
$$;