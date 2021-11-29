create table book_genre(
    isbn       int,
    genre_type varchar(20),

    primary key(isbn, genre_type),
    foreign key (isbn) references book
        on delete cascade
);