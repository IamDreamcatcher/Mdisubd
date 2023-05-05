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


CREATE OR REPLACE DIRECTORY my_dir AS 'D:\';

create or replace procedure create_report(t_begin in timestamp, t_end in timestamp)
as
    v_result varchar2(4000);
    i_count  number;
    u_count  number;
    d_count  number;
    my_file  UTL_FILE.FILE_TYPE;
begin
    v_result :=
    '<!DOCTYPE html>
    <html>
    <head>
        <title>Database Changes</title>
        <style type="text/css">
            h1 {
                font-size: 24px;
                font-weight: bold;
                margin-top: 20px;
                margin-bottom: 10px;
                text-align: center;
                text-transform: uppercase;
            }
            h2 {
                font-size: 18px;
                margin-top: 5px;
                text-align: center;
                margin-bottom: 5px;
            }
            .magenta {
                color: magenta;
            }
            .darkorange {
                color: darkorange;
            }
        </style>
    </head>
    <body>';
    v_result := v_result || '<h1 class = "darkorange">Table Actors:</h1>' || CHR(10);

    select count(*)
    into u_count
    from actors_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'UPDATE';

    select count(*)
    into i_count
    from actors_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'INSERT';

    select count(*)
    into d_count
    from actors_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'DELETE';

    i_count := i_count - u_count;
    d_count := d_count - u_count;

    v_result := v_result || '<h2 class="magenta">   Insert operations amount: ' || i_count || '</h2>' || CHR(10) ||
                '<h2 class="magenta">   Update operations amount: ' || u_count || '</h2>' || CHR(10) ||
                '<h2 class="magenta">   Delete operations amount: ' || d_count || '</h2>' || CHR(10);

    select count(*)
    into u_count
    from producers_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'UPDATE';

    select count(*)
    into i_count
    from producers_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'INSERT';

    select count(*)
    into d_count
    from producers_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'DELETE';

    i_count := i_count - u_count;
    d_count := d_count - u_count;

    v_result := v_result || '<h1 class="darkorange">Table Producers:</h1>' || CHR(10) ||
                '<h2 class="magenta">   Insert operations amount: ' || i_count || '</h2>' || CHR(10) ||
                '<h2 class="magenta">  Update operations amount: ' || u_count || '</h2>' || CHR(10) ||
                '<h2 class="magenta">   Delete operations amount: ' || d_count || '</h2>' || CHR(10);

    select count(*)
    into u_count
    from films_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'UPDATE';

    select count(*)
    into i_count
    from films_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'INSERT';

    select count(*)
    into d_count
    from films_history
    where CHANGE_DATE between t_begin and t_end
      and CHANGE_TYPE = 'DELETE';

    i_count := i_count - u_count;
    d_count := d_count - u_count;

    v_result := v_result || '<h1 class="darkorange">Table films:</h1>' || CHR(10) ||
                '<h2 class="magenta">  Insert operations amount: ' || i_count || '</h2>' || CHR(10) ||
                '<h2 class="magenta">   Update operations amount: ' || u_count || '</h2>' || CHR(10) ||
                '<h2 class="magenta">   Delete operations amount: ' || d_count || '</h2>' || CHR(10);
    v_result := v_result || '</body></html>';
    my_file := UTL_FILE.FOPEN('MY_DIR', 'report.html', 'w');
    UTL_FILE.PUT_LINE(my_file, v_result);
    UTL_FILE.FCLOSE(my_file);
    DBMS_OUTPUT.PUT_LINE(v_result);

end;