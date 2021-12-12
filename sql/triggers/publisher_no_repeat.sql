--This is a trigger used to check if a publisher email is not in a customer table
--and vice versa

--Check if a publisher is not a customer 

create or replace function check_publisher_not_customer_or_owner()
    returns trigger
    language plpgsql
as
$$
begin
    if new.publisher_email in (select customer_email from customer) or new.publisher_email in (select owner_email from owner) then
        raise exception 'publisher_email already exists in customer or owner';
    end if;
    return new;
end
$$;

create trigger publisher_not_customer_or_owner
before insert on publisher
for each row
execute procedure check_publisher_not_customer_or_owner();

