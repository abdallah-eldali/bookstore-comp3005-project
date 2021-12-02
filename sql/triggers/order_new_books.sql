--This trigger is used to order new books when the amount of books left is equal to 10

--function 
create or replace function check_order_new_books()
    returns trigger
    language plpgsql
as
$$
begin
    if new.quantity <= 10 then
        -- the new quantity is at minimum 11, hence we use the greatest function in the
        -- case where our book sales from previous month + quantity of book currently in stock
        -- is still less than 11
        new.quantity := greatest(11, 
        new.quantity + (
            select sum(book_order.quantity) 
            from (order_table natural join book_order)
            where isbn = new.isbn                                   AND
                    order_date >= current_date - interval '1 month' AND
                    order_date <= current_date
            ) 
        );

    end if;
    return new;
end;
$$;

-- trigger: In the case when a order on a book drops our book
-- quantity to the minimal 10 book threshold 
create trigger potentially_order_books
before insert or update on book
for each row 
execute procedure check_order_new_books();