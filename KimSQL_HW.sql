use sakila;

-- 1a: Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

-- 1b:Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, " ", last_name) as 'Actor Name' from actor;

--  2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id from actor where first_name = Joe;

-- 2b.  Find all actors whose last name contain the letters `GEN`:
select first_name, last_name from actor where last_name like '%GEN%'; 

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select first_name, last_name 
from actor where last_name like '%LI%'
order by last_name, first_name; 

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('China','Afghanistan','Bangladesh');

-- 3a. create a column in the table `actor` named `description` and use the data type `BLOB` 
alter table  actor add column Description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN Description;

--  4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*)
from actor
group by last_name;

-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*)
from actor
group by last_name
having count(*) >1; 

-- 4c The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor 
set first_name = 'HARPO'
where first_name ='GROUCHO'and last_name = 'WILLIAMS';


-- 4d In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`
update actor 
set first_name = 'GROUCHO'
where first_name ='HARPO'and last_name = 'WILLIAMS';

-- CHECK IF TABLE DID AS EXPECTED -- 
select first_name, last_name 
from actor
where last_name ='WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
create table address_2( 
	address_id int not null auto_increment, 
    address varchar(50),
    address2 varchar(50),
    district varchar(20), 
    city_id smallint(5), 
    postal_code varchar(10), 
    phone varchar(20), 
    location geometry, 
    last_update timestamp,
    primary key (address_id)
);

DROP DATABASE IF EXISTS address_2;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.   
-- select * from staff; 
  
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select first_name, last_name, sum(payment.amount) from staff 
join payment on payment.staff_id = staff.staff_id 
where payment_date > '2005-08-01 00:00:00'
and payment_date < '2005-09-01 00:00:00' 
group by first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select title, count(film_actor.actor_id) as 'number of actors' from film
inner join film_actor on film_actor.film_id = film.film_id
group by title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(inventory.film_id)as 'number of copies' from film 
join inventory on film.film_id = inventory.film_id
where title = 'Hunchback Impossible' 
group by title; 


-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select first_name, last_name, sum(payment.amount)as 'total paid'  from customer
join payment on customer.customer_id = payment.customer_id
group by first_name, last_name
order by last_name;


-- 7a.Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film 
WHERE title like 'Q%' OR title like 'K%' AND 
language_id IN
(
  SELECT language_id
  FROM language
  WHERE name = 'English' 
);  

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN 
(
SELECT actor_id
FROM film_actor
WHERE film_id IN
(
  SELECT film_id
  FROM film
  WHERE title ='Alone Trip' 
)
);  

-- 7c Use joins to retreive name and email of all canadian customers 
select customer.first_name, customer.last_name, customer.email, country.country 
from customer
join address on address.address_id = customer.address_id
join city on city.city_id = address.city_id
join country on city.country_id = country.country_id
where country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

Select title
from film
where film_id IN 
(select film_id 
from film_category
where category_id IN 
(select category_id 
from category 
where name = 'Family'
)
);

-- 7e. Display the most frequently rented movies in descending order.
select title, count(inventory.film_id) as tot_rentals
from film
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by title
order by tot_rentals DESC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount) as 'total spend'
from store
join customer on store.store_id = customer.store_id
join payment on customer.customer_id = payment.customer_id
group by store.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city.city, country.country
from store
join address on store.address_id = address.address_id
join city on city.city_id = address.city_id
join country on city.country_id = country.country_id
;

-- 7h. List the top five genres in gross revenue in descending order.
select category.name, sum(payment.amount) AS tot_sales
from payment 
join rental ON payment.rental_id = rental.rental_id
join inventory ON rental.inventory_id = inventory.inventory_id
join film ON inventory.film_id = film.film_id
join film_category ON film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY tot_sales DESC
limit 5 
;

create view top_5_genre as 
select category.name, sum(payment.amount) AS tot_sales
from payment 
join rental ON payment.rental_id = rental.rental_id
join inventory ON rental.inventory_id = inventory.inventory_id
join film ON inventory.film_id = film.film_id
join film_category ON film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
group by category.name
order by tot_sales DESC
limit 5 
;

Drop view top_5_genre;

select * from payment
;
