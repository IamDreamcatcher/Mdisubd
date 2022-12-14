-- Database: restaurants

DROP DATABASE IF EXISTS restaurants WITH (FORCE);

CREATE DATABASE restaurants
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
CREATE EXTENSION pgcrypto;

CREATE TABLE IF NOT EXISTS account_statuses(
	id SMALLSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE	
);

CREATE TABLE IF NOT EXISTS order_statuses(
	id SMALLSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE	
);

CREATE TABLE IF NOT EXISTS users(
	id BIGSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	password TEXT NOT NULL,
	status_id SMALLSERIAL,
	CONSTRAINT fk_status FOREIGN KEY(status_id) REFERENCES account_statuses(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS logs(
	id BIGSERIAL PRIMARY KEY,
	user_id BIGSERIAL,
	message VARCHAR(255) NOT NULL,
	time timestamp,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS restaurants(
	id BIGSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE,
	address VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS clients(
	id BIGSERIAL PRIMARY KEY,
	user_id BIGSERIAL,
	number VARCHAR(255) NOT NULL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cooks(
	id BIGSERIAL PRIMARY KEY,
	user_id BIGSERIAL,
	restaurant_id BIGSERIAL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_restaurant FOREIGN KEY(restaurant_id) REFERENCES restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS couriers(
	id BIGSERIAL PRIMARY KEY,
	user_id BIGSERIAL,
	restaurant_id BIGSERIAL,
	number VARCHAR(255) NOT NULL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_restaurant FOREIGN KEY(restaurant_id) REFERENCES restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS administrators(
	id BIGSERIAL PRIMARY KEY,
	user_id BIGSERIAL,
	restaurant_id BIGSERIAL,
	number VARCHAR(255) NOT NULL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_restaurant FOREIGN KEY(restaurant_id) REFERENCES restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS owners(
	id BIGSERIAL PRIMARY KEY,
	user_id BIGSERIAL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ingridients(
	id BIGSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE	
);

CREATE TABLE IF NOT EXISTS products(
	id BIGSERIAL PRIMARY KEY,
	restaurant_id BIGSERIAL,
	name VARCHAR(255) NOT NULL,
	description TEXT NOT NULL,
	price numeric NOT NULL CHECK(price>=0),
	photo_path VARCHAR(255) NOT NULL,
	CONSTRAINT fk_restaurant FOREIGN KEY(restaurant_id) REFERENCES restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product_ingridients(
	id BIGSERIAL PRIMARY KEY,
	product_id BIGSERIAL,
	ingridient_id BIGSERIAL,
	CONSTRAINT fk_product FOREIGN KEY(product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_ingridient FOREIGN KEY(ingridient_id) REFERENCES ingridients(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orders(
	id BIGSERIAL PRIMARY KEY,
	status_id SMALLSERIAL,
	client_id BIGSERIAL,
	courier_id BIGSERIAL,
	cook_id BIGSERIAL,
	administrator_id BIGSERIAL,
	price numeric NOT NULL CHECK(price>=0),
	CONSTRAINT fk_administrator FOREIGN KEY(administrator_id) REFERENCES administrators(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_cook FOREIGN KEY(cook_id) REFERENCES cooks(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_courier FOREIGN KEY(courier_id) REFERENCES couriers(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_status FOREIGN KEY(status_id) REFERENCES order_statuses(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_client FOREIGN KEY(client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS products_orders(
	id BIGSERIAL PRIMARY KEY,
	product_id BIGSERIAL,
	order_id BIGSERIAL,
	CONSTRAINT fk_product FOREIGN KEY(product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_order FOREIGN KEY(order_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews(
	id BIGSERIAL PRIMARY KEY,
	client_id BIGSERIAL,
	order_id BIGSERIAL,
	message VARCHAR(500) NOT NULL,
	CONSTRAINT fk_client FOREIGN KEY(client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_order FOREIGN KEY(order_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE
);
