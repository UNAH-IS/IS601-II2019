CREATE OR REPLACE PROCEDURE P_HOLA_MUNDO(P_NOMBRE VARCHAR2, P_APELLIDO VARCHAR2) AS
    ---DECLARACION DE VARIABLES
BEGIN
    --CUERPO DEL PROCEDIMIENTO
    DBMS_OUTPUT.PUT_LINE(P_NOMBRE||' '||P_APELLIDO);
END P_HOLA_MUNDO;


call p_hola_mundo('Pedro', 'Martinez');

execute p_hola_mundo('Pedro', 'Martinez');


begin
    p_hola_mundo('Pedro', 'Martinez');
end;