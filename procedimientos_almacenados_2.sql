

CREATE OR REPLACE PROCEDURE P_AGREGAR_EMPLEADO(
    p_first_name varchar2,
    p_last_name varchar2,
    p_email varchar2,
    p_phone_number varchar2,
    p_hire_date date,
    p_job_id varchar2,
    p_salary number,
    p_commission_pct number,
    p_manager_id number,
    p_department_id number
) AS
    v_salario_maximo number;
BEGIN
    select max(salary)
    into v_salario_maximo
    from employees;

    if p_salary>v_salario_maximo then
      dbms_output.put_line('Salario no permitido, se ha detectado un corrupto');
      return;
    else
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
          EMPLOYEES_SEQ.NEXTVAL,
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
    end if;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrio un error: ' || SQLERRM);
END;


DROP TABLE TMP;
CREATE TABLE TMP (
    CODIGO INTEGER,
    FECHA DATE
);


CREATE SEQUENCE SEQ_TMP;


INSERT INTO TMP (CODIGO, FECHA)
VALUES (SEQ_TMP.NEXTVAL,SYSDATE);



SELECT SEQ_TMP.CURRVAL
FROM DUAL;

SELECT * FROM TMP;

commit;



execute p_agregar_empleado('Matusalen','Rodriguez','matul@gmail.com','515.123.4456111',to_date('12/12/2012','dd/mm/yyyy'),'IT_PROG',4567,0.5,103,60);


select *
from employees;

select *
from jobs;

