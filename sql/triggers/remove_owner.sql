--Since the generalization is total, the that means that when
--a customer is deleted, then the same tuple should be deleted
--in the parent user_account since an user can only either be a
--owner or a customer

--function that removes owner from user_account when a tuple is removed in the owner table
create or replace function remove_owner_in_user()
    returns trigger
    language plpgsql
as
$$
begin
    --delete the owner from the user table
    delete from user_account
    where user_email=old.owner_email;

    return new;
end;
$$;

--trigger: when an owner is removed, then remove it from user_account as well
create trigger remove_owner
after delete on owner
for each row 
execute procedure remove_owner_in_user();