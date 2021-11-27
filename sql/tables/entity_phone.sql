--TODO: test this
create table entity_phone(
	email 		 varchar(50),
	phone_number varchar(10),
	
	primary key (email, phone_number),
	foreign key (email) references entity
		on delete cascade
);