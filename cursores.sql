drop table tmp;

create table tmp (
  valor integer
)


DECLARE
  V_Contador INTEGER:=1;
BEGIN
  LOOP
    INSERT INTO tmp(valor)
    VALUES (V_Contador);
    V_Contador:=V_Contador +1;
    EXIT WHEN V_Contador =1000000;
  END LOOP;
  commit;
END;


select *
from tmp
order by valor;


rollback;

truncate table tmp;



DECLARE
  V_Contador BINARY_INTEGER:=1;
BEGIN
  WHILE V_Contador <11 LOOP
    INSERT INTO tmp (Valor)
    VALUES (V_Contador);
    V_Contador:=V_Contador +1;
  END LOOP;
END;

select *
from tmp;


rollback;

BEGIN
  FOR V_Contador IN reverse 1..10 LOOP
    INSERT INTO tmp (Valor)
    VALUES (V_Contador);
  END LOOP;
END;



BEGIN
  DBMS_OUTPUT.PUT_LINE('Esto es un ejemplo.');
  GOTO Etiqueta_1;
  DBMS_OUTPUT.PUT_LINE('No hace el GOTO.');
  <<Etiqueta_1>>
  DBMS_OUTPUT.PUT_LINE('Entra en el GOTO');
END;


--No se puede saltar con GOTO al interior de otro bloque
begin
  GOTO etiqueta1;
  begin
    dbms_output.put_line('Bloque interno 1');
  end;
  begin
    <<etiqueta1>>
    dbms_output.put_line('Bloque interno 2');
  end;
end;


--No se puede saltar con GOTO al interior de un bucle
begin
  GOTO etiqueta1;

  ----

  WHILE condicion LOOP
    ----
    ---
    <<etiqueta1>>
  end loop;
end;


--No se puede saltar con GOTO al interior de un IF`
begin
  GOTO etiqueta1;

  ----

  if condicion then
    ----
    ---
    <<etiqueta1>>
  end if;
end;


begin
  <<ETIQUETAX>>
  dbms_output.put_line('hola mundo');
  GOTO ETIQUETAX;
end;


declare
  v_registro hr.employees%ROWTYPE;
  CURSOR c_empleados IS SELECT * FROM HR.EMPLOYEES;
begin
  open c_empleados; --Ejecuta la consulta y almacena el resultado en memoria
  loop
    FETCH c_empleados into v_registro;
    exit when c_empleados%notfound;
    dbms_output.put_line('NOMBRE: ' || v_registro.FIRST_NAME);
  end loop;
  close c_empleados;
end;




create table EMPLOYEES_COPY
(
	EMPLOYEE_ID NUMBER(6) not null,
	FIRST_NAME VARCHAR2(20),
	LAST_NAME VARCHAR2(25) not null,
	EMAIL VARCHAR2(25) not null,
	PHONE_NUMBER VARCHAR2(20),
	HIRE_DATE DATE not null,
	JOB_ID VARCHAR2(10) not null,
	SALARY NUMBER(8,2),
	COMMISSION_PCT NUMBER(2,2),
	MANAGER_ID NUMBER(6),
	DEPARTMENT_ID NUMBER(4)
);


SELECT *
FROM EMPLOYEES_COPY;

--cursor explicito: es un cursor con nombre
DECLARE
  CURSOR C_EMPLEADOS IS SELECT * FROM EMPLOYEES;
  V_REGISTRO HR.EMPLOYEES%ROWTYPE;
BEGIN
  OPEN C_EMPLEADOS;
  LOOP
    FETCH C_EMPLEADOS INTO V_REGISTRO;
    EXIT WHEN C_EMPLEADOS%NOTFOUND;
    INSERT INTO EMPLOYEES_COPY
      VALUES V_REGISTRO;
  END LOOP;
  COMMIT;
  CLOSE C_EMPLEADOS;
END;


SELECT COUNT(*)
FROM EMPLOYEES;
SELECT COUNT(*)
FROM EMPLOYEES_COPY;

TRUNCATE TABLE EMPLOYEES_COPY;

INSERT INTO EMPLOYEES_COPY
SELECT * FROM EMPLOYEES;

CREATE TABLE EMPLOYEES_BACKUP_20190715 AS
  SELECT * FROM EMPLOYEES;


SELECT *
  FROM EMPLOYEES_BACKUP_20190715;


EXECUTE P_TABLE_BACKUP('HR','EMPLOYEES');

--DIRECTAMENTE NO SE PUEDE EJECUTAR UN DDL DENTRO DE UN BLOQUE
--PARA LOGRARLO SE DEBE EJECUTAR CON LA INSTRUCCION EXECUTE IMMEDIATE
-- Y ENVIANDO LA INSTRUCCION DDL COMO CADENA
CREATE OR REPLACE PROCEDURE P_RESPALDO_TABLA(ESQUEMA VARCHAR2, TABLA VARCHAR2)
authid current_user
AS
  V_SQL VARCHAR2(1000);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE  'DROP TABLE '||ESQUEMA||'.'||TABLA||'_'||
                      TO_CHAR(SYSDATE,'YYYYMMDD');
    EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('El backup no existe, se creara');
  END;

  V_SQL := 'CREATE TABLE '||ESQUEMA||'.'||TABLA||'_'||
                    TO_CHAR(SYSDATE,'YYYYMMDD')||
                    ' AS SELECT * FROM '||ESQUEMA||'.'||TABLA;
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;

CALL P_RESPALDO_TABLA('HR','EMPLOYEES');



SELECT *
FROM ALL_TABLES
WHERE OWNER = 'HR'
AND TABLE_NAME LIKE 'EMPLOYEE%';

SELECT COUNT(*)
FROM ALL_TABLES
WHERE OWNER = 'HR'
AND TABLE_NAME = 'EMPLOYEES_20190715';


call system.P_RESPALDO_TABLA('hr','employees');



--ejemplo cursor implicito: Sin nombre


begin
  for v_registro in (select * from employees) loop
    dbms_output.put_line('Nombre: '||v_registro.FIRST_NAME);
  end loop;
end;


begin
  dbms_output.put_line('<table><thead><tr><th>First Name</th><th>Last Name</th><th>Salary</th></tr></thead><tbody>');
  for v_registro in (select * from employees) loop
    dbms_output.put_line('<tr><td>'||v_registro.FIRST_NAME||'</td><td>'||v_registro.last_NAME||'</td><td>'||v_registro.salary||'</td></tr>');
  end loop;
  dbms_output.put_line('</body></table>');
end;