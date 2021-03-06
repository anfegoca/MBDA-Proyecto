
----------------------------CRUDE-------------------------------------------
CREATE OR REPLACE PACKAGE PC_CONSULTAS IS
    FUNCTION CO_CANT RETURN SYS_REFCURSOR;
    FUNCTION CO_TOT RETURN SYS_REFCURSOR;
    FUNCTION CO_INA RETURN SYS_REFCURSOR;
    FUNCTION CO_TINA RETURN SYS_REFCURSOR;
END PC_CONSULTAS;
/
create or replace PACKAGE PC_COMPETENCIAS IS
    PROCEDURE AD_COMPETENCIA(XNOMBRE IN VARCHAR2, XID_VID IN NUMBER, XID_EQUI IN VARCHAR2, XRESULTADO IN XMLTYPE, XINICIO IN DATE, XFECHA_G IN DATE);
    FUNCTION CO_COMPETENCIA RETURN SYS_REFCURSOR;
    
END PC_COMPETENCIAS;
/
create or replace PACKAGE PC_EQUIPOS IS
    PROCEDURE AD_EQUIPO(XNOMBRE IN VARCHAR2, XFUNDACION IN DATE, XREGION IN VARCHAR2, XWEB IN VARCHAR2, COACH IN VARCHAR2, XESTADO IN VARCHAR2 );
    PROCEDURE MO_COACH(XNOMBRE IN VARCHAR2, XAPODO IN VARCHAR2);
    PROCEDURE MO_NOMBRE(XNOMBRE IN VARCHAR2, NUEVO IN VARCHAR2);
    PROCEDURE MO_PAGINA(XNOMBRE IN VARCHAR2, XWEB IN VARCHAR2);
    PROCEDURE MO_PATROCINADOR(XNOMBRE IN VARCHAR2, NOMBREPAT IN VARCHAR2);
    FUNCTION CO_EQUIPO RETURN SYS_REFCURSOR;
END PC_EQUIPOS;
/
create or replace PACKAGE PC_JUGADORES IS
    PROCEDURE AD_JUGADOR(XNOMBRE IN VARCHAR2,XAPELLIDO IN VARCHAR2,XAPODO IN VARCHAR2,XEDAD IN NUMBER,XNACIONALIDAD IN VARCHAR2,XACTIVO IN CHAR,XID_EQUI IN VARCHAR2);
    PROCEDURE MO_APODO(XAPODO IN VARCHAR2, NUEVO IN VARCHAR2);
    PROCEDURE MO_EDAD(XAPODO IN VARCHAR2,XEDAD IN NUMBER);
    PROCEDURE MO_ESTADO(XAPODO IN VARCHAR2,XESTADO IN NUMBER);
    FUNCTION CO_JUGADOR RETURN SYS_REFCURSOR;

END PC_JUGADORES;
/
create or replace PACKAGE PC_COACHES IS
    PROCEDURE AD_COACH(XNOMBRE IN VARCHAR2,XAPELLIDO IN VARCHAR2,XAPODO IN VARCHAR2,XEDAD IN NUMBER,XNACIONALIDAD IN VARCHAR2);
    PROCEDURE MO_APODO(XAPODO IN VARCHAR2, NUEVO IN VARCHAR2);
    PROCEDURE MO_EDAD(XAPODO IN VARCHAR2,XEDAD IN NUMBER);
    FUNCTION CO_COACH RETURN SYS_REFCURSOR;

END PC_COACHES;
/
create or replace PACKAGE PC_PATROCINADORES IS
    PROCEDURE AD_PATROCINADOR(XNOMBRE IN VARCHAR2,XWEB IN VARCHAR2);
    PROCEDURE MO_WEB(XWEB IN VARCHAR2, NUEVO IN VARCHAR2);
    PROCEDURE MO_NOMBRE(XWEB IN VARCHAR2,NUEVO IN VARCHAR2);

