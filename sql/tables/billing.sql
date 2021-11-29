create table billing(
    card_number varchar(16),

    -- first check length (supposedly can be 8 digits long), second check
    -- is to make sure the card_number only contains digits no letters
    check(length(card_number) >= 8 and card_number ~ '^\d*$'),
    primary key (card_number)
);