create table netflix
(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(15),
discription varchar(250)
);
select * from netflix;
alter table netflix alter column listed_in type varchar(150);
select count(*) from netflix;

select distinct type from netflix;

--lets solve problems
--1. count the  number of movies vs tv shows
select type,count(*) as total_content from netflix group by type;

--2. find the most common rating for movies and tv shows
select type, rating
from
(select type, rating ,
count(*),
rank() over(partition by Type order by count(*)desc)as ranking
from
netflix
group by 1,2 )as s1
where ranking=1;
.

--order by 1,3 desc;

--3.list all the movies released in specified year(2020)
select * from netflix
where 
type='Movie' and release_year=2020;

--4. find the top 5 countries with the most content on netflix
select country,count(show_id) as total_content
from netflix
group by 1 order by total_content desc;  --// this is also correct but in our data country has too many countries in one line by commas  so we need to separate them by below code

select 
unnest(string_to_array(country,','))as new_country  --// this query separates the all country which were in one line  and unnest them all
from netflix;

select 
unnest(string_to_array(country,','))as new_country ,
count(show_id) as total_content
from netflix
group by 1 
order by 2 desc limit 5; --// this is the correct query for the question because it is showing single country and their total contenet

--5. identify the longest movie
select * from netflix
where type='Movie' 
and
duration=(select max(duration)from netflix);

--6.find the content that added in the last 5 years
select * from netflix
where
to_date(date_added,'Month ,dd, yyyy') >= current_date - interval '5 years'; --// here todate converts the text format of date into the date format

--7.find all the movies /tv shows by director 'rajiv chilaka'
select * from netflix 
where director like '%Rajiv Chilaka%';

--8.  list all the tv shows with more than 5 seasons
select * from netflix 
where 
type= 'TV Show'and 
duration>='5 seasons'; 

--9.count the number ofcontent items in each genre 
select 
unnest(string_to_array(listed_in,','))as genre,
count(show_id) as total_content
from netflix
group by 1;

--10.find each year and the average numbers of content release by india on netflix, 
--return top5 year with highest average content release
select 
extract(year from to_date(date_added,'Month dd, yyyy'))as year,
count(*),
round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric*100,2)as avg_contenet_per_year
from netflix
where country='India'
group by 1;

--11.list all the movies that are documentaries
select * from netflix 
where listed_in like '%Documentaries%'

--12 find all the content without director
select * from netflix 
where director is Null

--13. find how many movies ACTOR 'salman' khan appeared  in last 90 days
select * from netflix 
where 
casts  Ilike '%salman khan%'
and
release_year >=extract(year from current_date)-10  

--14.find the top 10 actors who have appeard in the highest number of movies produced in india
select 
unnest(string_to_array(casts,','))as actors,
count(*) as total_content
from netflix 
where country ILIKE '%india%'
group by 1
order by 2 desc limit 10;

--15. categorize the content based on the presence of the keywords 'kill' and 'violence' in the
--discription field .label content containing these keywords as 'bad' and all other content as 'good'.
--count how many items fall into each category
with new_table --//CTE Function
as
(
select * ,
case
when discription ILIKe '%Kill%' 
or 
discription ILIKe '%violence%' then 'bad_content'
else 'good_content'
end category
from netflix 
)
select category,count(*)
from new_table
group by 1;