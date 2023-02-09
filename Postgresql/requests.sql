-- SELECT * FROM users;
-- ALTER TABLE users ADD COLUMN title INT;
-- ALTER TABLE users ALTER COLUMN title TYPE REAL;
-- ALTER TABLE users ADD CONSTRAINT unique_title UNIQUE(title);
-- UPDATE users SET title = 5/2 WHERE id_user = 1;
-- DELETE FROM users WHERE title = 3.12312;
-- ALTER TABLE users DROP CONSTRAINT unique_title;
-- ALTER TABLE users DROP COLUMN title;
-- EXPLAIN (ANALYZE, VERBOSE, COSTS, SETTINGS, BUFFERS, WAL, TIMING, SUMMARY, FORMAT) SELECT 
-- ALTER SEQUENCE seq RESTART WITH 1;
-- ON DELETE(CASCADE, SET NULL, RESTRICT, NO ACTION, SET DEFAULT)
-- ILIKE = LIKE, но ILIKE нечувствительным к регистру

-- select email, name with account status active
SELECT u.email, u.name
FROM users as u
JOIN account_statuses as st ON u.status_id = st.id
WHERE st.name = 'Active';

-- select email of users if account status = banned and email ="%@yahoo.com"
SELECT u.email
FROM users as u
JOIN account_statuses as st ON u.status_id = st.id
WHERE st.name = 'Banned' AND u.email LIKE '%@yahoo.com';
					   
-- select numbers of couriers & administrators
SELECT number FROM couriers
UNION SELECT number FROM administrators;

-- select name of clients who make orders in restaurant = 'Васильки'
SELECT DISTINCT u.name
FROM clients as cl
JOIN users as u ON cl.user_id = u.id
JOIN orders as ord ON ord.client_id = cl.id
JOIN administrators as adm ON ord.administrator_id = adm.id
WHERE adm.restaurant_id IN (SELECT id
							FROM restaurants as rst
							WHERE rst.name = 'Васильки');
										
-- select name of clinets make <=1 reviews
SELECT DISTINCT u.name, u.email
FROM clients as cl
JOIN users as u ON u.id = cl.user_id
WHERE (name, email) NOT IN (SELECT u.name, u.email
							FROM clients as cl
							JOIN users as u ON u.id = cl.user_id
							JOIN reviews rv ON rv.client_id = cl.id
						    GROUP BY (name, email)
						    HAVING COUNT(*) > 1);

-- select only august's logs 
SELECT message
FROM logs as lg
WHERE EXTRACT(MONTH FROM lg.time) = 08;

-- select type of order statuses
SELECT name
FROM order_statuses 
GROUP BY name; 

-- select clients consumption 
SELECT SUM(ord.price), u.name
FROM clients as cl
JOIN users as u ON u.id = cl.user_id
JOIN orders as ord ON ord.client_id = cl.id
GROUP BY u.name;

-- select products with <=2 ingridients
SELECT COUNT(*) count_of_ingridients, pr.name
FROM products as pr
JOIN product_ingridients as ing ON pr.id = ing.product_id
GROUP BY pr.name
HAVING COUNT(*) <= 2;

-- select count of clients
SELECT COUNT(*)
FROM clients;

-- select average price of products
SELECT AVG(price)
FROM products;

-- select name, emails of all owners
SELECT u.name , u.email 
FROM owners as own
JOIN users as u ON u.id = own.user_id;

-- select name of clients and their orders's prices with statuses != denied
SELECT u.name, ord.price, st.name
FROM clients as cl
JOIN users as u ON u.id = cl.user_id
JOIN orders as ord ON ord.client_id = cl.id
JOIN order_statuses as st ON ord.status_id = st.id
WHERE st.name NOT IN ('Denied')
GROUP BY (u.name, ord.price, st.name)

--select products from the end with 2, 3 pcs
SELECT * FROM products ORDER BY id DESC LIMIT 3 OFFSET 2;

--select the quantity of products in a rst's with a CASE design relative to 10000
SELECT rst.name, pr.name, pr.price,
CASE WHEN pr.price < 10000 THEN 'Меньше 10000'
     WHEN pr.price = 10000 THEN '10000'
     ELSE 'Больше 10000'
END as case_price
FROM products AS pr
JOIN restaurants AS rst ON pr.restaurant_id = rst.id;

--select products in restik id = 1 if exist cook in restik id 1
SELECT name from products as pr
WHERE pr.restaurant_id = 1 AND EXISTS (SELECT restaurant_id FROM cooks WHERE restaurant_id = 1);