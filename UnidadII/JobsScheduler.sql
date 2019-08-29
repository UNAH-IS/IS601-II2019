select * from tmp;
drop table tmp;
truncate table tmp;
create table tmp(
  fecha date
);

begin insert into tmp(fecha) values (sysdate); end;
--Tareas calendarizadas
--Extract Transform Load

--Esto solo se ejecuta una vez
begin
  dbms_scheduler.create_job (
    job_name => 'JOB_TEST',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin insert into tmp(fecha) values (sysdate); end;',
    number_of_arguments => 0,
    start_date => systimestamp + interval '1' minute, -- sysdate + 10 minutos
    job_class => 'DEFAULT_JOB_CLASS', -- Priority Group
    enabled => TRUE,
    auto_drop => TRUE,
    comments => 'JOB de prueba'
  );
end;


--Consultar todos los jobs calendarizados
select *
from ALL_SCHEDULER_JOBS;

select *
from all_tables
where owner = 'HR';


select *
from ALL_PROCEDURES;

select *
from ALL_VIEWS;

select *
from ALL_SEQUENCES;




select sysdate,
      to_char(sysdate,'YYYY/MM/DD') as fecha,
       to_char(sysdate, 'YYYY') as anio,
       to_char(sysdate,'hh24:mi:ss') hora
from dual;


select sysdate,
       sysdate + 10/24/59,
      sysdate + interval '10' minute
from dual;

select sysdate, systimestamp
from dual;


select systimestamp + interval '6' hour as fecha_hora_exacta_mas_6_h,
      trunc(systimestamp) + interval '23' hour as dia_actual_11pm,
       trunc(systimestamp,'month') as primer_dia_mes_actual,
       trunc(systimestamp,'year') as primer_dia_anio_actual,
       trunc(5.4)
from dual;


select last_day(systimestamp+1)
from dual;


begin
  dbms_scheduler.run_job('JOB_TEST',TRUE);
end;

begin
  dbms_scheduler.drop_job('JOB_TEST');
end;



-- intervalo diario
begin
  dbms_scheduler.create_schedule(
      schedule_name => 'INTERVALO_DIARIO',
      start_date=> SYSTIMESTAMP + INTERVAL '1' MINUTE,
      repeat_interval=> 'FREQ=DAILY; BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN;BYHOUR=20;',
      comments=>'Ejecucion: Todos los dias a las 20:00'
  );
end;

-- intervalo cada hora
begin
  dbms_scheduler.create_schedule(
      schedule_name => 'INTERVALO_CADA_HORA',
      start_date => SYSTIMESTAMP + INTERVAL '1' MINUTE,
      repeat_interval => 'freq=HOURLY;interval=1',
      comments => 'Ejecucion: cada hora'
  );
end;
/
-- intervalo cada 10 minutos
begin
  dbms_scheduler.create_schedule(
      schedule_name => 'INTERVALO_CADA_10_MINUTOS',
      start_date => SYSTIMESTAMP + INTERVAL '1' MINUTE,
      repeat_interval => 'freq=MINUTELY;interval=10',
      comments => 'Ejecucion: cada 10 minutos'
  );
end;

-- intervalo cada 10 minutos
begin
  dbms_scheduler.create_schedule(
      schedule_name => 'INTERVALO_CADA_MINUTO',
      start_date => SYSTIMESTAMP + INTERVAL '1' MINUTE,
      repeat_interval => 'freq=MINUTELY;interval=1',
      comments => 'Ejecucion: cada minuto'
  );
end;
/
-- todos los viernes a las 14:00
begin
  dbms_scheduler.create_schedule(
    schedule_name => 'INTERVALO_VIERNES_1400',
    start_date=> trunc(sysdate)+18/24,
    repeat_interval=> 'FREQ=DAILY; BYDAY=FRI; BYHOUR=14;',
    comments=>'Ejecucion: Cada viernes a las 14:00'
  );
end;

select *
from ALL_SCHEDULER_SCHEDULES;
--schedule_name



begin
  dbms_scheduler.create_job (
    job_name => 'JOB_TEST',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin insert into tmp(fecha) values (sysdate); commit; end;',
    number_of_arguments => 0,
    --start_date => systimestamp + interval '1' minute, -- sysdate + 10 minutos
    job_class => 'DEFAULT_JOB_CLASS', -- Priority Group
    enabled => TRUE,
    auto_drop => false,
    comments => 'JOB de prueba',
    schedule_name => 'INTERVALO_CADA_MINUTO'
  );
end;