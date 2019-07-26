--Crear nuevo usuario(esquema) con el password "PASSWORD" 
CREATE USER FACEBOOK
  IDENTIFIED BY "oracle"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
--asignar cuota ilimitada al tablespace por defecto  
ALTER USER FACEBOOK QUOTA UNLIMITED ON USERS;

--Asignar privilegios basicos
GRANT create session TO FACEBOOK;
GRANT create table TO FACEBOOK;
GRANT create view TO FACEBOOK;
GRANT create any trigger TO FACEBOOK;
GRANT create any procedure TO FACEBOOK;
GRANT create sequence TO FACEBOOK;
GRANT create synonym TO FACEBOOK;