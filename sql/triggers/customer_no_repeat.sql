-- Check if the customer_email is not in owner or publisher
create or replace function check_customer_not_owner_or_publisher()
    returns trigger
    language plpgsql
as
$$
begin
    if new.customer_email in (select owner_email from owner) or new.customer_email in (select publisher_email from publisher) then
        raise exception 'customer_email already exists in owner or publisher';
    end if;
    return new;
end;
$$;

create trigger customer_not_owner_or_publisher
before insert on customer
for each row
execute procedure check_customer_not_owner_or_publisher();