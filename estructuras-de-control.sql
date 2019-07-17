drop table tmp;

create table tmp (
  valor integer
)


DECLARE
  V_Contador INTEGER:=1;
BEGIN
  LOOP
    INSERT INTO tmp(valor)
    VALUES (V_Contador);
    V_Contador:=V_Contador +1;
    EXIT WHEN V_Contador =1000000;
  END LOOP;
  commit;
END;


select *
from tmp
order by valor;


rollback;

truncate table tmp;



DECLARE
  V_Contador BINARY_INTEGER:=1;
BEGIN
  WHILE V_Contador <11 LOOP
    INSERT INTO tmp (Valor)
    VALUES (V_Contador);
    V_Contador:=V_Contador +1;
  END LOOP;
END;

select *
from tmp;


rollback;

BEGIN
  FOR V_Contador IN reverse 1..10 LOOP
    INSERT INTO tmp (Valor)
    VALUES (V_Contador);
  END LOOP;
END;



BEGIN
  DBMS_OUTPUT.PUT_LINE('Esto es un ejemplo.');
  GOTO Etiqueta_1;
  DBMS_OUTPUT.PUT_LINE('No hace el GOTO.');
  <<Etiqueta_1>>
  DBMS_OUTPUT.PUT_LINE('Entra en el GOTO');
END;


--No se puede saltar con GOTO al interior de otro bloque
begin
  GOTO etiqueta1;
  begin
    dbms_output.put_line('Bloque interno 1');
  end;
  begin
    <<etiqueta1>>
    dbms_output.put_line('Bloque interno 2');
  end;
end;


--No se puede saltar con GOTO al interior de un bucle
begin
  GOTO etiqueta1;

  ----

  WHILE condicion LOOP
    ----
    ---
    <<etiqueta1>>
  end loop;
end;


--No se puede saltar con GOTO al interior de un IF`
begin
  GOTO etiqueta1;

  ----

  if condicion then
    ----
    ---
    <<etiqueta1>>
  end if;
end;


begin
  <<ETIQUETAX>>
  dbms_output.put_line('hola mundo');
  GOTO ETIQUETAX;
end;


declare
  v_registro hr.employees%ROWTYPE;
  CURSOR c_empleados IS SELECT * FROM HR.EMPLOYEES;
begin
  open c_empleados;
  FETCH c_empleados INTO v_registro;
  dbms_output.put_line('NOMBRE: ' || v_registro.FIRST_NAME);
  close c_empleados;
end;