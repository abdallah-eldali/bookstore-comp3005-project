--Since the generalization is total, the that means that when
--a publisher is deleted, then the same tuple should be deleted
--in the parent entity since an entity can only either be a
--publisher or a user_account

--function that removes publisher from entity when a tuple is removed in the publisher table
create or replace function remove_publisher_in_entity()
    returns trigger
    language plpgsql
as
$$
begin
    --delete the publisher from the entity table
    delete from entity
    where email=old.publisher_email;

    return new;
end;
$$;

--trigger: when a publisher is removed, then remove it from entity as well
create trigger remove_publisher
after delete on publisher
for each row 
execute procedure remove_publisher_in_entity();