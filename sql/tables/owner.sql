create table owner(
    owner_email  varchar(50),
    name         varchar(50) not null,
    password     varchar(50) not null,
    card_number  varchar(50) not null,
    full_address varchar(50) not null,
    phone_number varchar(50) not null,

    --phone_number should always be 10 characters long 
	--(assuming only Canadian phone numbers allowed)
	check (length(phone_number) = 10 and phone_number ~ '^\d*$'),
    -- first check length (supposedly can be 8 digits long), second check
    -- is to make sure the card_number only contains digits no letters
    check(length(card_number) = 8 and card_number ~ '^\d*$'),
    
    primary key (owner_email)
);