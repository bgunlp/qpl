USE spider;
CREATE TABLE  yelp.business (
[bid] int,
[name] VARCHAR(400),
[full_address] VARCHAR(400),
[city] VARCHAR(400),
[latitude] VARCHAR(400),
[longitude] VARCHAR(400),
[review_count] int,
[is_open] int,
[rating] real,
[state] VARCHAR(400),
primary key([bid])
);
CREATE TABLE  yelp.category (
[id] int,
[business_id] int,
[category_name] VARCHAR(400),
primary key([id]),
foreign key([business_id]) references  yelp.business([bid])
);
CREATE TABLE  yelp.[user] (
[uid] int,
[name] VARCHAR(400),
primary key([uid])
);
CREATE TABLE  yelp.checkin (
[cid] int,
[business_id] int,
[count] int,
[day] VARCHAR(400),
primary key([cid]),
foreign key([business_id]) references  yelp.business([bid])
);

CREATE TABLE  yelp.neighbourhood (
[id] int,
[business_id] int,
[neighbourhood_name] VARCHAR(400),
primary key([id]),
foreign key([business_id]) references  yelp.business([bid])
);

CREATE TABLE  yelp.review (
[rid] int,
[business_id] int,
[user_id] int,
[rating] real,
[VARCHAR(400)] VARCHAR(400),
[year] int,
[month] VARCHAR(400),
primary key([rid]),
foreign key([business_id]) references  yelp.business([bid]),
foreign key([user_id]) references  yelp.[user]([uid])
);
CREATE TABLE  yelp.tip (
[tip_id] int,
[business_id] int,
[text] VARCHAR(400),
[user_id] int,
[likes] int,
[year] int,
[month] VARCHAR(400),
primary key([tip_id]),
foreign key([business_id]) references  yelp.business([bid]),
foreign key([user_id]) references  yelp.[user]([uid])

);