END PC_PATROCINADORES;
/
CREATE OR REPLACE PACKAGE PC_PERFIL IS
    PROCEDURE AD_USUARIO (XNOMBRE IN VARCHAR2, XAPELLIDO IN VARCHAR2, XFECHANACI IN DATE, XCORREO IN VARCHAR2, XAPODO IN VARCHAR2, XCONTRASEÑA IN VARCHAR2);
    PROCEDURE MO_NOMBRE (XAPODO IN VARCHAR2, XNOMBRE IN VARCHAR2, XAPELLIDO IN VARCHAR2);
    PROCEDURE MO_CORREO (XAPODO IN VARCHAR2, XCORREO IN VARCHAR2);
    PROCEDURE MO_APODO (XAPODO IN VARCHAR2, NUEVO IN VARCHAR2);
    PROCEDURE EL_USUARIO (XAPODO IN VARCHAR2);
END PC_PERFIL;


/

----------------------------CRUDI-------------------------------------------
CREATE OR REPLACE PACKAGE BODY PC_CONSULTAS IS
FUNCTION CO_CANT RETURN SYS_REFCURSOR  IS CO_C SYS_REFCURSOR;
    BEGIN
    OPEN CO_C FOR
        SELECT * FROM 
        CANTCOMPE,CANTEQUI,CANTVIDEO;
    RETURN CO_C;
    END CO_CANT;

FUNCTION CO_TOT RETURN SYS_REFCURSOR  IS CO_T SYS_REFCURSOR;
    BEGIN
    OPEN CO_T FOR
        SELECT SUM(EQUIPOS)AS TOTAL FROM(
        SELECT * FROM CANTEQUI
        UNION ALL
        SELECT * FROM CANTCOMPE
        UNION ALL
        SELECT * FROM CANTVIDEO);
    RETURN CO_T;
    END CO_TOT;


FUNCTION CO_INA RETURN SYS_REFCURSOR  IS CO_I SYS_REFCURSOR;
    BEGIN
    OPEN CO_I FOR
        SELECT * FROM CONSULTAS WHERE (SYSDATE-FECHA) >= (5*365);
    RETURN CO_I;
    END CO_INA;

FUNCTION CO_TINA RETURN SYS_REFCURSOR  IS CO_TI SYS_REFCURSOR;
    BEGIN
    OPEN CO_TI FOR
        SELECT COUNT(*) FROM CONSULTAS WHERE (SYSDATE-FECHA) >= (5*365);
    RETURN CO_TI;
    END CO_TINA;

END PC_CONSULTAS;
/

create or replace PACKAGE BODY PC_COMPETENCIAS IS

PROCEDURE AD_COMPETENCIA (XNOMBRE IN VARCHAR2, XID_VID IN NUMBER, XID_EQUI IN VARCHAR2, XRESULTADO IN XMLTYPE, XINICIO IN DATE, XFECHA_G IN DATE) IS
    BEGIN
        INSERT INTO COMPETENCIAS (NOMBRE, ID_VID, ID_EQUI, RESULTADO, INICIO, FECHA_G) VALUES (XNOMBRE, XID_VID, XID_EQUI, XRESULTADO, XINICIO, XFECHA_G);
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo insertar la competencia');
    END;
FUNCTION CO_COMPETENCIA RETURN SYS_REFCURSOR  IS CO_COM SYS_REFCURSOR;
    BEGIN
    OPEN CO_COM FOR
        SELECT NOMBRE, LUGAR,INICIO,REGION,FECHA_G,RESULTADO INGRESO FROM COMPETENCIAS;
    RETURN CO_COM;
    END CO_COMPETENCIA;

END PC_COMPETENCIAS;

/
create or replace PACKAGE BODY PC_EQUIPOS IS

PROCEDURE AD_EQUIPO (XNOMBRE IN VARCHAR2, XFUNDACION IN DATE, XREGION IN VARCHAR2, XWEB IN VARCHAR2, COACH IN VARCHAR2, XESTADO IN VARCHAR2 ) IS
    X NUMBER;
    BEGIN
        SELECT ID INTO X FROM COACHES WHERE APODO=COACH; 
        INSERT INTO EQUIPOS (NOMBRE, FUNDACION, REGION, WEB, ID_COA, ESTADO) VALUES (XNOMBRE, XFUNDACION, XREGION, XWEB, X,'1');
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo insertar el equipo');
    END;
    
