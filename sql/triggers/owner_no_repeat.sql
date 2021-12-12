-- Check if owner_email is not in customer or publisher

create or replace function check_owner_not_customer_or_publisher()
    returns trigger
    language plpgsql
as
$$
begin
    if new.owner_email in (select customer_email from customer) or new.owner_email in (select publisher_email from publisher) then
        raise exception 'owner_email already exists in customer or publisher';
    end if;
    return new;
end;
$$;

create trigger owner_not_customer_or_publisher
before insert on owner
for each row
execute procedure check_owner_not_customer_or_publisher();