CREATE OR REPLACE PACKAGE PKG_EMPLEADOS AS
  PROCEDURE P_AGREGAR_EMPLEADO(
    p_first_name in varchar2,
    p_last_name in varchar2
  );

  PROCEDURE P_AGREGAR_EMPLEADO(
    p_first_name in varchar2,
    p_last_name in varchar2,
    p_email in varchar2,
    p_phone_number in varchar2,
    p_hire_date in date,
    p_job_id in varchar2,
    p_salary in number,
    p_commission_pct in number,
    p_manager_id in number,
    p_department_id in number,
    p_resultado out varchar2,
    p_codigo_resultado out integer,
    p_employee_id out integer
  );

  PROCEDURE P_ACTUALIZAR_EMPLEADO(
    p_employee_id in integer,
    p_first_name in varchar2,
    p_last_name in varchar2,
    p_email in varchar2,
    p_phone_number in varchar2,
    p_hire_date in date,
    p_job_id in varchar2,
    p_salary in number,
    p_commission_pct in number,
    p_manager_id in number,
    p_department_id in number,
    p_resultado out varchar2,
    p_codigo_resultado out integer
  );

  PROCEDURE P_ELIMINAR_EMPLEADO(
    p_employee_id in integer,
    p_resultado out varchar2,
    p_codigo_resultado out integer
  );

  FUNCTION F_LOGIN(
    P_USUARIO VARCHAR2,
    P_CONTRASENA VARCHAR2,
    P_CODIGO_USUARIO OUT INTEGER,
    P_CODIGO_TIPO_USUARIO OUT INTEGER
  ) RETURN boolean;

END PKG_EMPLEADOS;


