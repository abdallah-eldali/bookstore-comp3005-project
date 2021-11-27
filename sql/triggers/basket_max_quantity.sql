--This trigger is used to check that a book in a basket has at most the quantity of books stored

--function 
create or replace function check_basket_max_quantity()
    returns trigger
    language plpgsql
as
$$
begin
    if new.quantity > (select quantity from book where isbn=new.isbn) then
        raise exception 'new row for relation "basket" violates constraint where quantity must be lower or equal to the book quantity';
    end if;

    return new;
end;
$$;

--trigger: when a quantity of a book in a basket is higher than the book's quantity
--after updating or inserting it, then raise an exception
create trigger basket_max_quantity
before insert or update on basket
for each row 
execute procedure check_basket_max_quantity();