--Creating dev and prod schemas
alter session set "_ORACLE_SCRIPT"=true;
CREATE USER dev IDENTIFIED BY qwertyu;
CREATE USER prod IDENTIFIED BY qwertyu;
GRANT ALL PRIVILEGES TO dev;
GRANT ALL PRIVILEGES TO prod;

--Creating tables
CREATE TABLE dev.first
(
    id NUMBER not null,
    first VARCHAR2(44) not null,
    CONSTRAINT first_pk PRIMARY KEY (id)
);

CREATE TABLE dev.second
(
    id NUMBER(11) not null,
    second VARCHAR2(44) not null,
    CONSTRAINT second_pk PRIMARY KEY (id)
);

CREATE TABLE prod.first
(
    id NUMBER not null,
    first VARCHAR2(44) not null,
    first2 VARCHAR2(44),
    CONSTRAINT first_pk PRIMARY KEY (id)
);

CREATE TABLE prod.third
(
    id NUMBER not null,
    third VARCHAR2(44) not null,
    CONSTRAINT third_pk PRIMARY KEY (id)
);
--Creating tables with references
CREATE TABLE dev.third_ref
(
    id NUMBER not null,
    third_ref VARCHAR2(44) not null,
    CONSTRAINT third_ref_pk PRIMARY KEY (id)
);

CREATE TABLE dev.second_ref
(
    id NUMBER(11) not null,
    fk_id NUMBER(11) not null,
    second_ref VARCHAR2(44) not null,
    CONSTRAINT second_ref_pk PRIMARY KEY (id),
    CONSTRAINT second_ref_fk FOREIGN KEY (fk_id) REFERENCES dev.third_ref(id)
);

CREATE TABLE dev.first_ref
(
    id NUMBER(11) not null,
    fk_id NUMBER(11) not null,
    first_ref VARCHAR2(44) not null,
    CONSTRAINT first_ref_pk PRIMARY KEY (id),
    CONSTRAINT first_ref_fk FOREIGN KEY (fk_id) REFERENCES dev.second_ref(id)
);
--Creating table with cycle
CREATE TABLE dev.cycled
(
    id NUMBER(11) not null,
    fk_id NUMBER(11) not null,
    CONSTRAINT pk PRIMARY KEY (id),
    CONSTRAINT fk FOREIGN KEY (fk_id) REFERENCES dev.cycled(id)
);
--functions
CREATE OR REPLACE Function dev.func_example(variable in VARCHAR2)
    return NUMBER
    IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
    RETURN 11;
END;

--index
CREATE INDEX dev.index_example
ON dev.first(first);

--procedures
CREATE OR REPLACE PROCEDURE DEV.proc_example_first(variable VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
END;

CREATE OR REPLACE PROCEDURE PROD.proc_example_first(variable VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
END;


CREATE OR REPLACE PROCEDURE DEV.proc_example_second(variable VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
END;

CREATE OR REPLACE PROCEDURE PROD.proc_example_second(variable VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
    DBMS_OUTPUT.PUT_LINE(variable);
END;

CREATE OR REPLACE PROCEDURE DEV.proc_example_third(variable VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
END;

CREATE OR REPLACE PROCEDURE PROD.proc_example_fourth(variable VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(variable);
END;

--data for creating tables in shames
CREATE TABLE ddl_table
(
    table_name VARCHAR2(100),
    ddl_script VARCHAR2(3000),
    type       VARCHAR2(100),
    priority   NUMBER(10) DEFAULT 100000
);

CREATE TABLE fk_table
(
    id     NUMBER,
    child  VARCHAR2(100),
    parent VARCHAR2(100)
);

