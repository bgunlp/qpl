BEGIN TRANSACTION;
GO
USE spider;
GO
create table [college_2].classroom
	(building		varchar(15),
	 room_number		varchar(7),
	 capacity		numeric(4,0),
	 primary key (building, room_number)
	);
GO
create table [college_2].department
	(dept_name		varchar(20),
	 building		varchar(15),
	 budget		        numeric(12,2) check (budget > 0),
	 primary key (dept_name)
	);
GO
create table [college_2].course
	(course_id		varchar(8),
	 title			varchar(50),
	 dept_name		varchar(20) NULL,
	 credits		numeric(2,0) check (credits > 0),
	 primary key (course_id),
	 foreign key (dept_name) references [college_2].department (dept_name)
		on delete set null
   );
GO
create table [college_2].instructor
	(ID			varchar(5),
	 name			varchar(20) not null,
	 dept_name		varchar(20),
	 salary			numeric(8,2) check (salary > 29000),
	 primary key (ID),
	 foreign key (dept_name) references [college_2].department (dept_name)
		on delete set null
	);
GO
create table [college_2].section
	(course_id		varchar(8),
         sec_id			varchar(8),
	 semester		varchar(6)
		check (semester in ('Fall', 'Winter', 'Spring', 'Summer')),
	 year			numeric(4,0) check (year > 1701 and year < 2100),
	 building		varchar(15),
	 room_number		varchar(7),
	 time_slot_id		varchar(4),
	 primary key (course_id, sec_id, semester, year),
	 foreign key (course_id) references [college_2].course (course_id)
		on delete cascade,
	 foreign key (building, room_number) references [college_2].classroom (building, room_number)
		on delete set null
	);
GO
create table [college_2].teaches
	(ID			varchar(5),
	 course_id		varchar(8),
	 sec_id			varchar(8),
	 semester		varchar(6),
	 year			numeric(4,0),
	 primary key (ID, course_id, sec_id, semester, year),
	 foreign key (course_id,sec_id, semester, year) references [college_2].section (course_id, sec_id, semester, year)
		on delete cascade,
	 foreign key (ID) references [college_2].instructor (ID)
		on delete cascade
	);
GO
create table [college_2].student
	(ID			varchar(5),
	 name			varchar(20) not null,
	 dept_name		varchar(20),
	 tot_cred		numeric(3,0) check (tot_cred >= 0),
	 primary key (ID),
	 foreign key (dept_name) references [college_2].department (dept_name)
		on delete set null
	);
GO
create table [college_2].takes
	(ID			varchar(5),
	 course_id		varchar(8),
	 sec_id			varchar(8),
	 semester		varchar(6),
	 year			numeric(4,0),
	 grade		        varchar(2),
	 primary key (ID, course_id, sec_id, semester, year),
	 foreign key (course_id,sec_id, semester, year) references [college_2].section (course_id, sec_id, semester, year)
		on delete cascade,
	 foreign key (ID) references [college_2].student (ID)
		on delete cascade
	);
GO
create table [college_2].advisor
	(s_ID			varchar(5),
	 i_ID			varchar(5),
	 primary key (s_ID, i_ID),
	 foreign key (i_ID) references [college_2].instructor (ID)
		on delete cascade,
	 foreign key (s_ID) references [college_2].student (ID)
		on delete cascade
	);
GO
create table [college_2].time_slot
	(time_slot_id		varchar(4),
	 day			varchar(1),
	 start_hr		numeric(2) check (start_hr >= 0 and start_hr < 24),
	 start_min		numeric(2) check (start_min >= 0 and start_min < 60),
	 end_hr			numeric(2) check (end_hr >= 0 and end_hr < 24),
	 end_min		numeric(2) check (end_min >= 0 and end_min < 60),
	 primary key (time_slot_id, day, start_hr, start_min)
	);
GO
create table [college_2].prereq
	(course_id		varchar(8),
	 prereq_id		varchar(8),
	 primary key (course_id, prereq_id),
	 foreign key (course_id) references [college_2].course (course_id)
		on delete cascade,
	 foreign key (prereq_id) references [college_2].course (course_id)
	);
GO
COMMIT;
