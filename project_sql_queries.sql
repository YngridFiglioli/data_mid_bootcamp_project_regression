#Requirements
#Create a database called house_price_regression.
#Create a table house_price_data with the same columns as given in the csv file. Please make sure you use the correct data types for the columns.
#Import the data from the csv file into the table. Before you import the data into the empty table, make sure that you have deleted the headers from the csv file. To not modify the original data, if you want you can create a copy of the csv file as well. Note you might have to use the following queries to give permission to SQL to import data from csv files in bulk:
#SHOW VARIABLES LIKE 'local_infile'; -- This query would show you the status of the variable ‘local_infile’. If it is off, use the next command, otherwise you should be good to go;
#SET GLOBAL local_infile = 1;
#Select all the data from table house_price_data to check if the data was imported correctly#
#Use the alter table command to drop the column date from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. Limit your returned results to 10.
#Use sql query to find how many rows of data you have.
#Now we will try to find the unique values in some of the categorical columns:
	#What are the unique values in the column bedrooms?
	#What are the unique values in the column bathrooms?
	#What are the unique values in the column floors?
	#What are the unique values in the column condition?
	#What are the unique values in the column grade?
#Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.
#What is the average price of all the properties in your data?
#In this exercise we will use simple group by to check the properties of some of the categorical variables in our data
#What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second column.
#What is the average sqft_living of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the sqft_living. Use an alias to change the name of the second column.
#What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and Average of the prices. Use an alias to change the name of the second column.
#Is there any correlation between the columns condition and grade? You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
#One of the customers is only interested in the following houses:
	#Number of bedrooms either 3 or 4
	#Bathrooms more than 3
	#One Floor
	#No waterfront
	#Condition should be 3 at least
	#Grade should be 5 at least
	#Price less than 300000
	#For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
#Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. Write a query to show them the list of such properties. You might need to use a sub query for this problem.
#Since this is something that the senior management is regularly interested in, create a view of the same query.
#Most customers are interested in properties with three or four bedrooms. What is the difference in average prices of the properties with three and four bedrooms?
#What are the different locations where properties are available in your database? (distinct zip codes)
#Show the list of all the properties that were renovated.
#Provide the details of the property that is the 11th most expensive property in your database.

create database if not exists house_price_regression;
use house_price_regression;

create table house_price_data (
	`id` bigint not null,
    `date` text,
    `bedrooms` int,
    `bathrooms` decimal,
    `sqft_living` int,
    `sqft_lot` int,
    `floors` decimal,
    `waterfront` int,
    `view` int,
    `condition` int,
    `grade` int,
    `sqft_above` int,
    `sqft_basement` int,
    `yr_built` int,
    `yr_renovated` int,
    `zipcode` int,
    `lat` float,
    `long` float,
    `sqft_living15` int,
    `sqft_lot15` int,
    `price` int
    );

select * from house_price_data;

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

load data local infile '/Users/yngridfiglioli/Desktop/Ironhack/mid_bootcamp_project/data_mid_bootcamp_project_regression/regression_data.csv'
into table house_price_data fields terminated BY ','  lines terminated by '\n'
(`id`,`date`,`bedrooms`,`bathrooms`,`sqft_living`,`sqft_lot`,`floors`,`waterfront`,`view`,`condition`,`grade`,
    `sqft_above`,`sqft_basement`,`yr_built`,`yr_renovated`,`zipcode`,`lat`,`long`,`sqft_living15`,`sqft_lot15`,`price`);

select * from house_price_data;

alter table house_price_data
drop column date;

select * from house_price_data limit 10;

select count(*) from house_price_data; #Answer: 21597 rows

select distinct(bedrooms), count(id) as quantity_houses
from house_price_data group by bedrooms order by quantity_houses;

select distinct(floors) from house_price_data order by floors;
select distinct(floors), count(id) as quantity_houses
from house_price_data group by floors order by quantity_houses;

select distinct(`condition`) from house_price_data order by `condition`;
select distinct(`condition`), count(id) as quantity_houses, round(avg(price), 0) as avg_price
from house_price_data group by `condition` order by avg_price asc;

select distinct(grade) from house_price_data order by grade;
select distinct(grade), count(id) as quantity_houses, round(avg(price), 0) as avg_price
from house_price_data group by grade order by avg_price asc;

select id, price from house_price_data order by price desc limit 10;

select round(avg(price),0) as avg_price from house_price_data; #Answer: 

select distinct(bedrooms), round(avg(price),0) as avg_price from house_price_data group by bedrooms order by avg_price;
select bedrooms, round(avg(sqft_living),0) as avg_sqft_living from house_price_data group by bedrooms order by avg_sqft_living;
select waterfront, round(avg(price),0) as avg_price from house_price_data group by waterfront order by avg_price;

select `condition`, avg(grade) as avg_grade from house_price_data group by `condition` order by avg_grade asc;
select grade, avg(`condition`) as avg_condition from house_price_data group by grade order by avg_condition asc;
#Answer: the condition with avg_grade seems to have a correlation, since both ascende, starting with condition 1 and grade 5. 
#However, the second query doesnt show a correlation between grade and avg_condition.alter

select * from house_price_data where bedrooms in (3,4) and bathrooms > 3 and floors = 1 and waterfront = 0 and `condition`>= 3 and grade >= 5 and price < 300000 order by price asc;
#Answer: we dont have a house with that exact conditions to show the client, maybe if the client accept for a <= 3 bathrooms, we have 53 options.

select id,price from house_price_data where price > (select (avg(price) * 2) from house_price_data) order by price asc;

create view outliers_avgprice_houses as (select id, price from house_price_data where price > (select (avg(price) * 2) from house_price_data));
select * from outliers_avgprice_houses;

select round((avg(four.price) - avg(three.price)),2) as diff_avgprice from house_price_data as three
cross join house_price_data as four
where three.bedrooms = 3 and four.bedrooms = 4 group by four.bedrooms;
#Answer the difference from the price is considerable high from 3 to 4 bedrooms.

select distinct(zipcode) as zones from house_price_data;

select id, yr_renovated, bedrooms, bathrooms, grade, `condition`, zipcode, price from house_price_data where yr_renovated != 0 order by price asc;

select * from (select *, rank() over (order by price desc) as ranking from house_price_data) as ranked_table where ranking = 11;










