delete from TBL_MATRICULA
where 1=1;

commit;
--rutina para llenar informacion de prueba
select sysdate, add_months(sysdate, -30)
  from dual;


declare
  v_fecha_inicio date;
  v_fecha_fin    date := sysdate;
begin

  v_fecha_inicio := add_months(sysdate, -30);
  while (v_fecha_inicio<=v_fecha_fin) loop
    for i in 1.. round(DBMS_RANDOM.value(1,50)) loop
        insert into tbl_matricula(
            FECHA_MATRICULA,
            CODIGO_SECCION,
            CODIGO_ALUMNO,
            CODIGO_ESTADO_MATRICULA
        )
        values (
            v_fecha_inicio,
            round(DBMS_RANDOM.value(1,10)),
            round(DBMS_RANDOM.value(1,30)),
            round(DBMS_RANDOM.value(1,3))
        );
      end loop;
      v_fecha_inicio:=v_fecha_inicio+1;
  end loop;
  commit;
end;

select trunc(fecha_matricula), count(*)
  from TBL_MATRICULA
group by trunc(FECHA_MATRICULA)
order by trunc(FECHA_MATRICULA);


select min(fecha_matricula)
from tbl_matricula;

select *
  from EXTRACCION_MATRICULA;
rollback;
DROP TABLE EXTRACCION_MATRICULA;
create table EXTRACCION_MATRICULA
(
  FECHA_MATRICULA         DATE,
  FECHA_HORA_MATRICULA    DATE,
  CODIGO_SECCION          NUMBER not null,
  CANTIDAD_CUPOS          NUMBER,
  CODIGO_ALUMNO           NUMBER not null,
  NOMBRE                  VARCHAR2(1000),
  CODIGO_ESTADO_MATRICULA NUMBER not null,
  ESTADO_MATRICULA        VARCHAR2(300),
  CODIGO_ASIGNATURA       INTEGER,
  NOMBRE_ASIGNATURA       VARCHAR2(1000),
  NOMBRE_PERIODO          VARCHAR2(500)
);


DROP TABLE EXTRACCION_MATRICULA_RESUMEN;
create table EXTRACCION_MATRICULA_RESUMEN
(
  FECHA_MATRICULA         DATE,
  CODIGO_SECCION          NUMBER not null,
  CANTIDAD_CUPOS          NUMBER,
  CODIGO_ESTADO_MATRICULA NUMBER not null,
  ESTADO_MATRICULA        VARCHAR2(300),
  CODIGO_ASIGNATURA       INTEGER,
  NOMBRE_ASIGNATURA       VARCHAR2(1000),
  NOMBRE_PERIODO          VARCHAR2(500),
  CANTIDAD_ALUMNOS        NUMBER not null
);


truncate table EXTRACCION_MATRICULA;


create or replace PROCEDURE P_ETL_MATRICULA AS
  V_HORA_INICIO TIMESTAMP;
  V_COMENTARIO VARCHAR2(2000);
  V_FECHA_INICIO DATE;
  V_FECHA_FIN DATE;
