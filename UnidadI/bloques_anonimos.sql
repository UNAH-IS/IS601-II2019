create table nombre_tabla(
    campo tipo_dato opciones,
    campo tipo_dato opciones
);


--Habilitar consola de oracle para visualizar la salida.
set serveroutput on;

declare
    nombre varchar2(200):='Juan';
    apellido varchar2(200);
begin
    apellido:='Perez';
    dbms_output.put_line('Hola '||nombre||' '||apellido);
end;


declare
    nombre varchar2(200);
    apellido varchar2(200);
begin
    --En PL/SQL no se puede ejecutar una consulta a secas.
    --Es necesario almacenarla en alguna variable utilizando INTO
    --La consulta solo debe retornar un registro
    select first_name, last_name
    into nombre, apellido
    from employees
    where employee_id = 100;
    dbms_output.put_line('Hola '||nombre||' '||apellido);
end;


select (5+5) *2 as calculo
from dual;

select first_name, 6*6 as calculo, salary*0.05 as seguro,
    upper(first_name||' '||last_name) as nombre_completo
from employees;


set serveroutput on;
declare
    v_first_name employees.first_name%TYPE;
    v_last_name employees.last_name%TYPE;
    v_email employees.email%TYPE;
begin
    select first_name, last_name, email
    into v_first_name, v_last_name, v_email
    from employees
    where employee_id = 100;
    dbms_output.put_line('Hola '||v_first_name||' '||v_last_name||', '||v_email);
end;



declare
    v_registro employees%ROWTYPE;
begin
    select *
    into v_registro
    from employees
    where employee_id = 100;
    dbms_output.put_line('Hola '||v_registro.first_name||' '||v_registro.last_name||', '||v_registro.email||'('||v_registro.salary||')');
end;


declare
    type empleado is record (
        nombre varchar2(200),
        apellido varchar2(200),
        correo varchar2(200)
    );
    empleado1 empleado;

    /*class Empleado{
        public String nombre;
        public String apellido;
        public String correo;
    }

    Empleado empleado1 = new Empleado();*/
    
    
begin
   empleado1.nombre:='Juan';
   empleado1.apellido:='Perez';
   empleado1.correo:='JPEREZ';
    dbms_output.put_line('Hola '||empleado1.nombre||' '||empleado1.apellido||', '||empleado1.correo);
end;



declare
    type empleado is record (
        nombre varchar2(200),
        apellido varchar2(200),
        correo varchar2(200)
    );
    empleado1 empleado;
begin
    select first_name, last_name, email
    into empleado1
    from employees
    where employee_id = 100;
    dbms_output.put_line('Hola '||empleado1.nombre||' '||empleado1.apellido||', '||empleado1.correo);
end;

