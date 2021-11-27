-- This is a trigger used to make sure that the tuple inserted in customer
-- is not already in the owner table due to the disjoint between the
-- two, i.e.: an owner and a customer is an entity, but they're not
-- each other (owner can't be a customer and vice versa)

--NOTE: This has to be run AFTER we create all the schema

--we need this trigger function so the trigger can work
create or replace function check_customer_not_owner() 
	returns trigger
	language plpgsql
as
$$
begin
	if new.customer_email in (select owner_email from owner) then 
		raise exception 'customer_email already exists in owner';
		
	end if;
	return new;
end
$$;

--trigger: before inserting a tuple to publisher, check if it's not a user already
create trigger customer_not_owner
before insert on customer
for each row
execute procedure check_customer_not_owner();