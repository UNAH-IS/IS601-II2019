-------Consultas-----------------------------------------------------------------------------------------------------------


-----llenar tabla de JOBS
insert into jobs(
    job_id,
    job_title,
    min_salary,
    max_salary
)
SELECT job_id,
    job_title,
    min_salary,
    max_salary
FROM hr.jobs;

select * from jobs;
commit;

----------llenar tabla de empleados
insert into employees (
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
)
SELECT employee_id,
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
FROM hr.employees;

commit;
-----------------------------------------
select *
from departments;

insert into DEPARTMENTS (
        DEPARTMENT_ID,
        DEPARTMENT_NAME,
        MANAGER_ID,
        LOCATION_ID,
        STREET_ADDRESS,
        POSTAL_CODE,
        CITY,
        STATE_PROVINCE,
        COUNTRY_ID,
        COUNTRY_NAME,
        REGION_ID,
        REGION_NAME
)
select a.DEPARTMENT_ID,
        a.DEPARTMENT_NAME,
        a.MANAGER_ID,
        a.LOCATION_ID,
        b.STREET_ADDRESS,
        b.POSTAL_CODE,
        b.CITY,
        b.STATE_PROVINCE,
        b.COUNTRY_ID,
        c.COUNTRY_NAME,
        c.REGION_ID,
        d.REGION_NAME
from hr.departments a
left join hr.locations b
on (a.LOCATION_ID = b.LOCATION_ID)
left join hr.countries c
on (b.country_id = c.country_id)
left join hr.regions d
on (c.region_id = d.region_id);


select count(*) from hr.departments; --27


insert into dwh_hr.JOB_HISTORY(
        employee_id,
        start_date,
        end_date,
        job_id,
        department_id
)
SELECT  employee_id,
        start_date,
        end_date,
        job_id,
        department_id
FROM hr.job_history;

commit;


----------------------------------------------------------------------------------------------------------------------------------------------

create table log_etls(
  nombre_etl varchar2(30),
  fecha_hora_inicio timestamp,
  fecha_hora_fin timestamp,
  estado_ejecucion varchar2(1),
  comentario varchar2(1000)
);


--EL TIPO DE EXTRACCION MÁS ADECUADO PARA ESTE CASO ES VOLATIL
--PORQUE LA INFORMACION PUEDE VARIAR EN CUALQUIER MOMENTO
CREATE OR REPLACE PROCEDURE P_ETL_JOBS AS
    V_HORA_INICIO TIMESTAMP;
    V_COMENTARIO VARCHAR2(2000);
BEGIN
  ----AQUI INICIA
  V_HORA_INICIO := SYSTIMESTAMP;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JOBS';
  INSERT INTO JOBS(
    JOB_ID,
    JOB_TITLE,
    MIN_SALARY,
    MAX_SALARY
  )
  SELECT JOB_ID,
      JOB_TITLE,
      MIN_SALARY,
      MAX_SALARY
  FROM HR.JOBS;

  INSERT INTO LOG_ETLS (
      nombre_etl,
      fecha_hora_inicio,
      fecha_hora_fin ,
      estado_ejecucion,
      comentario
  )
  VALUES (
    'P_ETL_JOBS',
    V_HORA_INICIO,
    SYSTIMESTAMP,
    'S',
    'EXTRACCION FINALIZADA CON EXITO'
  );
  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      V_COMENTARIO :='EXTRACCION FINALIZADA CON ERROR '||SQLERRM;
      ROLLBACK;
      INSERT INTO LOG_ETLS (
          nombre_etl,
          fecha_hora_inicio,
          fecha_hora_fin ,
          estado_ejecucion,
          comentario
      )
      VALUES (
        'P_ETL_JOBS',
        V_HORA_INICIO,
        SYSTIMESTAMP,
        'N',
        V_COMENTARIO
      );
      COMMIT;
END;

call p_etl_jobs();

--alter table nombre_tabla disable constraint nombre_constraint;
select * from jobs;

TRUNCATE TABLE log_etls;


SELECT *
FROM log_etls;




-- intervalo cada minuto
begin
  dbms_scheduler.create_schedule(
      schedule_name => 'INTERVALO_CADA_MINUTOS',
      start_date => SYSTIMESTAMP + INTERVAL '1' MINUTE,
      repeat_interval => 'freq=MINUTELY;interval=1',
      comments => 'Ejecucion: cada minuto'
  );
end;

SELECT *
  FROM ALL_SCHEDULER_SCHEDULES;

