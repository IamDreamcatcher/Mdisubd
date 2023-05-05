delete
from films;
delete
from actors;
delete
from producers;

INSERT INTO actors (actor_id, first_name, last_name, email, phone_number)
VALUES (1, 'first_name1', 'last_name1', 'email1@gmail.com', 'phone_number1');

INSERT INTO actors (actor_id, first_name, last_name, email, phone_number)
VALUES (2, 'first_name2', 'last_name2', 'email2@gmail.com', 'phone_number2');

UPDATE actors
set phone_number = 'new phone'
where actor_id = 2;

INSERT INTO producers (producer_id, producer_name, filmography, age)
VALUES (1, 'producer_name1', 'filmography1', 45);

INSERT INTO producers (producer_id, producer_name, filmography, age)
VALUES (2, 'producer_name2', 'filmography2', 30);

INSERT INTO films (film_id, film_date, actor_id, producer_id, box_office)
VALUES (1, TO_DATE('2002-02-02', 'YYYY-MM-DD'), 1, 1, 1000);

INSERT INTO films (film_id, film_date, actor_id, producer_id, box_office)
VALUES (2, TO_DATE('2023-05-05', 'YYYY-MM-DD'), 2, 2, 22313);

delete
from films
where film_id = 2;

---------------

select *
from actors;
select *
from actors_history;

select *
from producers;
select *
from producers_history;

select *
from films;
select *
from films_history;

select *
from reports_history;

call rollback_by_date(to_timestamp('2023-04-29 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
call rollback_by_date(to_timestamp('2023-05-01 23:30:40', 'YYYY-MM-DD HH24:MI:SS'));
call FUNC_PACKAGE.ROLL_BACK(100000);
call FUNC_PACKAGE.ROLL_BACK(to_timestamp('2023-05-05 13:44:50', 'YYYY-MM-DD HH24:MI:SS'));
call FUNC_PACKAGE.REPORT();
call FUNC_PACKAGE.REPORT(to_timestamp('2023-04-29 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                         to_timestamp('2024-05-02 23:30:40', 'YYYY-MM-DD HH24:MI:SS'));