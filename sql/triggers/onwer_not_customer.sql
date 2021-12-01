-- This is a trigger used to make sure that the tuple inserted in owner
-- is not already in the customer table due to the disjoint between the
-- two, i.e.: an owner and a customer is an entity, but they're not
-- each other (owner can't be a customer and vice versa)

--NOTE: This has to be run AFTER we create all the schema

--we need this trigger function so the trigger can work
create or replace function check_owner_not_customer() 
	returns trigger
	language plpgsql
as
$$
begin
	if new.owner_email in (select customer_email from customer) then 
		raise exception 'owner_email already exists in customer';
		
	end if;
	return new;
end
$$;

--trigger: before inserting a tuple to publisher, check if it's not a user already
create trigger owner_not_customer
before insert on owner
for each row
execute procedure check_owner_not_customer();