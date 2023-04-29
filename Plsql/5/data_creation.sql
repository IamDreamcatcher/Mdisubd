drop table films;
drop table actors;
drop table producers;


CREATE TABLE actors
(
    actor_id  NUMBER(10)
        CONSTRAINT PK_actors PRIMARY KEY,
    first_name   VARCHAR2(50),
    last_name    VARCHAR2(50),
    email        VARCHAR2(100) UNIQUE,
    phone_number VARCHAR2(50)
);

CREATE TABLE producers
(
    producer_id   NUMBER(10)
        CONSTRAINT PK_producers PRIMARY KEY,
    producer_name VARCHAR2(100),
    filmography   VARCHAR2(500),
    age         NUMBER
);

CREATE TABLE films
(
    film_id    NUMBER(10)
        CONSTRAINT PK_films PRIMARY KEY,
    film_date  DATE,
    actor_id NUMBER(10),
    producer_id NUMBER(10),
    box_office      NUMBER(10),
    CONSTRAINT fk_actor FOREIGN KEY (actor_id) REFERENCES actors (actor_id),
    CONSTRAINT fk_producer FOREIGN KEY (producer_id) REFERENCES producers (producer_id)
);

drop table actors_history;
drop table producers_history;
drop table films_history;

CREATE TABLE actors_history
(
    action_id    number,
    actor_id  NUMBER(10),
    first_name   VARCHAR2(50),
    last_name    VARCHAR2(50),
    email        VARCHAR2(100),
    phone_number VARCHAR2(50),
    change_date  DATE,
    change_type  VARCHAR2(10)
);

CREATE TABLE producers_history
(
    action_id     number,
    producer_id   NUMBER(10),
    producer_name VARCHAR2(100),
    filmography   VARCHAR2(500),
    age         NUMBER,
    change_date   DATE,
    change_type   VARCHAR2(10)
);

CREATE TABLE films_history
(
    action_id   number,
    film_id    NUMBER(10),
    film_date  DATE,
    actor_id NUMBER(10),
    producer_id NUMBER(10),
    box_office      NUMBER(10),
    change_date DATE,
    change_type VARCHAR2(10)
);

drop table reports_history;
create table reports_history
(
    id          number GENERATED ALWAYS AS IDENTITY,
    report_date timestamp,
    CONSTRAINT PK_reports PRIMARY KEY (id)
);

insert into reports_history(report_date)
values (to_timestamp('1000-04-23 18:25:00', 'YYYY-MM-DD HH24:MI:SS'));
select *
from reports_history;

drop sequence history_seq;
create sequence history_seq start with 1;
