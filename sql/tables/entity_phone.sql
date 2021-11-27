create table entity_phone(
	email 		 varchar(50),
	phone_number varchar(10),
	
	--phone_number should always be 10 characters long 
	--(assuming only Canada phone numbers allowed)
	check (length(phone_number) = 10),

	primary key (email, phone_number),
	foreign key (email) references entity
		on delete cascade
);