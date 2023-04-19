CREATE OR REPLACE PROCEDURE GET_SCRIPT(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE DDL_TABLE';
    CREATING_TABLES(dev_schema_name, prod_schema_name);
    DELETING_TABLES(dev_schema_name, prod_schema_name);
    GET_TABLES_ORDER(dev_schema_name);

    FOR script IN (SELECT DDL_SCRIPT
                   FROM DDL_TABLE
                   ORDER BY PRIORITY desc )
        LOOP
        DBMS_OUTPUT.PUT_LINE(script.DDL_SCRIPT);
        END LOOP;

    CREATING_PROCEDURES(dev_schema_name, prod_schema_name);
    DELETING_PROCEDURES(dev_schema_name, prod_schema_name);
    UPDATING_PROCEDURES(dev_schema_name, prod_schema_name);
    CREATING_FUNCTIONS(dev_schema_name, prod_schema_name);
    DELETING_FUNCTIONS(dev_schema_name, prod_schema_name);
    UPDATING_FUNCTIONS(dev_schema_name, prod_schema_name);
END;


CALL GET_SCRIPT('DEV', 'PROD');