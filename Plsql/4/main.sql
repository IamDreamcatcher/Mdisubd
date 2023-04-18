DROP TYPE XMLRecord;
CREATE TYPE XMLRecord IS TABLE OF VARCHAR2(1000);

CREATE OR REPLACE FUNCTION get_value_from_xml(xml_string IN VARCHAR2, xpath IN VARCHAR2)
    RETURN XMLRecord AS
    records_length NUMBER := 0; current_record VARCHAR2(50) := ' '; xml_property XMLRecord := XMLRecord(); i NUMBER := 1;
BEGIN
    SELECT EXTRACTVALUE(XMLTYPE(xml_string), xpath || '[' || i || ']') INTO current_record FROM dual;
    WHILE current_record IS NOT NULL
        LOOP
            i := i + 1;
            records_length := records_length + 1; xml_property.extend;
            xml_property(records_length) := REPLACE(TRIM(current_record), ' ', '');
            SELECT EXTRACTVALUE(XMLTYPE(xml_string), xpath || '[' || i || ']') INTO current_record FROM dual;
        END LOOP;
    return xml_property;
end get_value_from_xml;

CREATE OR REPLACE PACKAGE xml_package AS
    FUNCTION process_select(xml_string IN varchar2) RETURN sys_refcursor;
    FUNCTION xml_select(xml_string in varchar2) RETURN varchar2;
    FUNCTION where_property(xml_string in varchar2) RETURN varchar2;
END xml_package;
/
CREATE OR REPLACE PACKAGE BODY xml_package AS
    FUNCTION process_select(xml_string IN varchar2) RETURN sys_refcursor
    AS
        cur sys_refcursor;
    BEGIN
        OPEN cur FOR xml_select(xml_string); RETURN cur;
    END process_select;


    FUNCTION xml_select(xml_string in varchar2) RETURN varchar2
    AS
        tables_list  XMLRecord      := XMLRecord(); columns_list XMLRecord := XMLRecord(); filters XMLRecord := XMLRecord(); join_type VARCHAR2(100); join_condition VARCHAR2(100);
        select_query VARCHAR2(1000) := 'SELECT';
    BEGIN
        IF xml_string IS NULL THEN
            RETURN NULL;
        END IF;


        tables_list := get_value_from_xml(xml_string, 'Operation/Tables/Table');
        columns_list := get_value_from_xml(xml_string, 'Operation/OutputColumns/Column');

        select_query := select_query || ' ' || columns_list(1);
        FOR col_index IN 2..columns_list.count
            LOOP
                select_query := select_query || ', ' || columns_list(col_index);
            END LOOP;

        select_query := select_query || ' FROM ' || tables_list(1);
        FOR indx IN 2..tables_list.count
            LOOP
                SELECT EXTRACTVALUE(XMLTYPE(xml_string), 'Operation/Joins/Join' || '[' || (indx
                    - 1) || ']/Type')
                INTO join_type
                FROM dual;
                SELECT EXTRACTVALUE(XMLTYPE(xml_string), 'Operation/Joins/Join' || '[' || (indx
                    - 1) || ']/Condition')
                INTO join_condition
                FROM dual;
                select_query :=
                            select_query || ' ' || join_type || ' ' || tables_list(indx) || ' ON ' || join_condition;
            END LOOP;


        select_query := select_query || where_property(xml_string); dbms_output.put_line(select_query);
        RETURN select_query;
    END xml_select;

    FUNCTION where_property(xml_string in varchar2) RETURN varchar2 AS
        where_filters XMLRecord                                                                                                                      := XMLRecord(); where_clouse VARCHAR2(1000) := ' WHERE'; condition_body VARCHAR2(100);
        sub_query     VARCHAR(1000); sub_query1 VARCHAR(1000); condition_operator VARCHAR(100); current_record VARCHAR2(1000); records_length NUMBER := 0;
        i             NUMBER                                                                                                                         := 0;
    BEGIN
        SELECT EXTRACT(XMLTYPE(xml_string),
                       'Operation/Where/Conditions/Condition').getStringVal()
        INTO current_record
        FROM dual;

        WHILE current_record IS NOT NULL
            LOOP
                i := i + 1;
                records_length := records_length + 1; where_filters.extend;
                where_filters(records_length) := TRIM(current_record);
                SELECT EXTRACT(XMLTYPE(xml_string), 'Operation/Where/Conditions/Condition'
                    || '[' || i || ']').getStringVal()
                INTO current_record
                FROM dual;
            END LOOP;

        FOR i IN 2..where_filters.count
            LOOP
                SELECT EXTRACTVALUE(XMLTYPE(where_filters(i)), 'Condition/Body') INTO condition_body FROM dual;
                SELECT EXTRACT(XMLTYPE(where_filters(i)), 'Condition/Operation').getStringVal()
                INTO sub_query
                FROM dual;
                SELECT EXTRACTVALUE(XMLTYPE(where_filters(i)), 'Condition/ConditionOperator')
                INTO condition_operator
                FROM dual;
                sub_query1 := xml_select(sub_query);


                IF sub_query1 IS NOT NULL THEN
                    sub_query1 := '(' || sub_query1 || ')';
                END IF;
                where_clouse := where_clouse || ' ' || TRIM(condition_body) || ' ' || sub_query1 ||
                                TRIM(condition_operator) || ' ';
            END LOOP;


        IF where_filters.count = 0 THEN
            return ' ';
        ELSE
            return where_clouse;
        END IF;
    END where_property;
END xml_package;


DECLARE
    cur sys_refcursor;
BEGIN
    cur := xml_package.process_select('<Operation>
<QueryType> SELECT
</QueryType>
<OutputColumns>
<Column>students.id</Column>
<Column>students.name</Column>
<Column>groups.id</Column>
</OutputColumns>
<Tables>
<Table>students</Table>
<Table>groups</Table>
</Tables>
<Joins>
<Join>
<Type>LEFT JOIN</Type>
<Condition>groups.id = students.group_id</Condition>
</Join>
</Joins>
<Where>
<Conditions>
<Body>students.id = 5</Body>
</Conditions>
</Where>
</Operation>');
END;