
CREATE OR REPLACE TRIGGER tr_actors_insert
    AFTER INSERT
    ON actors
    FOR EACH ROW
BEGIN
    INSERT INTO actors_history (action_id, actor_id, first_name, last_name, email, phone_number, change_date,
                                   change_type)
    VALUES (history_seq.nextval, :NEW.actor_id, :NEW.first_name, :NEW.last_name, :NEW.email, :NEW.phone_number,
            SYSDATE, 'INSERT');
END;

CREATE OR REPLACE TRIGGER tr_actors_update
    AFTER UPDATE
    ON actors
    FOR EACH ROW
DECLARE
    v_id number;
BEGIN
    INSERT INTO actors_history (action_id, actor_id, first_name, last_name, email, phone_number, change_date,
                                   change_type)
    VALUES (HISTORY_SEQ.nextval, :OLD.actor_id, :OLD.first_name, :OLD.last_name, :OLD.email, :OLD.phone_number,
            SYSDATE, 'DELETE');

    INSERT INTO actors_history (action_id, actor_id, first_name, last_name, email, phone_number, change_date,
                                   change_type)
    VALUES (HISTORY_SEQ.nextval, :OLD.actor_id, :OLD.first_name, :OLD.last_name, :OLD.email, :OLD.phone_number,
            SYSDATE, 'UPDATE');

    INSERT INTO actors_history (action_id, actor_id, first_name, last_name, email, phone_number, change_date,
                                   change_type)
    VALUES (HISTORY_SEQ.nextval, :NEW.actor_id, :NEW.first_name, :NEW.last_name, :NEW.email, :NEW.phone_number,
            SYSDATE, 'INSERT');
END;

CREATE OR REPLACE TRIGGER tr_actors_delete
    AFTER DELETE
    ON actors
    FOR EACH ROW
BEGIN
    INSERT INTO actors_history (action_id, actor_id, first_name, last_name, email, phone_number, change_date,
                                   change_type)
    VALUES (history_seq.nextval, :OLD.actor_id, :OLD.first_name, :OLD.last_name, :OLD.email, :OLD.phone_number,
            SYSDATE, 'DELETE');
END;

CREATE OR REPLACE TRIGGER tr_producers_insert
    AFTER INSERT
    ON producers
    FOR EACH ROW
BEGIN
    INSERT INTO producers_history (action_id, producer_id, producer_name, filmography, age, change_date, change_type)
    VALUES (history_seq.nextval, :new.producer_id, :new.producer_name, :new.filmography, :new.age, SYSDATE, 'INSERT');
END;

CREATE OR REPLACE TRIGGER tr_producers_update
    AFTER UPDATE
    ON producers
    FOR EACH ROW
DECLARE
    v_id number;
BEGIN
    v_id := HISTORY_SEQ.nextval;
    INSERT INTO producers_history (action_id, producer_id, producer_name, filmography, age, change_date, change_type)
    VALUES (v_id, :old.producer_id, :old.producer_name, :old.filmography, :old.age, SYSDATE, 'DELETE');

    INSERT INTO producers_history (action_id, producer_id, producer_name, filmography, age, change_date, change_type)
    VALUES (v_id, :old.producer_id, :old.producer_name, :old.filmography, :old.age, SYSDATE, 'UPDATE');

    INSERT INTO producers_history (action_id, producer_id, producer_name, filmography, age, change_date, change_type)
    VALUES (v_id, :new.producer_id, :new.producer_name, :new.filmography, :new.age, SYSDATE, 'INSERT');
END;

CREATE OR REPLACE TRIGGER tr_producers_delete
    AFTER DELETE
    ON producers
    FOR EACH ROW
BEGIN
    INSERT INTO producers_history (action_id, producer_id, producer_name, filmography, age, change_date, change_type)
    VALUES (history_seq.nextval, :old.producer_id, :old.producer_name, :old.filmography, :old.age, SYSDATE, 'DELETE');
END;

CREATE OR REPLACE TRIGGER tr_films_insert
    AFTER INSERT
    ON films
    FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO films_history (action_id, film_id, film_date, actor_id, producer_id, box_office, change_date,
                                change_type)
    VALUES (history_seq.NEXTVAL, :NEW.film_id, :NEW.film_date, :NEW.actor_id, :NEW.producer_id, :NEW.box_office,
            SYSDATE, 'INSERT');
END;

CREATE OR REPLACE TRIGGER tr_films_update
    AFTER UPDATE
    ON films
    FOR EACH ROW
DECLARE
    v_id number;
BEGIN
    v_id := HISTORY_SEQ.nextval;
    INSERT INTO films_history (action_id, film_id, film_date, actor_id, producer_id, box_office, change_date,
                                change_type)
    VALUES (v_id, :OLD.film_id, :OLD.film_date, :OLD.actor_id, :OLD.producer_id, :OLD.box_office, SYSDATE, 'DELETE');

    INSERT INTO films_history (action_id, film_id, film_date, actor_id, producer_id, box_office, change_date,
                                change_type)
    VALUES (v_id, :OLD.film_id, :OLD.film_date, :OLD.actor_id, :OLD.producer_id, :OLD.box_office, SYSDATE, 'UPDATE');

    INSERT INTO films_history (action_id, film_id, film_date, actor_id, producer_id, box_office, change_date,
                                change_type)
    VALUES (v_id, :NEW.film_id, :NEW.film_date, :NEW.actor_id, :NEW.producer_id, :NEW.box_office, SYSDATE, 'INSERT');
END;

CREATE OR REPLACE TRIGGER tr_films_delete
    AFTER DELETE
    ON films
    FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO films_history (action_id, film_id, film_date, actor_id, producer_id, box_office, change_date,
                                change_type)
    VALUES (history_seq.NEXTVAL, :OLD.film_id, :OLD.film_date, :OLD.actor_id, :OLD.producer_id, :OLD.box_office,
            SYSDATE, 'DELETE');
END;
