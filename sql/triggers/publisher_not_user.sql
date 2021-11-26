-- This is a trigger used to make sure that the tuple inserted in publisher
-- is not already in the user_account table due to the disjoint between the
-- two, i.e.: a publisher and a user_account is an entity, but they're not
-- each other (publisher can't be a user and vice versa)

--NOTE: This has to be run AFTER we create all the schema

--TODO: We need to test this

--we need this trigger function so the trigger can work
create or replace function check_publisher_not_user() 
	returns trigger
	language plpgsql
as
$$
begin
	if new.publisher_email in (select user_email from user_account) then 
		raise exception 'publisher_email already exists in user_account';
		
	end if;
	return new;
end
$$;

--trigger: before inserting a tuple to publisher, check if it's not a user already
create trigger publisher_not_user
before insert on publisher
for each row
execute procedure check_publisher_not_user();