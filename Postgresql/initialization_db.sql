INSERT INTO account_statuses(name) VALUES
('Active'),
('Banned');

INSERT INTO order_statuses(name) VALUES
('Accepted'),
('Cooking'),
('Delivery'),
('Denied'),
('Completed');

INSERT INTO users(name, email, password, status_id) VALUES
('firstUser', 'firstUser@gmail.com', crypt('firstUserfirst', gen_salt('md5')), 1),
('secondUser', 'secondUser@yandex.ru', crypt('secondUsersecond', gen_salt('md5')), 1),
('thirdUser', 'thirdUser@mail.ru', crypt('thirdUserthird', gen_salt('md5')), 1),
('fourthUser', 'fourthUser@yandex.by', crypt('fourthUserfourth', gen_salt('md5')), 1),
('fifthUser', 'fifthUser@yahoo.com', crypt('fifthUserfifth', gen_salt('md5')), 2),
('sixthUser', 'sixthUser@yandex.by', crypt('sixthUsersixth', gen_salt('md5')), 1);

INSERT INTO logs(user_id, message, time) VALUES
(1, 'User registered', '2015-08-13 19:12:50-08'),
(1, 'User logined', '2017-09-14 13:13:50-08'),
(1, 'User make order', '2018-08-14 14:14:50-08'),
(5, 'User registered', '2019-09-15 15:15:50-08'),
(5, 'User was banned', '2021-08-16 16:16:50-08');

INSERT INTO restaurants(name, address) VALUES
('Васильки', 'просп. Независимости, 16'),
('Раковский Бровар', 'Раковская ул., 19А (этаж 2)'),
('La Scala Trattoria Ignazio', 'ул. Немига, 36'),
('Ресторан 101', 'ул. Городской Вал, 12, корп. 1 (этаж 1)'),
('The View', 'просп. Победителей, 7А (этаж 28)');

INSERT INTO clients(user_id, number) VALUES
(4, '+375298549388'),
(5, '+375298549389');

INSERT INTO cooks(user_id, restaurant_id) VALUES
(3, 1);

INSERT INTO couriers(user_id, restaurant_id, number) VALUES
(2, 1, '+375339549388');

INSERT INTO administrators(user_id, restaurant_id, number) VALUES
(6, 1, '+375339549888');

INSERT INTO owners(user_id) VALUES
(1);

INSERT INTO ingridients(name) VALUES
('kiwi'),
('Potato'),
('Sour cream'),
('Flour'),
('Butter'),
('Salt'),
('These are'),
('Draniki with kiwi');

INSERT INTO products(restaurant_id, name, description, price, photo_path) VALUES
(1, 'kasha','Если вдруг', 1, 'Images\Draniki'),
(2, 'kakasha','Вам стало скучно', 10, 'Images\DranikiWithSourCream'),
(3, 'nasha', 'Ну или грустно', 100, 'Images\DranikiWithKetchinezzze'),
(4, 'rasha', 'Вы можете сделать драники.....', 1000, 'Images\DranikiWithSosiski'),
(5, 'parasha', '... с начинкой из киви', 10000, 'Images\DranikiNetSKolbasoy'),
(1, 'pasta', 'И только тогда поймете', 20000, 'Images\DranikiKakSmyslZhizny'),
(2, 'copypasta', 'Что никогда не ели нормальную еду', 30000, 'Images\DranikiX3kakye'),
(3, 'karakatoya i kiwi','Следующий раз будет', 40000, 'Images\DranikiIzPomidorov'),
(4, 'pencils', 'Рецепт с черникой', 50000, 'Images\cringe');

INSERT INTO product_ingridients(product_id, ingridient_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(1, 5),
(1, 6),
(2, 7),
(3, 8),
(5, 1),
(6, 2),
(7, 3),
(8, 4),
(9, 1),
(9, 3);

INSERT INTO orders(status_id, client_id, courier_id, cook_id, administrator_id, price) VALUES
(1, 1, 1, 1, 1, 12345),
(2, 2, 1, 1, 1, 552345),
(3, 1, 1, 1, 1, 12345),
(4, 2, 1, 1, 1, 552345),
(5, 2, 1, 1, 1, 552345);

INSERT INTO products_orders(product_id, order_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 1),
(7, 2),
(8, 3),
(9, 4),
(1, 5);

INSERT INTO reviews(client_id, order_id, message) VALUES
(1, 1, 'kek'),
(1, 2, 'lol'),
(1, 3, 'cheburek'),
(1, 4, 'xto'),
(2, 5, 'ya');

CREATE INDEX email_idx ON users(email);
CREATE INDEX name_idx ON restaurants(name);
CREATE INDEX products_idx ON products(name);