CREATE OR REPLACE PACKAGE BODY PKG_EMPLEADOS AS
  V_VARIABLE_GLOBAL VARCHAR2(100):='VALOR DE LA VARIABLE GLOBAL';
  PROCEDURE P_AGREGAR_EMPLEADO(
    P_FIRST_NAME IN VARCHAR2,
    P_LAST_NAME IN VARCHAR2
  ) AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('AGREGAR EMPLEADO OPCION 1');
  END P_AGREGAR_EMPLEADO;

  PROCEDURE P_AGREGAR_EMPLEADO(
    P_FIRST_NAME IN VARCHAR2,
    P_LAST_NAME IN VARCHAR2,
    P_EMAIL IN VARCHAR2,
    P_PHONE_NUMBER IN VARCHAR2,
    P_HIRE_DATE IN DATE,
    P_JOB_ID IN VARCHAR2,
    P_SALARY IN NUMBER,
    P_COMMISSION_PCT IN NUMBER,
    P_MANAGER_ID IN NUMBER,
    P_DEPARTMENT_ID IN NUMBER,
    P_RESULTADO OUT VARCHAR2,
    P_CODIGO_RESULTADO OUT INTEGER,
    P_EMPLOYEE_ID OUT INTEGER
  ) AS
      V_SALARIO_MAXIMO NUMBER;
  BEGIN
    SELECT MAX(SALARY)
    INTO V_SALARIO_MAXIMO
    FROM EMPLOYEES;

    IF P_SALARY>V_SALARIO_MAXIMO THEN
      P_RESULTADO := 'SALARIO NO PERMITIDO, SE HA DETECTADO UN CORRUPTO';
      P_CODIGO_RESULTADO:=1;
      RETURN;
    ELSE
      P_EMPLOYEE_ID := EMPLOYEES_SEQ.NEXTVAL;
      INSERT INTO EMPLOYEES (
          EMPLOYEE_ID,
          FIRST_NAME,
          LAST_NAME,
          EMAIL,
          PHONE_NUMBER,
          HIRE_DATE,
          JOB_ID,
          SALARY,
          COMMISSION_PCT,
          MANAGER_ID,
          DEPARTMENT_ID
      ) VALUES (
          P_EMPLOYEE_ID,
          P_FIRST_NAME,
          P_LAST_NAME,
          P_EMAIL,
          P_PHONE_NUMBER,
          P_HIRE_DATE,
          P_JOB_ID,
          P_SALARY,
          P_COMMISSION_PCT,
          P_MANAGER_ID,
          P_DEPARTMENT_ID
      );
      COMMIT;
      P_RESULTADO := 'REGISTRO ALMACENADO CON EXITO';
      P_CODIGO_RESULTADO := 0;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        /*DBMS_OUTPUT.PUT_LINE('OCURRIO UN ERROR: ' || SQLERRM);*/
        P_RESULTADO := 'OCURRIO UN ERROR: ' || SQLERRM;
        P_CODIGO_RESULTADO := 1;
  END P_AGREGAR_EMPLEADO;

  PROCEDURE P_ACTUALIZAR_EMPLEADO(
    P_EMPLOYEE_ID IN INTEGER,
    P_FIRST_NAME IN VARCHAR2,
    P_LAST_NAME IN VARCHAR2,
    P_EMAIL IN VARCHAR2,
    P_PHONE_NUMBER IN VARCHAR2,
    P_HIRE_DATE IN DATE,
    P_JOB_ID IN VARCHAR2,
    P_SALARY IN NUMBER,
    P_COMMISSION_PCT IN NUMBER,
    P_MANAGER_ID IN NUMBER,
    P_DEPARTMENT_ID IN NUMBER,
    P_RESULTADO OUT VARCHAR2,
    P_CODIGO_RESULTADO OUT INTEGER
  ) AS
      V_SALARIO_MAXIMO NUMBER;
    BEGIN
      SELECT MAX(SALARY)
      INTO V_SALARIO_MAXIMO
      FROM EMPLOYEES;

      IF P_SALARY>V_SALARIO_MAXIMO THEN
        P_RESULTADO := 'SALARIO NO PERMITIDO, SE HA DETECTADO UN CORRUPTO';
        P_CODIGO_RESULTADO:=1;
        RETURN;
      ELSE
        UPDATE EMPLOYEES
        SET
            FIRST_NAME=P_FIRST_NAME,
            LAST_NAME=P_LAST_NAME,
            EMAIL=P_EMAIL,
            PHONE_NUMBER=P_PHONE_NUMBER,
            HIRE_DATE=P_HIRE_DATE,
            JOB_ID=P_JOB_ID,
            SALARY=P_SALARY,
            COMMISSION_PCT=P_COMMISSION_PCT,
            MANAGER_ID=P_MANAGER_ID,
            DEPARTMENT_ID=P_DEPARTMENT_ID
        WHERE EMPLOYEE_ID=P_EMPLOYEE_ID;
        COMMIT;
        P_RESULTADO := 'REGISTRO ALMACENADO CON EXITO';
        P_CODIGO_RESULTADO := 0;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
          /*DBMS_OUTPUT.PUT_LINE('OCURRIO UN ERROR: ' || SQLERRM);*/
          P_RESULTADO := 'OCURRIO UN ERROR: ' || SQLERRM;
          P_CODIGO_RESULTADO := 1;
  END P_ACTUALIZAR_EMPLEADO;

  PROCEDURE P_ELIMINAR_EMPLEADO(
    P_EMPLOYEE_ID IN INTEGER,
    P_RESULTADO OUT VARCHAR2,
    P_CODIGO_RESULTADO OUT INTEGER
  )AS
  BEGIN
    DELETE FROM JOB_HISTORY
    WHERE EMPLOYEE_ID= P_EMPLOYEE_ID;

    UPDATE EMPLOYEES
    SET MANAGER_ID = NULL
    WHERE MANAGER_ID = P_EMPLOYEE_ID;

    UPDATE DEPARTMENTS
    SET MANAGER_ID = NULL
      WHERE MANAGER_ID = P_EMPLOYEE_ID;

    DELETE FROM EMPLOYEES
    WHERE EMPLOYEE_ID = P_EMPLOYEE_ID;

    P_RESULTADO := 'REGISTRO ELIMINADO CON EXITO';
    P_CODIGO_RESULTADO := 0;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
        P_RESULTADO := 'OCURRIO UN ERROR AL ELIMINAR: ' || SQLERRM||' '||SQLCODE;
        P_CODIGO_RESULTADO := 1;
        rollback;
  END P_ELIMINAR_EMPLEADO;

  FUNCTION F_LOGIN(
    P_USUARIO VARCHAR2,
    P_CONTRASENA VARCHAR2,
    P_CODIGO_USUARIO OUT INTEGER,
    P_CODIGO_TIPO_USUARIO OUT INTEGER
  ) RETURN BOOLEAN
  AS
  /*V_CODIGO_USUARIO INTEGER;
    V_CODIGO_TIPO_USUARIO INTEGER;*/
    V_CANTIDAD INTEGER;
  BEGIN
      SELECT COUNT(*)
      INTO V_CANTIDAD
      FROM USUARIOS
      WHERE USUARIO = P_USUARIO
      AND CONTRASENA = P_CONTRASENA;

      IF (V_CANTIDAD>0) THEN
          SELECT CODIGO_USUARIO, CODIGO_TIPO_USUARIO
          INTO P_CODIGO_USUARIO, P_CODIGO_TIPO_USUARIO
          FROM USUARIOS
          WHERE USUARIO = P_USUARIO
          AND CONTRASENA = P_CONTRASENA;

          /*DBMS_OUTPUT.PUT_LINE('V_CODIGO_USUARIO: '||V_CODIGO_USUARIO);
          DBMS_OUTPUT.PUT_LINE('V_CODIGO_TIPO_USUARIO: '||V_CODIGO_TIPO_USUARIO);*/
          RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
  END F_LOGIN;
END PKG_EMPLEADOS;





declare
    v_resultado varchar2(500);
    v_codigo_resultado integer;
    v_employee_id integer;
begin
    HR.PKG_EMPLEADOS.p_agregar_empleado(
        p_first_name => 'Matusalen',
        p_last_name => 'Rodriguez',
        p_email => 'matu446erasd@gmail.com',
        p_phone_number => '515.123.4456111',
        p_hire_date => to_date('12/12/2012','dd/mm/yyyy'),
        p_job_id => 'IT_PROG',
        p_salary => 4567,
        p_commission_pct => 0.5,
        p_manager_id => 103,
        p_department_id => 60,
        p_resultado => v_resultado,
        p_codigo_resultado => v_codigo_resultado,
        p_employee_id => v_employee_id
    );
    dbms_output.put_line('v_resultado: '||v_resultado);
    dbms_output.put_line('v_codigo_resultado: '||v_codigo_resultado);
    dbms_output.put_line('v_employee_id: '||v_employee_id);
end;

DECLARE
    V_RESULTADO VARCHAR2(500);
    V_CODIGO_RESULTADO INTEGER;
BEGIN
    HR.PKG_EMPLEADOS.P_ELIMINAR_EMPLEADO(200,V_RESULTADO,V_CODIGO_RESULTADO);
    dbms_output.put_line('v_resultado: '||v_resultado);
    dbms_output.put_line('v_codigo_resultado: '||v_codigo_resultado);
END;

select *
from EMPLOYEES
where employee_id = 200;

rollback;