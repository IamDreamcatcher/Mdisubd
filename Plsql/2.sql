--First one
--Create tables
CREATE TABLE Students(
     id NUMBER,
     name VARCHAR2(100),
     group_id NUMBER
);

CREATE TABLE Groups(
     id NUMBER,
     name VARCHAR2(100),
     students_cnt NUMBER
);
--Testing triggers
DELETE FROM Students where name='Wwwww';
DELETE FROM Groups where id = 1;

INSERT INTO Groups (name, students_cnt) VALUES ('174002', 0);
INSERT INTO Groups (name, students_cnt) VALUES ('231451', 0);

INSERT INTO Students (name, group_id) VALUES ('Qqqqq', 2);
INSERT INTO Students (name, group_id) VALUES ('Eeeeee', 2);
INSERT INTO Students (name, group_id) VALUES ('Wwwww', 2);
INSERT INTO Students (name, group_id) VALUES ('Ssssss', 3);

UPDATE students SET students.group_id=2 WHERE students.id=5;

SELECT * FROM Students;
SELECT * FROM Groups;

--Second one
--Auto-increment key generation
CREATE SEQUENCE group_sequence_id
START WITH 1;

CREATE SEQUENCE student_sequence_id
START WITH 1;
--Triggers
--Trigger for generating group id
CREATE OR REPLACE TRIGGER group_id_generating
BEFORE INSERT ON Groups
FOR EACH ROW
BEGIN
    :new.ID := group_sequence_id.nextval;
END;
--Trigger for generating student id
CREATE OR REPLACE TRIGGER student_id_generating
BEFORE INSERT ON Students
FOR EACH ROW
BEGIN
    :new.ID := student_sequence_id.nextval;
END;
--Trigger for uniqueness check for the group name
CREATE OR REPLACE TRIGGER group_name_uniqueness_check
BEFORE UPDATE OR INSERT ON Groups
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM Groups WHERE name = :new.name;
    IF cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Group name must be unique');
    END IF;
END;
--Trigger for id uniqueness check for the student table
CREATE OR REPLACE TRIGGER student_id_uniqueness_check
BEFORE INSERT ON Students
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM Students WHERE ID = :new.id;
    IF cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'ID for student must be unique');
    END IF;
END;
--Trigger for id uniqueness check for the group table
CREATE OR REPLACE TRIGGER group_id_uniqueness_check
BEFORE INSERT ON Groups
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM Groups WHERE ID = :new.id;
    IF cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'ID group must be unique');
    END IF;
END;

--Third one
--Trigger implementing a Foreign Key with cascading deletion between tables
CREATE OR REPLACE TRIGGER group_foreign_key_trigger
BEFORE DELETE ON Groups
FOR EACH ROW
BEGIN
    DELETE FROM Students s where s.group_id = :old.id;
END;
--Fourth one
--Create table for logging
SELECT * FROM Logging;

CREATE TABLE Logging(
    id NUMBER PRIMARY KEY,
    action VARCHAR2(10),
    logging_time TIMESTAMP,
    st_id_prev NUMBER,
    st_id NUMBER,
    st_name VARCHAR2(100),
    st_group NUMBER
);
--Auto-increment key generation
CREATE SEQUENCE logging_sequence_id
START WITH 1;
--Trigger that implements logging of all actions on the data of the Students table
CREATE OR REPLACE TRIGGER students_logging
AFTER INSERT OR UPDATE OR DELETE ON Students
FOR EACH ROW
DECLARE
    cur_action VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    cur_action := 'INS';
    INSERT INTO Logging (id, action, logging_time, st_id_prev, st_id, st_name, st_group)
        VALUES (logging_sequence_id.nextval, cur_action, CURRENT_TIMESTAMP, null, :new.id, :new.name, :new.group_id);
  ELSIF UPDATING THEN
    cur_action := 'UPD';
    INSERT INTO Logging (id, action, logging_time, st_id_prev, st_id, st_name, st_group)
        VALUES (logging_sequence_id.nextval, cur_action, CURRENT_TIMESTAMP, :old.id, :new.id, :old.name, :old.group_id);
  ELSIF DELETING THEN
    cur_action := 'DEL';
    INSERT INTO Logging (id, action, logging_time, st_id_prev, st_id, st_name, st_group)
        VALUES (logging_sequence_id.nextval, cur_action, CURRENT_TIMESTAMP, :old.id, null, :old.name, :old.group_id);

  END IF;
END;
--Fifth one
--Procedure to restore information for Students
CREATE OR REPLACE PROCEDURE restore_information(ts timestamp, second number) IS
