-- CREATE TABLE NETFLIX PROJECT
DROP TABLE IF EXISTS NETFLIX;
CREATE TABLE NETFLIX 
(
	show_id	VARCHAR(6),
	type VARCHAR(10),	
	title VARCHAR(150),
	director VARCHAR(208),	
	castS VARCHAR(1000),	
	country	VARCHAR(150),
	date_added VARCHAR(50),	
	release_year INT,	
	rating VARCHAR(15),
	duration VARCHAR(20),	
	listed_in VARCHAR(200),	
	description VARCHAR(250)

)