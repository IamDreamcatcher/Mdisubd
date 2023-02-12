CREATE TABLE MyTable
(
    id    NUMBER UNIQUE,
    value NUMBER
);

SELECT *
FROM MyTable;

DROP TABLE MyTable;

DECLARE
    cur_id NUMBER := 1;
    cur_val NUMBER;
BEGIN
    WHILE cur_id <= 10 LOOP
        cur_val := dbms_random.RANDOM();
        INSERT INTO MyTable (id, value)
        VALUES (cur_id, cur_val);
        cur_id := cur_id + 1;
    END LOOP;
END;

CREATE OR REPLACE FUNCTION is_even_more_than_odd
    RETURN VARCHAR2
    IS
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
--insert has been changed
CREATE OR REPLACE FUNCTION custom_insert(in_id NUMBER)
    RETURN VARCHAR2
    IS
    out_id VARCHAR2(15);
    out_val VARCHAR2(15);
BEGIN
    FOR i in (SELECT * FROM MyTable WHERE id = in_id) LOOP
        out_id := TO_CHAR(i.id);
        out_val := TO_CHAR(i.value);
        RETURN 'INSERT INTO MyTable (id, value) VALUES (' || out_id || ', ' || out_val || ');';
    end loop;
    RETURN 'Id not exists';
END;
BEGIN
    DBMS_OUTPUT.put_line(custom_insert(-300));
END;

CREATE OR REPLACE PROCEDURE insert_into_mytable(new_id NUMBER, new_value NUMBER) IS
BEGIN
  INSERT INTO MyTable (id, value)
  VALUES (new_id, new_value);
END;
CREATE OR REPLACE PROCEDURE update_mytable(in_id NUMBER, new_value NUMBER) IS
BEGIN
  UPDATE MyTable
  SET value = new_value
  WHERE id = in_id;
END;
CREATE OR REPLACE PROCEDURE delete_from_mytable(in_id NUMBER) IS
BEGIN
  DELETE FROM MyTable
  WHERE id = in_id;
END;
BEGIN
    insert_into_mytable(100000000, 1);
    update_mytable(2, 2);
    delete_from_mytable(3);
END;

CREATE OR REPLACE FUNCTION calculate_total(monthly_salary NUMBER, bonus_percentage NUMBER)
RETURN VARCHAR2
IS
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
  EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.put_line('Invalid input');
END;