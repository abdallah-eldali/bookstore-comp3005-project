-- This is a trigger used to make sure that the tuple inserted in user_account
-- is not already in the publisher table due to the disjoint between the
-- two, i.e.: a publisher and a user_account is an entity, but they're not
-- each other (publisher can't be a user and vice versa)

--NOTE: This has to be run AFTER we create all the schema

--TODO: We need to test this

--we need this trigger function so the trigger can work
create or replace function check_user_not_publisher() 
	returns trigger
	language plpgsql
as
$$
begin
	if new.user_email in (select publisher_email from publisher) then 
		raise exception 'user_email already exists in publisher';
		
	end if;
	return new;
end
$$;

--trigger: before inserting a tuple to user_account, 
--         check if it's not a publisher already
create trigger user_not_publisher
before insert on user_account
for each row
execute procedure check_user_not_publisher();