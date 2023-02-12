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
DELETE FROM Students;
DELETE FROM Groups where id = 1;

INSERT INTO Groups (name, students_cnt) VALUES ('174002', 0);
INSERT INTO Groups (name, students_cnt) VALUES ('231451', 0);

INSERT INTO Students (name, group_id) VALUES ('Qqqqq', 2);
INSERT INTO Students (name, group_id) VALUES ('Eeeeee', 2);
INSERT INTO Students (name, group_id) VALUES ('Wwwww', 2);
INSERT INTO Students (name, group_id) VALUES ('Ssssss', 1);

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
BEFORE UPDATE OR INSERT ON Students
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
BEFORE UPDATE OR INSERT ON Groups
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
