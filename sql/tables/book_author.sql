create table book_author(
    author_id int,
    isbn      int,

    primary key (author_id, isbn),
    foreign key (author_id) references author
        on delete cascade,
    foreign key (isbn) references book
        on delete cascade
);