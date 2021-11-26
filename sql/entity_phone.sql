--TODO: test this
create table user_phone(
	email int,
	phone_number varchar(10),
	
	primary key (email, phone_number),
	foreign key (email) references entity
		on delete cascade
);