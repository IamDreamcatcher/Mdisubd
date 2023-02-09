CREATE TABLE MyTable
(
    id    NUMBER UNIQUE,
    value NUMBER
);
-------------
SELECT *
FROM MyTable;
-----------
DECLARE
    v_id NUMBER := 1;
    v_val NUMBER;
BEGIN
    WHILE v_id <= 10000 LOOP
        v_val := dbms_random.RANDOM();
        INSERT INTO MyTable (id, value)
        VALUES (v_id, v_val);
        v_id := v_id + 1;
    END LOOP;
END;
----------
CREATE OR REPLACE FUNCTION is_even_more_than_odd
    RETURN VARCHAR2
    AS
    even_count NUMBER := 0;
    odd_count NUMBER := 0;
    cur_numb NUMBER := 0;
BEGIN
  FOR i IN (SELECT * FROM MyTable) LOOP
    cur_numb := i.value;
    if MOD(cur_numb, 2) = 0 then
      even_count := even_count + 1;
    else
      odd_count := odd_count + 1;
    end if;
  END LOOP;

  IF even_count > odd_count THEN
    RETURN 'TRUE';
  ELSIF odd_count > even_count THEN
    RETURN 'FALSE';
  ELSE
    RETURN 'EQUAL';
  END IF;
END;
BEGIN
    DBMS_OUTPUT.put_line(is_even_more_than_odd());
END;
-------
CREATE OR REPLACE FUNCTION custom_insert(id NUMBER)
    RETURN VARCHAR2
    AS
    l_id VARCHAR2(15);
    l_val VARCHAR2(15);
BEGIN
    l_id := TO_CHAR(id);
    l_val := TO_CHAR(dbms_random.RANDOM());
    RETURN 'INSERT INTO MyTable (id, value) VALUES (' || l_id || ', ' || l_val || ');';
END;
BEGIN
    DBMS_OUTPUT.put_line(custom_insert(1));
END;
----------
CREATE OR REPLACE PROCEDURE insert_into_mytable(new_id NUMBER, new_value NUMBER) AS
BEGIN
  INSERT INTO MyTable (id, value)
  VALUES (new_id, new_value);
END;
CREATE OR REPLACE PROCEDURE update_mytable(in_id NUMBER, new_value NUMBER) AS
BEGIN
  UPDATE MyTable
  SET value = new_value
  WHERE id = in_id;
END;
CREATE OR REPLACE PROCEDURE delete_from_mytable(in_id NUMBER) AS
BEGIN
  DELETE FROM MyTable
  WHERE id = in_id;
END;
BEGIN
    insert_into_mytable(100000000, 1);
    update_mytable(2, 2);
    delete_from_mytable(3);
END;
------------
CREATE OR REPLACE FUNCTION calculate_total(monthly_salary NUMBER, bonus_percentage NUMBER)
RETURN VARCHAR2
AS
BEGIN
    IF bonus_percentage < 0 OR bonus_percentage > 100  THEN
        RETURN 'Bonus percentage is wrong';
    ELSIF monthly_salary < 0 THEN
        RETURN 'Salary can not be less than zero';
    END IF;

    RETURN TO_CHAR((1 + bonus_percentage / 100) * 12 * monthly_salary);
END;
DECLARE
  monthly_salary NUMBER := 10000;
  bonus_percentage NUMBER := 10;
  result NUMBER;
BEGIN
  result := calculate_total(monthly_salary, bonus_percentage);
  DBMS_OUTPUT.put_line('Result: ' || result);
END;