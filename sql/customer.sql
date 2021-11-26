--TODO: test this
create table customer(
    customer_email varchar(50),

    primary key (customer_email), 
    foreign key (customer_email) references user_account (user_email)
        on delete cascade
);