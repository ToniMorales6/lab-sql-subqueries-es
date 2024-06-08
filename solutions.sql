use sakila;

-- 1. ¿Cuántas copias de la película El Jorobado Imposible existen en el sistema de inventario?
SELECT f.title, count(*) as Total_Copies
	FROM sakila.inventory as i
    JOIN film as f
    ON f.film_id = i.film_id
    WHERE f.title = 'Hunchback Impossible'
    GROUP BY f.title;

-- 2. Lista todas las películas cuya duración sea mayor que el promedio de todas las películas.
SELECT title FROM sakila.film WHERE length > (SELECT AVG(length) FROM film);

-- 3. Usa subconsultas para mostrar todos los actores que aparecen en la película Viaje Solo.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip'));


-- 4. Las ventas han estado disminuyendo entre las familias jóvenes, y deseas dirigir todas las películas familiares a una promoción.
-- Identifica todas las películas categorizadas como películas familiares.
SELECT title FROM sakila.film WHERE film_id IN (
	SELECT film_id FROM sakila.film_category WHERE category_id = (
		SELECT category_id FROM sakila.category WHERE name = 'family'
	)
);

-- 5. Obtén el nombre y correo electrónico de los clientes de Canadá usando subconsultas. Haz lo mismo con uniones. 
-- Ten en cuenta que para crear una unión, tendrás que identificar las tablas correctas con sus claves primarias y claves foráneas, que te ayudarán a obtener la información relevante.
SELECT email FROM sakila.customer WHERE address_id IN (
	SELECT address_id FROM sakila.address WHERE city_id IN (
		SELECT city_id FROM sakila.city WHERE country_id IN (
			SELECT country_id FROM sakila.country WHERE country = 'CANADA'
		)
	)
);

-- 6. ¿Cuáles son las películas protagonizadas por el actor más prolífico? El actor más prolífico se define como el actor que ha actuado en el mayor número de películas. 
-- Primero tendrás que encontrar al actor más prolífico y luego usar ese actor_id para encontrar las diferentes películas en las que ha protagonizado.
SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM film_actor WHERE actor_id = (SELECT actor_id FROM (SELECT actor_id, COUNT(*) AS film_count FROM film_actor GROUP BY actor_id ORDER BY film_count DESC LIMIT 1) AS most_prolific_actor));


-- 7. Películas alquiladas por el cliente más rentable.
-- Puedes usar la tabla de clientes y la tabla de pagos para encontrar al cliente más rentable, es decir, el cliente que ha realizado la mayor suma de pagos.
SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM inventory WHERE inventory_id IN (SELECT inventory_id FROM rental WHERE customer_id = (SELECT customer_id FROM (SELECT customer_id, SUM(amount) AS total_spent FROM payment GROUP BY customer_id ORDER BY total_spent DESC LIMIT 1) AS most_profitable_customer)));


-- 8. Obtén el client_id y el total_amount_spent de esos clientes que gastaron más que el promedio del total_amount gastado por cada cliente.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(total_spent) FROM (SELECT customer_id, SUM(amount) AS total_spent FROM payment GROUP BY customer_id) AS avg_amount_spent);