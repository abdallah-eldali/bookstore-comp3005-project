--Since the generalization is total, the that means that when
--a customer is deleted, then the same tuple should be deleted
--in the parent user_account since an user can only either be a
--owner or a customer

--function that removes customer from user_account when a tuple is removed in the customer table
create or replace function remove_customer_in_user()
    returns trigger
    language plpgsql
as
$$
begin
    --delete the customer from the user table
    delete from user_account
    where user_email=old.customer_email;

    return new;
end;
$$;

--trigger: when a customer is removed, then remove it from user_account as well
create trigger remove_customer
after delete on customer
for each row 
execute procedure remove_customer_in_user();