BEGIN
  ----AQUI INICIA
  V_HORA_INICIO := SYSTIMESTAMP;


  SELECT trunc(NVL(FECHA_MATRICULA,
             (SELECT MIN(FECHA_MATRICULA)
              FROM TBL_MATRICULA)
           )) INTO
           V_FECHA_INICIO
  FROM (
         SELECT MAX(FECHA_MATRICULA) + 1 AS FECHA_MATRICULA
         FROM EXTRACCION_MATRICULA
       );
  V_FECHA_FIN := trunc(SYSDATE-1);

  WHILE (V_FECHA_INICIO <= V_FECHA_FIN)
    LOOP
      INSERT INTO EXTRACCION_MATRICULA(
                 FECHA_MATRICULA,
                 FECHA_HORA_MATRICULA,
                 CODIGO_SECCION,
                 CANTIDAD_CUPOS,
                 CODIGO_ALUMNO,
                 NOMBRE,
                 CODIGO_ESTADO_MATRICULA,
                 ESTADO_MATRICULA,
                 CODIGO_ASIGNATURA,
                 NOMBRE_ASIGNATURA,
                 NOMBRE_PERIODO
        )
        select TRUNC(A.FECHA_MATRICULA) AS FECHA_MATRICULA,
                A.FECHA_MATRICULA AS FECHA_HORA_MATRICULA,
                A.CODIGO_SECCION,
                D.CANTIDAD_CUPOS,
                A.CODIGO_ALUMNO,
                B.NOMBRE || ' ' || B.APELLIDO AS NOMBRE,
                A.CODIGO_ESTADO_MATRICULA,
                C.NOMBRE_ESTADO as ESTADO_MATRICULA,
                E.CODIGO_ASIGNATURA,
                E.NOMBRE_ASIGNATURA,
                F.NOMBRE_PERIODO
        FROM TBL_MATRICULA A
        INNER JOIN TBL_PERSONAS B
        ON (A.CODIGO_ALUMNO = B.CODIGO_PERSONA)
        INNER JOIN TBL_ESTADOS_MATRICULA C
        ON (A.CODIGO_ESTADO_MATRICULA = C.CODIGO_ESTADO_MATRICULA)
        INNER JOIN TBL_SECCION D
        ON A.CODIGO_SECCION = D.CODIGO_SECCION
        INNER JOIN TBL_ASIGNATURAS E
        ON D.CODIGO_ASIGNATURA = E.CODIGO_ASIGNATURA
        INNER JOIN TBL_PERIODOS F
        ON D.CODIGO_PERIODO = F.CODIGO_PERIODO
        WHERE trunc(A.FECHA_MATRICULA) = trunc(V_FECHA_INICIO);


        INSERT INTO EXTRACCION_MATRICULA_RESUMEN(
              FECHA_MATRICULA,
              CODIGO_SECCION,
              CANTIDAD_CUPOS,
              CODIGO_ESTADO_MATRICULA,
              ESTADO_MATRICULA,
              CODIGO_ASIGNATURA,
              NOMBRE_ASIGNATURA,
              NOMBRE_PERIODO,
              CANTIDAD_ALUMNOS
        )
        SELECT FECHA_MATRICULA,
              CODIGO_SECCION,
              CANTIDAD_CUPOS,
              CODIGO_ESTADO_MATRICULA,
              ESTADO_MATRICULA,
              CODIGO_ASIGNATURA,
              NOMBRE_ASIGNATURA,
              NOMBRE_PERIODO,
              COUNT(*) AS CANTIDAD_ALUMNOS
        FROM EXTRACCION_MATRICULA
        WHERE FECHA_MATRICULA = trunc(V_FECHA_INICIO)
        GROUP BY  FECHA_MATRICULA,
              CODIGO_SECCION,
              CANTIDAD_CUPOS,
              CODIGO_ESTADO_MATRICULA,
              ESTADO_MATRICULA,
              CODIGO_ASIGNATURA,
              NOMBRE_ASIGNATURA,
              NOMBRE_PERIODO;
      COMMIT;
      V_FECHA_INICIO := V_FECHA_INICIO + 1;
    END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    V_COMENTARIO := 'EXTRACCION FINALIZADA CON ERROR ' || SQLERRM;
    ROLLBACK;
END;
/


ROLLBACK;

select count(*) from EXTRACCION_MATRICULA;
select count(*) from TBL_MATRICULA;
select count(*) from TBL_MATRICULA where trunc(fecha_matricula) = trunc(sysdate);

SELECT trunc(FECHA_MATRICULA), COUNT(*)
FROM TBL_MATRICULA
GROUP BY trunc(FECHA_MATRICULA)
order by trunc(fecha_matricula);

SELECT trunc(FECHA_MATRICULA), COUNT(*)
FROM EXTRACCION_MATRICULA
GROUP BY trunc(FECHA_MATRICULA)
order by trunc(fecha_matricula);

commit;
CALL P_ETL_MATRICULA();

delete from EXTRACCION_MATRICULA
where trunc(fecha_matricula)>=trunc(sysdate-5);
commit;


SELECT  TO_CHAR(FECHA_MATRICULA, 'yyyy') AS ANIO,
        TO_CHAR(FECHA_MATRICULA, 'yyyy-MM') ANIO_MES,
        A.*
FROM DB_UNAH.EXTRACCION_MATRICULA A;

------------------------------------------------------------------------------------


