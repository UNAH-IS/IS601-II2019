--Crear nuevo usuario(esquema) con el password "PASSWORD" 
CREATE USER DB_UNAH
  IDENTIFIED BY "oracle"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
--asignar cuota ilimitada al tablespace por defecto  
ALTER USER DB_UNAH QUOTA UNLIMITED ON USERS;

--Asignar privilegios basicos
GRANT create session TO DB_UNAH;
GRANT create table TO DB_UNAH;
GRANT create view TO DB_UNAH;
GRANT create any trigger TO DB_UNAH;
GRANT create any procedure TO DB_UNAH;
GRANT create sequence TO DB_UNAH;
GRANT create materialized view TO DB_UNAH;
GRANT select any table TO DB_UNAH;
GRANT create synonym TO DB_UNAH;


GRANT execute any procedure to DB_UNAH;





--En caso de que el usuario system se bloquee ejecutar lo siguiente:
--Desde la consola:


sqlplus sys as sysdba 
--ingresar el password

alter user system account unlock;
alter user system identified by "nuevo_password";


alter user system account unlock;
alter user system identified by "oracle";