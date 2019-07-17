CREATE OR REPLACE PROCEDURE P_AGREGAR_EMPLEADO(
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
) AS
    v_salario_maximo number;
BEGIN
    select max(salary)
    into v_salario_maximo
    from employees;

    if p_salary>v_salario_maximo then
      p_resultado := 'Salario no permitido, se ha detectado un corrupto';
      p_codigo_resultado:=1;
      return;
    else
      p_employee_id := EMPLOYEES_SEQ.NEXTVAL;
      INSERT INTO employees (
          employee_id,
          first_name,
          last_name,
          email,
          phone_number,
          hire_date,
          job_id,
          salary,
          commission_pct,
          manager_id,
          department_id
      ) VALUES (
          p_employee_id,
          p_first_name,
          p_last_name,
          p_email,
          p_phone_number,
          p_hire_date,
          p_job_id,
          p_salary,
          p_commission_pct,
          p_manager_id,
          p_department_id
      );
      COMMIT;
      p_resultado := 'Registro almacenado con exito';
      p_codigo_resultado := 0;
    end if;

EXCEPTION
    WHEN OTHERS THEN
        /*DBMS_OUTPUT.PUT_LINE('Ocurrio un error: ' || SQLERRM);*/
        p_resultado := 'Ocurrio un error: ' || SQLERRM;
        p_codigo_resultado := 1;
END;





declare
    v_resultado varchar2(500);
    v_codigo_resultado integer;
    v_employee_id integer;
begin
    p_agregar_empleado(
        p_first_name => 'Matusalen',
        p_last_name => 'Rodriguez',
        p_email => 'matu446@gmail.com',
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


select *
from employees
where employee_id = 216;



-------------------------------------------------------------
CREATE TABLE USUARIOS (
  CODIGO_USUARIO INTEGER,
  USUARIO VARCHAR2(500),
  CONTRASENA VARCHAR2(500),
  CODIGO_TIPO_USUARIO INTEGER
);
SELECT *
FROM USUARIOS;

CREATE OR REPLACE FUNCTION F_LOGIN(P_USUARIO VARCHAR2, P_CONTRASENA VARCHAR2, P_CODIGO_USUARIO OUT INTEGER, P_CODIGO_TIPO_USUARIO OUT INTEGER)
RETURN boolean
AS
    /*V_CODIGO_USUARIO INTEGER;
    V_CODIGO_TIPO_USUARIO INTEGER;*/
    V_CANTIDAD INTEGER;
BEGIN
      SELECT count(*)
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
          RETURN true;
    ELSE
        RETURN false;
    END IF;
END F_LOGIN;

--nO dATA FOUND


select case
        when f_login('jperez','asd.456') then
            'Si existe'
        else 'No existe'
      end
from dual;


--pRUEBA DE EJECUCION DE LA FUNCION
declare
  v_resultado boolean;
  V_CODIGO_USUARIO INTEGER;
  V_CODIGO_TIPO_USUARIO INTEGER;
begin
  v_resultado := f_login('jperez','asd.456',V_CODIGO_USUARIO, V_CODIGO_TIPO_USUARIO );
  if (v_resultado = true) then
    dbms_output.put_line('USUARIO SI EXISTE');
    dbms_output.put_line('CODIGO USUARIO LOGUEADO: ' || V_CODIGO_USUARIO);
    dbms_output.put_line('CODIGO TIPO USUARIO LOGUEADO: ' || V_CODIGO_TIPO_USUARIO);
  else
    dbms_output.put_line('USUARIO NO EXISTE');
  end if;
end;


SELECT *
FROM (
       SELECT CODIGO_USUARIO, UPPER(USUARIO)
       FROM USUARIOS
)
WHERE CODIGO_USUARIO = 1;

SELECT CODIGO_USUARIO, UPPER(USUARIO)
FROM (
       SELECT CODIGO_USUARIO, USUARIO
       FROM USUARIOS
      WHERE CODIGO_USUARIO = 1
);



DECLARE
  Num1 NUMBER :=3;
  Num2 NUMBER; -- Como no inicializamos la variable, su valor es NULL
  EsMayor VARCHAR2(15);
BEGIN
  IF Num1 < Num2 THEN
    DBMS_OUTPUT.PUT_LINE('Yes');
  ELSE
    DBMS_OUTPUT.PUT_LINE('No');
  END IF;
END;



DECLARE
  equipo varchar(100);
  ciudad varchar(50):= 'MADRID';
BEGIN
    CASE ciudad
      WHEN 'MADRID' THEN equipo:= 'RealMadrid';
      WHEN 'BARCELONA' THEN equipo:='FCBarcelona';
      WHEN  'LACORUÑA' THEN equipo:= 'Deportivo de La Coruña';
      ELSE equipo:='SIN EQUIPO';
    END CASE;
    DBMS_OUTPUT.PUT_LINE(equipo);
END;



DECLARE
  equipo varchar(100);
  ciudad varchar(50):= 'MADRID';
BEGIN
    CASE
      WHEN ciudad='MADRID' AND OTRA_VARIABLE = '' THEN equipo:= 'RealMadrid';
      WHEN CUALQUIER_vARIABLE =  '' THEN equipo:='FCBarcelona';
      WHEN  ciudad='LACORUÑA' THEN equipo:= 'Deportivo de La Coruña';
      ELSE equipo:='SIN EQUIPO';
    END CASE;
    DBMS_OUTPUT.PUT_LINE(equipo);
END;


SELECT  FIRST_NAME, LAST_NAME,
       CASE
          WHEN SALARY >15000 THEN 'TIENE BILLETE'
          ELSE 'ES POBRE'
        END AS RESULTADO
FROM EMPLOYEES;