DROP TABLE EXTRACCION_ALUMNOS;
create table EXTRACCION_ALUMNOS
(
  FECHA_PROCESO      NUMBER,
  CODIGO_ALUMNO      NUMBER         not null,
  NUMERO_CUENTA      VARCHAR2(11)   not null,
  PROMEDIO           NUMBER,
  NOMBRE             VARCHAR2(500),
  CORREO_ELECTRONICO VARCHAR2(500)  not null,
  DIRECCION          VARCHAR2(1000) not null,
  IDENTIDAD          VARCHAR2(20)   not null,
  TELEFONO           VARCHAR2(40)   not null,
  NOMBRE_GENERO      VARCHAR2(70)   not null,
  LUGAR_RESIDENCIA   VARCHAR2(500)  not null,
  LUGAR_NACIMIENTO   VARCHAR2(500)  not null,
  ESTADO_CIVIL       VARCHAR2(300)  not null
);

--Agilizar los filtros por la fecha de proceso
create index ALUMNOS_FECHA_PROCESO_index
  on EXTRACCION_ALUMNOS (FECHA_PROCESO);


create OR REPLACE PROCEDURE P_ETL_ALUMNOS AS
  V_HORA_INICIO TIMESTAMP;
  V_COMENTARIO VARCHAR2(2000);
  V_FECHA_PROCESO NUMBER;
BEGIN
  V_FECHA_PROCESO := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD'));
  DELETE
  FROM EXTRACCION_ALUMNOS
  WHERE FECHA_PROCESO = V_FECHA_PROCESO;
  INSERT INTO EXTRACCION_ALUMNOS(FECHA_PROCESO,
                                 CODIGO_ALUMNO,
                                 NUMERO_CUENTA,
                                 PROMEDIO,
                                 NOMBRE,
                                 CORREO_ELECTRONICO,
                                 DIRECCION,
                                 IDENTIDAD,
                                 TELEFONO,
                                 NOMBRE_GENERO,
                                 LUGAR_RESIDENCIA,
                                 LUGAR_NACIMIENTO,
                                 ESTADO_CIVIL)
    SELECT V_FECHA_PROCESO,
    A.CODIGO_ALUMNO,
    A.NUMERO_CUENTA,
    A.PROMEDIO,
    B.NOMBRE || ' ' || B.APELLIDO AS NOMBRE,
    B.CORREO_ELECTRONICO,
    B.DIRECCION,
    B.IDENTIDAD,
    B.TELEFONO,
    C.NOMBRE_GENERO,
    D.NOMBRE_LUGAR AS LUGAR_RESIDENCIA,
    E.NOMBRE_LUGAR AS LUGAR_NACIMIENTO,
    F.NOMBRE_ESTADO_CIVIL AS ESTADO_CIVIL
    FROM TBL_ALUMNOS A
    INNER JOIN TBL_PERSONAS B
    ON A.CODIGO_ALUMNO = B.CODIGO_PERSONA
    INNER JOIN TBL_GENEROS C
    ON B.CODIGO_GENERO = C.CODIGO_GENERO
    INNER JOIN TBL_LUGARES D
    ON B.CODIGO_LUGAR_RESIDENCIA = D.CODIGO_LUGAR
    INNER JOIN TBL_LUGARES E
    ON B.CODIGO_LUGAR_NACIMIENTO = E.CODIGO_LUGAR
    INNER JOIN TBL_ESTADOS_CIVILES F
    ON B.CODIGO_ESTADO_CIVIL = F.CODIGO_ESTADO_CIVIL;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    V_COMENTARIO := 'EXTRACCION FINALIZADA CON ERROR ' || SQLERRM;
    ROLLBACK;
END;


SELECT *
FROM TBL_ALUMNOS;
SELECT *
FROM EXTRACCION_ALUMNOS;

CALL P_ETL_ALUMNOS();




SELECT  TO_CHAR(FECHA_MATRICULA, 'yyyy') AS ANIO,
        TO_CHAR(FECHA_MATRICULA, 'yyyy-MM') ANIO_MES,
        TRUNC(FECHA_MATRICULA) FECHA,
        A.*
FROM EXTRACCION_MATRICULA A;

SELECT *
FROM EXTRACCION_MATRICULA
WHERE TRUNC(FECHA_MATRICULA) = TO_DATE('15/08/2019','DD/mm/yyyy');

COMMIT;



;


SELECT *
FROM EXTRACCION_MATRICULA;
SELECT*
FROM EXTRACCION_MATRICULA_RESUMEN;