PROCEDURE MO_COACH(XNOMBRE IN VARCHAR2 , XAPODO IN VARCHAR2) IS
    X NUMBER;
    BEGIN
        SELECT ID INTO X FROM COACHES WHERE NOMBRE=XNOMBRE;
        UPDATE EQUIPOS SET ID_COA=X WHERE ID_COA=X;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo actualizar el coach del equipo');
    END;
PROCEDURE MO_NOMBRE(XNOMBRE IN VARCHAR2, NUEVO IN VARCHAR2) IS
    BEGIN
        UPDATE EQUIPOS SET NOMBRE=NUEVO WHERE NOMBRE=XNOMBRE;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el nombre del equipo');
    END;
PROCEDURE MO_PAGINA(XNOMBRE IN VARCHAR2, XWEB IN VARCHAR2) IS
    BEGIN
        UPDATE EQUIPOS SET WEB=XWEB WHERE NOMBRE=XNOMBRE;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar la pagina web');
    END;
PROCEDURE MO_PATROCINADOR(XNOMBRE IN VARCHAR2, NOMBREPAT IN VARCHAR2) IS
    X NUMBER;
    BEGIN
        SELECT ID INTO X FROM PATROCINADORES WHERE NOMBREPAT=NOMBRE;
        UPDATE PATROCINIOS SET ID_PAT=X WHERE ID_EQUI=XNOMBRE;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el patrocinador');
    END;
    FUNCTION CO_EQUIPO RETURN SYS_REFCURSOR  IS CO_EQ SYS_REFCURSOR;
    BEGIN
        OPEN CO_EQ FOR
            SELECT NOMBRE, FUNDACION,REGION,WEB,ESTADO INGRESO FROM EQUIPOS;
        RETURN CO_EQ;
    END CO_EQUIPO;
    
END PC_EQUIPOS;
/

create or replace PACKAGE BODY PC_JUGADORES IS
    PROCEDURE AD_JUGADOR(XNOMBRE IN VARCHAR2,XAPELLIDO IN VARCHAR2,XAPODO IN VARCHAR2,XEDAD IN NUMBER,XNACIONALIDAD IN VARCHAR2,XACTIVO IN CHAR,XID_EQUI IN VARCHAR2) IS
    BEGIN
        INSERT INTO JUGADORES  (NOMBRE,APELLIDO,APODO,EDAD,NACIONALIDAD,ACTIVO,ID_EQUI) VALUES (XNOMBRE,XAPELLIDO,XAPODO,XEDAD,XNACIONALIDAD,'1',XID_EQUI);
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo adicionar el jugador');
    END;
    PROCEDURE MO_APODO(XAPODO IN VARCHAR2, NUEVO IN VARCHAR2) IS
    BEGIN
        UPDATE JUGADORES SET APODO=NUEVO WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el apodo del jugador');
    END;
    PROCEDURE MO_EDAD(XAPODO IN VARCHAR2, XEDAD IN NUMBER) IS
    BEGIN
        UPDATE JUGADORES SET EDAD=XEDAD WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar la edad');        
    END; 
    PROCEDURE MO_ESTADO(XAPODO IN VARCHAR2, XESTADO IN NUMBER) IS
    BEGIN
        UPDATE JUGADORES SET ACTIVO=XESTADO WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el estado');        
    END;
    FUNCTION CO_JUGADOR RETURN SYS_REFCURSOR  IS CO_JU SYS_REFCURSOR;
    BEGIN
    OPEN CO_JU FOR
        SELECT NOMBRE, APELLIDO, APODO, EDAD, NACIONALIDAD, ROL, ACTIVO, INGRESO FROM JUGADORES;
    RETURN CO_JU;
    END CO_JUGADOR;

END PC_JUGADORES;
/

