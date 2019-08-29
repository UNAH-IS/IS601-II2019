--Crear nuevo usuario(esquema) con el password "PASSWORD" 
CREATE USER DWH_HR
  IDENTIFIED BY "oracle"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
--asignar cuota ilimitada al tablespace por defecto  
ALTER USER DWH_HR QUOTA UNLIMITED ON USERS;

--Asignar privilegios basicos
GRANT create session TO DWH_HR;
GRANT create table TO DWH_HR;
GRANT create view TO DWH_HR;
GRANT create any trigger TO DWH_HR;
GRANT create any procedure TO DWH_HR;
GRANT create sequence TO DWH_HR;
GRANT create materialized view TO DWH_HR;
GRANT select any table TO DWH_HR;
GRANT create synonym TO DWH_HR;


GRANT execute any procedure to DWH_HR;





--En caso de que el usuario system se bloquee ejecutar lo siguiente:
--Desde la consola:


sqlplus sys as sysdba 
--ingresar el password

alter user system account unlock;
alter user system identified by "nuevo_password";


alter user system account unlock;
alter user system identified by "oracle";