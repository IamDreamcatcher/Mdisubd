DECLARE
    INPUT_DATA VARCHAR2(1000) := '<Operation><Type>SELECT</Type><Tables><Table>XMLTEST1</Table><Table>XMLTEST2</Table></Tables><Joins><Join><Type>LEFT JOIN</Type><Condition>XMLTEST1.ID = XMLTEST2.ID</Condition></Join></Joins><Columns><Column>XMLTEST1.ID</Column><Column>XMLTEST2.ID</Column></Columns><Where><Conditions><Condition><Body>XMLTEST1.ID = 1</Body><ConditionOperator>AND</ConditionOperator></Condition><Condition><Body>EXISTS</Body><Operation><Type>SELECT</Type><Tables><Table>XMLTEST1</Table></Tables><Columns><Column>ID</Column></Columns><Where><Conditions><Condition><Body>ID = 1</Body></Condition></Conditions></Where></Operation></Condition></Conditions></Where></Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_OPERATOR((INPUT_DATA)));
END;
DECLARE
    INPUT_DATA VARCHAR2(3000) := '
    <Operation>
        <Type>CREATE</Type>
        <Table>SOME_TABLE</Table>
        <Columns>
            <Column>
                <Name>COL1</Name>
                <Type>NUMBER</Type>
                <Constraints>
                    <Constraint>NOT NULL</Constraint>
                </Constraints>
            </Column>
            <Column>
                <Name>COL2</Name>
                <Type>VARCHAR2(100)</Type>
                <Constraints>
                    <Constraint>NOT NULL</Constraint>
                </Constraints>
            </Column>
        </Columns>
        <TableConstraints>
            <Primary>
                <Columns>
                    <Column>COL2</Column>
                </Columns>
            </Primary>
            <ForeignKey>
                <ChildColumns>
                    <Column>COL1</Column>
                </ChildColumns>
                <Parent>SOME_TABLE2</Parent>
                <ParentColumns>
                    <Column>ID</Column>
                </ParentColumns>
            </ForeignKey>
        </TableConstraints>
    </Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_CREATE(INPUT_DATA));
END;

DECLARE
    INPUT_DATA VARCHAR2(3000) := '
    <Operation>
        <Type>CREATE</Type>
        <Table>T1</Table>
        <Columns>
            <Column>
                <Name>NUM</Name>
                <Type>INT</Type>
            </Column>
            <Column>
                <Name>VAL</Name>
                <Type>VARCHAR2</Type>
            </Column>
        </Columns>
        <TableConstraints>
            <Primary>
                <Columns>
                    <Column>ID</Column>
                </Columns>
            </Primary>
        </TableConstraints>
    </Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_CREATE(INPUT_DATA));
END;

DECLARE
    INPUT_DATA VARCHAR2(3000) := '
    <Operation>
        <Type>DELETE</Type>
        <Table>XMLTEST1</Table>
        <Where>
            <Conditions>
                <Condition>
                    <Body>XMLTEST1.ID = 1</Body>
                    <ConditionOperator>AND</ConditionOperator>
                </Condition>
                <Condition>
                    <Body>EXISTS</Body>
                    <Operation>
                        <Type>SELECT</Type>
                        <Tables>
                            <Table>XMLTEST1</Table>
                        </Tables>
                        <Columns>
                            <Column>ID</Column>
                        </Columns>
                        <Where>
                            <Conditions>
                                <Condition>
                                    <Body>ID = 1</Body>
                                </Condition>
                            </Conditions>
                        </Where>
                    </Operation>
                </Condition>
            </Conditions>
        </Where>
    </Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_DELETE(INPUT_DATA));
END;

DECLARE
    INPUT_DATA VARCHAR2(3000) := '<Operation><Type>DROP</Type><Table>XMLTEST1</Table></Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_DROP(INPUT_DATA));
END;

DECLARE
    INPUT_DATA VARCHAR2(3000) := '<Operation>
    <Type>INSERT</Type>
    <Table>Table1</Table>
    <Columns>
        <Column>XMLTEST2.ID</Column>
    </Columns>
    <Operation>
        <Type>SELECT</Type>
        <Tables>
            <Table>XMLTEST1</Table>
        </Tables>
        <Columns>
            <Column>ID</Column>
        </Columns>
        <Where>
            <Conditions>
                <Condition>
                    <Body>ID = 1</Body>
                </Condition>
            </Conditions>
        </Where>
    </Operation>
</Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_INSERT(INPUT_DATA));
END;
DECLARE
    INPUT_DATA VARCHAR2(3000) := '
    <Operation>
        <Type>UPDATE</Type>
        <Table>XMLTEST1</Table>
        <SetOperations>
            <Set>col1 = 1</Set>
        </SetOperations>
        <Where>
            <Conditions>
                <Condition>
                    <Body>XMLTEST1.ID = 1</Body>
                    <ConditionOperator>AND</ConditionOperator>
                </Condition>
                <Condition>
                    <Body>EXISTS</Body>
                    <Operation>
                        <Type>SELECT</Type>
                        <Tables>
                            <Table>XMLTEST1</Table>
                        </Tables>
                        <Columns>
                            <Column>ID</Column>
                        </Columns>
                        <Where>
                            <Conditions>
                                <Condition>
                                    <Body>ID = 1</Body>
                                </Condition>
                            </Conditions>
                        </Where>
                    </Operation>
                </Condition>
            </Conditions>
        </Where>
    </Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_UPDATE((INPUT_DATA)));
END;

DECLARE
    INPUT_DATA VARCHAR2(3000) := '<Operation>
    <Type>SELECT</Type>
    <Tables>
        <Table>T1</Table>
    </Tables>
    <Columns>
        <Column>*</Column>
    </Columns>
    <Where>
        <Conditions>
            <Condition>
                <Body>T1.ID IN</Body>
                <Operation>
                    <Type>SELECT</Type>
                    <Tables>
                        <Table>T2</Table>
                    </Tables>
                    <Columns>
                        <Column>ID</Column>
                    </Columns>
                    <Where>
                        <Conditions>
                            <Condition>
                                <Body>VAl LIKE ''%a%''</Body>
                                <Operator>AND</Operator>
                            </Condition>
                            <Condition>
                                <Body>T2.NUMB BETWEEN 2 AND 4</Body>
                            </Condition>
                        </Conditions>
                    </Where>
                </Operation>
            </Condition>
        </Conditions>
    </Where>
</Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(XML_PARSING.HANDLER_OPERATOR(INPUT_DATA));
END;

SELECT * FROM T1 WHERE T1.ID IN
(SELECT ID FROM T2 WHERE
    VAl LIKE '%a%' AND T2.NUMB BETWEEN 2 AND 4)