create or replace PACKAGE BODY PC_COACHES IS
    PROCEDURE AD_COACH(XNOMBRE IN VARCHAR2,XAPELLIDO IN VARCHAR2,XAPODO IN VARCHAR2,XEDAD IN NUMBER,XNACIONALIDAD IN VARCHAR2) IS
    BEGIN
        INSERT INTO COACHES  (NOMBRE,APELLIDO,APODO,EDAD,NACIONALIDAD) VALUES (XNOMBRE,XAPELLIDO,XAPODO,XEDAD,XNACIONALIDAD);
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo adicionar el coach');
    END;
    PROCEDURE MO_APODO(XAPODO IN VARCHAR2, NUEVO IN VARCHAR2) IS
    BEGIN
        UPDATE COACHES SET APODO=NUEVO WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el apodo del coach');
    END;
    PROCEDURE MO_EDAD(XAPODO IN VARCHAR2, XEDAD IN NUMBER) IS
    BEGIN
        UPDATE COACHES SET EDAD=XEDAD WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar la edad');        
    END;
    FUNCTION CO_COACH RETURN SYS_REFCURSOR  IS CO_COA SYS_REFCURSOR;
    BEGIN
    OPEN CO_COA FOR
        SELECT NOMBRE, APELLIDO, EDAD, NACIONALIDAD, INGRESO FROM COACHES;
    RETURN CO_COA;
    END CO_COACH;

END PC_COACHES;
/
create or replace PACKAGE BODY PC_PATROCINADORES IS
    PROCEDURE AD_PATROCINADOR(XNOMBRE IN VARCHAR2,XWEB IN VARCHAR2) IS
    BEGIN
        INSERT INTO PATROCINADORES (NOMBRE,WEB) VALUES (XNOMBRE,XWEB);
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo adicionar el patrocinador');
    END;
    PROCEDURE MO_WEB(XWEB IN VARCHAR2, NUEVO IN VARCHAR2) IS
    BEGIN
        UPDATE PATROCINADORES SET WEB=XWEB WHERE WEB=XWEB;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar la pagina web');
    END;
    PROCEDURE MO_NOMBRE(XWEB IN VARCHAR2, NUEVO IN VARCHAR2) IS
    BEGIN
        UPDATE PATROCINADORES SET NOMBRE=NUEVO WHERE WEB=XWEB;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar la edad');        
    END; 

END PC_PATROCINADORES;
/
    
CREATE OR REPLACE PACKAGE BODY PC_PERFIL IS

PROCEDURE AD_USUARIO (XNOMBRE IN VARCHAR2, XAPELLIDO IN VARCHAR2, XFECHANACI IN DATE, XCORREO IN VARCHAR2, XAPODO IN VARCHAR2, XCONTRASEÑA IN VARCHAR2) IS
    BEGIN
        INSERT INTO USUARIOS (NOMBRE, CORREO, APODO, FECHANACI, APELLIDO, CONTRASEÑA) VALUES (XNOMBRE, XCORREO, XAPODO, XFECHANACI, XAPELLIDO, XCONTRASEÑA);
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo realizar el registro');
    END;
    
PROCEDURE MO_NOMBRE (XAPODO IN VARCHAR2, XNOMBRE IN VARCHAR2, XAPELLIDO IN VARCHAR2) IS
    BEGIN
        UPDATE USUARIOS SET NOMBRE=XNOMBRE, APELLIDO=XAPELLIDO WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el nombre');
    END;

PROCEDURE MO_CORREO (XAPODO IN VARCHAR2, XCORREO IN VARCHAR2) IS
    BEGIN
        UPDATE USUARIOS SET CORREO=XCORREO WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el correo');
    END;
    
PROCEDURE MO_APODO (XAPODO IN VARCHAR2, NUEVO IN VARCHAR2) IS
    BEGIN
        UPDATE USUARIOS SET APODO=NUEVO WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo modificar el apodo');
    END;
    
PROCEDURE EL_USUARIO (XAPODO IN VARCHAR2) IS
    BEGIN
        DELETE FROM USUARIOS WHERE APODO=XAPODO;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo eliminar el usuario');
    END;
    
END PC_PERFIL;

/*
-----------------------------XCRUD------------------------------
DROP PACKAGE PC_CONSULTAS;

DROP PACKAGE PC_COMPETENCIAS;

DROP PACKAGE PC_EQUIPOS;

DROP PACKAGE PC_JUGADORES;

DROP PACKAGE PC_COACHES;

DROP PACKAGE PC_PATROCINADORES;

DROP PACKAGE PC_USUARIOS;






SELECT PC_CONSULTAS.CO_CANT FROM DUAL;

SELECT PC_CONSULTAS.CO_TOT FROM DUAL;
*/