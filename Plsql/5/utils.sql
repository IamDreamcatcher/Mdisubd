create or replace procedure rollback_by_date(date_time in timestamp)
as
begin
    disable_all_constraints('films');
    disable_all_constraints('actors');
    disable_all_constraints('producers');

    delete from films;
    delete from actors;
    delete from producers;

    for i in (select * from actors_history where CHANGE_DATE <= date_time order BY ACTION_ID)
        LOOP
            if i.CHANGE_TYPE = 'INSERT' then
                insert into actors values (i.actor_ID, i.FIRST_NAME, i.LAST_NAME, i.EMAIL, i.PHONE_NUMBER);
            elsif i.CHANGE_TYPE = 'DELETE' then
                delete from actors where actor_ID = i.actor_ID;
            end if;
        end loop;

    for i in (select * from producers_history where CHANGE_DATE <= date_time order BY ACTION_ID)
        LOOP
            if i.CHANGE_TYPE = 'INSERT' then
                insert into producers values (i.producer_ID, i.producer_NAME, i.filmography, i.age);
            elsif i.CHANGE_TYPE = 'DELETE' then
                delete from producers where producer_ID = i.producer_ID;
            end if;
        end loop;

    for i in (select * from films_history where CHANGE_DATE <= date_time order BY ACTION_ID)
        LOOP
            if i.CHANGE_TYPE = 'INSERT' then
                insert into films values (i.film_ID, i.film_DATE, i.actor_ID, i.producer_ID, i.box_office);
            elsif i.CHANGE_TYPE = 'DELETE' then
                delete from films where films.film_ID = i.film_ID;
            end if;
            commit;
        end loop;

    delete
    from actors_history
    where CHANGE_DATE > date_time;

    delete
    from producers_history
    where CHANGE_DATE > date_time;

    delete
    from films_history
    where CHANGE_DATE > date_time;

    enable_all_constraints('actors');
    enable_all_constraints('producers');
    enable_all_constraints('films');
end;

CREATE OR REPLACE PROCEDURE disable_all_constraints(p_table_name IN VARCHAR2) IS
BEGIN
    FOR c IN (SELECT constraint_name
              FROM user_constraints
              WHERE table_name = p_table_name)
        LOOP
            EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table_name || ' DISABLE CONSTRAINT ' || c.constraint_name;
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || p_table_name || ' DISABLE CONSTRAINT ' || c.constraint_name);
        END LOOP;

    EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table_name || ' DISABLE ALL TRIGGERS';
END;

CREATE OR REPLACE PROCEDURE enable_all_constraints(p_table_name IN VARCHAR2) IS
BEGIN
    FOR c IN (SELECT constraint_name
              FROM user_constraints
              WHERE table_name = p_table_name)
        LOOP
            EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table_name || ' ENABLE CONSTRAINT ' || c.constraint_name;
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || p_table_name || ' ENABLE CONSTRAINT ' || c.constraint_name);
        END LOOP;

    EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table_name || ' ENABLE ALL TRIGGERS';
END;
