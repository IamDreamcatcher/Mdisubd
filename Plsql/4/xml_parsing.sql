CREATE OR REPLACE PACKAGE XML_PARSING AS
    FUNCTION HANDLER_WHERE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_OPERATOR(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_SELECT(XML_STRING IN VARCHAR2) RETURN SYS_REFCURSOR;
    FUNCTION HANDLER_INSERT(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_UPDATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_DELETE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_CREATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_DROP(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION HANDLER_AUTO_INCREMENT(TABLE_NAME IN VARCHAR2) RETURN VARCHAR2;
END XML_PARSING;

CREATE OR REPLACE PACKAGE BODY XML_PARSING AS
    FUNCTION HANDLER_OPERATOR(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        TABLES_LIST    XML_DATA := XML_DATA();
        IN_COLUMNS     XML_DATA := XML_DATA();
        JOIN_CONDITION VARCHAR2(100);
        JOIN_TYPE      VARCHAR2(100);
        SELECT_QUERY   CLOB := 'SELECT ';

        FUNCTION GET_COLUMN_LIST(in_columns IN XML_DATA) RETURN CLOB IS
            result CLOB := '';

            BEGIN
                FOR indx IN 1..in_columns.COUNT
                LOOP
                    result := result || in_columns(indx) || ', ';
                END LOOP;

                result := RTRIM(result, ', ');
                RETURN result;
            END GET_COLUMN_LIST;

    BEGIN
        IF XML_STRING IS NULL THEN
            RETURN NULL;
        END IF;

        TABLES_LIST := EXTRACT_VALUES(XML_STRING, 'Operation/Tables/Table');
        IN_COLUMNS := EXTRACT_VALUES(XML_STRING, 'Operation/Columns/Column');

        SELECT_QUERY := SELECT_QUERY || GET_COLUMN_LIST(IN_COLUMNS);
        SELECT_QUERY := SELECT_QUERY || ' FROM ' || TABLES_LIST(1);

        FOR indx IN 2..TABLES_LIST.COUNT
        LOOP
            JOIN_TYPE := EXTRACTVALUE(XMLTYPE(XML_STRING),
                                      'Operation/Joins/Join[' || (indx - 1) || ']/Type');
            JOIN_CONDITION := EXTRACTVALUE(XMLTYPE(XML_STRING),
                                           'Operation/Joins/Join[' || (indx - 1) || ']/Condition');
            SELECT_QUERY := SELECT_QUERY || ' ' || JOIN_TYPE || ' ' || TABLES_LIST(indx) || ' ON ' || JOIN_CONDITION;
        END LOOP;

        SELECT_QUERY := SELECT_QUERY || HANDLER_WHERE(XML_STRING);

        RETURN SELECT_QUERY;
    END HANDLER_OPERATOR;


    FUNCTION HANDLER_WHERE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        WHERE_FILTER        XML_DATA       := XML_DATA();
        WHERE_CLAUSE        VARCHAR2(1000) := ' WHERE ';
        I                   NUMBER         := 1;
    BEGIN
        WHERE_FILTER := EXTRACT_WITH_SUBNODES(XML_STRING, 'Operation/Where/Conditions/Condition');

        FOR I IN 1..WHERE_FILTER.COUNT LOOP
            WHERE_CLAUSE := WHERE_CLAUSE || TRIM(EXTRACTVALUE(WHERE_FILTER(I), '/Condition/Body')) || ' '
                || TRIM(EXTRACTVALUE(WHERE_FILTER(I), '/Condition/Operator')) || ' ';

            IF (EXISTSNODE(WHERE_FILTER(I), '/Condition/Arguments/Argument')) THEN
                WHERE_CLAUSE := WHERE_CLAUSE || '(';

                FOR ARGUMENT IN (
                    SELECT EXTRACTVALUE(VALUE(arg), '.')
                    FROM TABLE(XMLSEQUENCE(EXTRACT(WHERE_FILTER(I), '/Condition/Arguments/Argument'))) arg
                ) LOOP
                    WHERE_CLAUSE := WHERE_CLAUSE || ARGUMENT || ', ';
                END LOOP;

                WHERE_CLAUSE := TRIM(TRAILING ', ' FROM WHERE_CLAUSE) || ') ';
            END IF;

            IF (EXISTSNODE(WHERE_FILTER(I), '/Condition/Operation')) THEN
                WHERE_CLAUSE := WHERE_CLAUSE || HANDLER_OPERATOR(EXTRACTVALUE(WHERE_FILTER(I), '/Condition/Operation')) || ' ';
            END IF;

            IF (EXISTSNODE(WHERE_FILTER(I), '/Condition/Separator')) THEN
                WHERE_CLAUSE := WHERE_CLAUSE || TRIM(EXTRACTVALUE(WHERE_FILTER(I), '/Condition/Separator')) || ' ';
            END IF;
        END LOOP;

        IF WHERE_FILTER.COUNT = 0 THEN
            RETURN ' ';
        END IF;

        RETURN WHERE_CLAUSE;
    END HANDLER_WHERE;



    FUNCTION HANDLER_SELECT(XML_STRING IN VARCHAR2) RETURN SYS_REFCURSOR IS
        RF_CUR SYS_REFCURSOR;
    BEGIN
        OPEN RF_CUR FOR HANDLER_OPERATOR(XML_STRING);
        RETURN RF_CUR;
    END;


    FUNCTION HANDLER_INSERT(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        VALUES_TO_INSERT       VARCHAR2(1000);
        SELECT_QUERY_TO_INSERT VARCHAR2(1000);
        XML_VALUES             XML_DATA := XML_DATA();
        INSERT_QUERY           VARCHAR2(1000);
        TABLE_NAME             VARCHAR2(100);
        XML_COLUMNS            VARCHAR2(200);
    BEGIN
        SELECT EXTRACT(XMLTYPE(XML_STRING), 'Operation/Values').GETSTRINGVAL()
        INTO VALUES_TO_INSERT
        FROM DUAL;

        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING), 'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;

        XML_COLUMNS := '(' || CONCAT_STRING(EXTRACT_VALUES(XML_STRING, 'Operation/Columns/Column'), ',') || ')';

        INSERT_QUERY := 'INSERT INTO ' || TABLE_NAME || XML_COLUMNS;

        IF VALUES_TO_INSERT IS NOT NULL THEN
            XML_VALUES := EXTRACT_VALUES(VALUES_TO_INSERT, 'Values/Value');
            INSERT_QUERY := INSERT_QUERY || ' VALUES (';

            FOR I IN 1..XML_VALUES.COUNT LOOP
                IF I > 1 THEN
                    INSERT_QUERY := INSERT_QUERY || ', ';
                END IF;
                INSERT_QUERY := INSERT_QUERY || XML_VALUES(I);
            END LOOP;

            INSERT_QUERY := INSERT_QUERY || ')';

        ELSE
            SELECT EXTRACT(XMLTYPE(XML_STRING), 'Operation/Operation').GETSTRINGVAL()
            INTO SELECT_QUERY_TO_INSERT
            FROM DUAL;
            INSERT_QUERY := INSERT_QUERY || HANDLER_OPERATOR(SELECT_QUERY_TO_INSERT);
        END IF;

        RETURN INSERT_QUERY;
    END;


    FUNCTION HANDLER_UPDATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        SET_COLLECTION     XML_DATA       := XML_DATA();
        SET_OPERATIONS     VARCHAR2(1000);
        UPDATE_QUERY       VARCHAR2(1000) := 'UPDATE ';
        TABLE_NAME         VARCHAR2(100);
    BEGIN
        SELECT EXTRACT(XMLTYPE(XML_STRING),
                       'Operation/SetOperations').GETSTRINGVAL()
        INTO SET_OPERATIONS
        FROM DUAL;
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING),
                            'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;
        SET_COLLECTION := EXTRACT_VALUES(SET_OPERATIONS, 'SetOperations/Set');
        UPDATE_QUERY := UPDATE_QUERY
            || TABLE_NAME
            || ' SET '
            || SET_COLLECTION(1);
        FOR I IN 2..SET_COLLECTION.COUNT
            LOOP
                UPDATE_QUERY := UPDATE_QUERY
                    || ','
                    || SET_COLLECTION(I);
            END LOOP;
        UPDATE_QUERY := UPDATE_QUERY
            || HANDLER_WHERE(XML_STRING);
        RETURN UPDATE_QUERY;
    END;

    FUNCTION HANDLER_DELETE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        DELETE_QUERY       VARCHAR2(1000) := 'DELETE FROM ';
        TABLE_NAME         VARCHAR2(100);
    BEGIN
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING),
                            'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;
        DELETE_QUERY := DELETE_QUERY || TABLE_NAME || HANDLER_WHERE(XML_STRING);
        RETURN DELETE_QUERY;
    END;

    FUNCTION HANDLER_CREATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        TABLE_COLUMNS         XML_DATA       := XML_DATA();
        TABLE_NAME            VARCHAR2(100);
        COL_CONSTRAINTS       XML_DATA       := XML_DATA();
        TABLE_CONSTRAINTS     XML_DATA       := XML_DATA();
        COL_NAME              VARCHAR2(100);
        COL_TYPE              VARCHAR2(100);
        PARENT_TABLE          VARCHAR2(100);
        CREATE_QUERY          VARCHAR2(1000) := 'CREATE TABLE ';
        PRIMARY_CONSTRAINT    VARCHAR2(1000);
        AUTO_INCREMENT_SCRIPT VARCHAR2(1000);
    BEGIN
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING),
                            'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;
        CREATE_QUERY := CREATE_QUERY
            || TABLE_NAME
            || '(';
        TABLE_COLUMNS := EXTRACT_WITH_SUBNODES(XML_STRING, 'Operation/Columns/Column');
        FOR I IN 1 .. TABLE_COLUMNS.COUNT
            LOOP
                SELECT EXTRACTVALUE(XMLTYPE(TABLE_COLUMNS(I)),
                                    'Column/Name')
                INTO COL_NAME
                FROM DUAL;
                SELECT EXTRACTVALUE(XMLTYPE(TABLE_COLUMNS(I)),
                                    'Column/Type')
                INTO COL_TYPE
                FROM DUAL;
                COL_CONSTRAINTS := EXTRACT_VALUES(TABLE_COLUMNS(I), 'Column/Constraints/Constraint');
                CREATE_QUERY := CREATE_QUERY
                    || ' '
                    || COL_NAME
                    || ' '
                    || COL_TYPE
                    || ' '
                    || CONCAT_STRING(COL_CONSTRAINTS, '
            ');
                IF I != TABLE_COLUMNS.COUNT THEN
                    CREATE_QUERY := CREATE_QUERY
                        || ' , ';
                END IF;
            END LOOP;
        SELECT EXTRACT(XMLTYPE(XML_STRING),
                       'Operation/TableConstraints/PrimaryKey').GETSTRINGVAL()
        INTO PRIMARY_CONSTRAINT
        FROM DUAL;

        IF PRIMARY_CONSTRAINT IS NOT NULL THEN
            CREATE_QUERY := CREATE_QUERY
                || 'Constraint'
                || TABLE_NAME
                || '_pk PRIMARY KEY ('
                || CONCAT_STRING(EXTRACT_VALUES(PRIMARY_CONSTRAINT, 'PrimaryKey/Columns/Column'), ',')
                || ')';
        ELSE
            AUTO_INCREMENT_SCRIPT := HANDLER_AUTO_INCREMENT(TABLE_NAME);
            CREATE_QUERY := CREATE_QUERY
                || ', ID NUMBER PRIMARY KEY';
        END IF;

        TABLE_CONSTRAINTS := EXTRACT_WITH_SUBNODES(XML_STRING, 'Operation/TableConstraints/ForeignKey');
        FOR I IN 1 .. TABLE_CONSTRAINTS.COUNT
            LOOP
                SELECT EXTRACTVALUE(XMLTYPE(TABLE_CONSTRAINTS(I)),
                                    'ForeignKey/Parent')
                INTO PARENT_TABLE
                FROM DUAL;
                CREATE_QUERY := CREATE_QUERY
                    || ' , CONSTRAINT '
                    || TABLE_NAME
                    || '_'
                    || PARENT_TABLE
                    || '_fk Foreign Key ('
                    || CONCAT_STRING(EXTRACT_VALUES(TABLE_CONSTRAINTS(I), 'ForeignKey/ChildColumns/Column'), ' , ')
                    || ' ) '
                    || 'REFERENCES '
                    || PARENT_TABLE
                    || '('
                    || CONCAT_STRING(EXTRACT_VALUES(TABLE_CONSTRAINTS(I), 'ForeignKey/ChildColumns/Column'), ' , ')
                    || ')';
            END LOOP;
        CREATE_QUERY := CREATE_QUERY
            || ');'
            || AUTO_INCREMENT_SCRIPT;
        RETURN CREATE_QUERY;
    END;

    FUNCTION HANDLER_DROP(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        DROP_QUERY VARCHAR2(1000) := 'DROP TABLE ';
        TABLE_NAME VARCHAR2(100);
    BEGIN
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING),
                            'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;
        DROP_QUERY := DROP_QUERY
            || TABLE_NAME;
        RETURN DROP_QUERY;
    END;

    FUNCTION HANDLER_AUTO_INCREMENT(TABLE_NAME IN VARCHAR2) RETURN VARCHAR2 IS
        AUTO_INCREMENT_SCRIPT VARCHAR(1000);
    BEGIN
        AUTO_INCREMENT_SCRIPT := 'CREATE SEQUENCE '
            || TABLE_NAME
            || '_pk_seq'
            || '; ';
        AUTO_INCREMENT_SCRIPT := AUTO_INCREMENT_SCRIPT
            || 'CREATE OR REPLACE TRIGGER '
            || TABLE_NAME
            || ' BEFORE INSERT ON '
            || TABLE_NAME
            || ' FOR EACH '
            || 'ROW BEGIN'
            || ' IF INSERTING THEN '
            || ' SELECT '
            || TABLE_NAME
            || '_pk_seq'
            || '.NEXTVAL INTO :NEW."ID" FROM DUAL;'
            || ' END IF;'
            || 'END';
        RETURN AUTO_INCREMENT_SCRIPT;
    END;
END XML_PARSING;