begin
  dbms_scheduler.create_job (
    job_name => 'ETL_JOBS',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin p_etl_jobs(); end;',
    number_of_arguments => 0,
    --start_date => systimestamp + interval '1' minute, -- sysdate + 10 minutos
    job_class => 'DEFAULT_JOB_CLASS', -- Priority Group
    enabled => TRUE,
    auto_drop => false,
    comments => 'Tarea calendarizada para extraer la información de la tabla de JOBS del esquema HR',
    schedule_name => 'INTERVALO_CADA_MINUTOS'
  );
end;


select * from ALL_SCHEDULER_JOBS;




-----------------------------------------------------------------------------------------------------
----EXTRACCION DEPARTAMENTOS
create or replace procedure p_etl_departments
as
    V_HORA_INICIO TIMESTAMP;
    V_COMENTARIO VARCHAR2(2000);
begin
   ----AQUI INICIA
  V_HORA_INICIO := SYSTIMESTAMP;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE DEPARTMENTS';
  insert into DEPARTMENTS (
          DEPARTMENT_ID,
          DEPARTMENT_NAME,
          MANAGER_ID,
          LOCATION_ID,
          STREET_ADDRESS,
          POSTAL_CODE,
          CITY,
          STATE_PROVINCE,
          COUNTRY_ID,
          COUNTRY_NAME,
          REGION_ID,
          REGION_NAME
  )
  select a.DEPARTMENT_ID,
          a.DEPARTMENT_NAME,
          a.MANAGER_ID,
          a.LOCATION_ID,
          b.STREET_ADDRESS,
          b.POSTAL_CODE,
          b.CITY,
          b.STATE_PROVINCE,
          b.COUNTRY_ID,
          c.COUNTRY_NAME,
          c.REGION_ID,
          d.REGION_NAME
  from hr.departments@remote_windows a
  left join hr.locations@remote_windows b
  on (a.LOCATION_ID = b.LOCATION_ID)
  left join hr.countries@remote_windows c
  on (b.country_id = c.country_id)
  left join hr.regions@remote_windows d
  on (c.region_id = d.region_id);

  INSERT INTO LOG_ETLS (
      nombre_etl,
      fecha_hora_inicio,
      fecha_hora_fin ,
      estado_ejecucion,
      comentario
  )
  VALUES (
    'P_ETL_DEPARTMENTS',
    V_HORA_INICIO,
    SYSTIMESTAMP,
    'S',
    'EXTRACCION FINALIZADA CON EXITO'
  );
  COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    V_COMENTARIO :='EXTRACCION FINALIZADA CON ERROR '||SQLERRM;
      ROLLBACK;
      INSERT INTO LOG_ETLS (
          nombre_etl,
          fecha_hora_inicio,
          fecha_hora_fin ,
          estado_ejecucion,
          comentario
      )
      VALUES (
        'P_ETL_DEPARTMENTS',
        V_HORA_INICIO,
        SYSTIMESTAMP,
        'N',
        V_COMENTARIO
      );
      COMMIT;
end;



-- intervalo cada minuto
begin
  dbms_scheduler.create_schedule(
      schedule_name => 'INTERVALO_CADA_MINUTO',
      start_date => SYSTIMESTAMP + INTERVAL '1' MINUTE,
      repeat_interval => 'freq=MINUTELY;interval=1',
      comments => 'Ejecucion: cada minuto'
  );
end;

select * from LOG_ETLS;

select *
from ALL_SCHEDULER_SCHEDULES;

begin
  dbms_scheduler.create_job (
    job_name => 'ETL_JOBS',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin p_etl_jobs(); end;',
    number_of_arguments => 0,
    --start_date => systimestamp + interval '1' minute, -- sysdate + 10 minutos
    job_class => 'DEFAULT_JOB_CLASS', -- Priority Group
    enabled => TRUE,
    auto_drop => false,
    comments => 'Tarea calendarizada para extraer la información de la tabla de JOBS del esquema HR',
    schedule_name => 'INTERVALO_CADA_MINUTO'
  );
end;


begin
  dbms_scheduler.create_job (
    job_name => 'ETL_DEPARTMENTS',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin p_etl_departments(); end;',
    number_of_arguments => 0,
    --start_date => systimestamp + interval '1' minute, -- sysdate + 10 minutos
    job_class => 'DEFAULT_JOB_CLASS', -- Priority Group
    enabled => TRUE,
    auto_drop => false,
    comments => 'Tarea calendarizada para extraer la información de la tabla de DEPARTMENTS del esquema HR',
    schedule_name => 'INTERVALO_CADA_MINUTO'
  );
end;


SELECT *
FROM ALL_SCHEDULER_JOBS;

SELECT *
FROM LOG_ETLS;


SELECT *
FROM DWH_HR.DEPARTMENTS;