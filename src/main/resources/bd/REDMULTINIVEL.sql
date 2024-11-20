SET SERVEROUTPUT ON;

-- Gestion de la entidad venta


-- Secuencias

    DROP SEQUENCE cart_seq;

    CREATE SEQUENCE cart_seq
    START WITH 1
    INCREMENT BY 1;


    DROP SEQUENCE CART_PRODUCT_DETAIL_SEQ;

    CREATE SEQUENCE CART_PRODUCT_DETAIL_SEQ
    START WITH 1
    INCREMENT BY 1;
    
    DROP SEQUENCE CART_PRODUCT_DETAIL_SEQ;

    CREATE SEQUENCE SALE_SEQ
    START WITH 1
    INCREMENT BY 1;
    
    CREATE SEQUENCE SHIPPING_SEQ
    START WITH 1
    INCREMENT BY 1;
    
    CREATE SEQUENCE COMMISSION_SEQ
    START WITH 1
    INCREMENT BY 1;
--Metodos comprar ahora: este es para comprar un único producto producto 
/*
Agregar al carrito:

-Se debe crear un carrito 
-luego anexar el producto al carrito con su respectiva cantidad mediante la tabla intermedio

Comprar un todo lo de un carrito:
- Se debe de crear la venta 
- se agrega el carrito y se asigna el estado de la venta
- se crea un envio y segun el estado de la venta se cambia el estado del envio
*/
--Evitar duplicados en el carrito
CREATE OR REPLACE TRIGGER TRG_PREVENT_DUPLICATE_PRODUCTS
BEFORE INSERT ON CART_PRODUCT_DETAIL
FOR EACH ROW
DECLARE
v_count NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count
FROM CART_PRODUCT_DETAIL
WHERE CART_ID = :NEW.CART_ID AND PRODUCT_ID = :NEW.PRODUCT_ID;

IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'El producto ya está en el carrito.');
END IF;
END;
/

--Verificar que al registrarse, se verifique los duplicados de correo
CREATE OR REPLACE TRIGGER TRG_VALIDATE_EMAIL
BEFORE INSERT OR UPDATE ON AFFILIATE
                            FOR EACH ROW
DECLARE
v_count NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count
FROM AFFILIATE
WHERE EMAIL = :NEW.EMAIL AND AFFILIATE_ID != :NEW.AFFILIATE_ID;

IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'El correo electrónico ya está registrado.');
END IF;
END;

--Actualizar Estado de Envio
CREATE OR REPLACE TRIGGER TRG_UPDATE_SHIPPING_STATUS
AFTER INSERT OR UPDATE ON SHIPPING
                           FOR EACH ROW
BEGIN
  IF :NEW.ESTIMATED_DELIVERY_DATE < SYSDATE THEN
UPDATE SHIPPING
SET STATUS_SHIPPING_ID = 3  -- Entregado
WHERE SHIPPING_ID = :NEW.SHIPPING_ID;
END IF;
END;
/

--Generar Comision despues de venta
CREATE OR REPLACE TRIGGER TRG_GENERATE_COMMISSION
AFTER INSERT ON SALE
FOR EACH ROW
DECLARE
v_affiliate_id NUMBER;
  v_parent_id NUMBER;
  v_commission_value NUMBER;
BEGIN
SELECT CART.AFFILIATE_ID INTO v_affiliate_id
FROM CART WHERE CART_ID = :NEW.CART_ID;

v_parent_id := v_affiliate_id;

FOR i IN 1..4 LOOP
    IF v_parent_id IS NULL THEN
      EXIT;
END IF;

    v_commission_value := :NEW.FINAL_PRICE * CASE i
      WHEN 1 THEN 0.10
      WHEN 2 THEN 0.05
      WHEN 3 THEN 0.03
      ELSE 0.01
END;

INSERT INTO COMMISSION (COMMISSION_ID, VALOR, SALE_ID, AFFILIATE_ID)
VALUES (SEQ_COMMISSION_ID.NEXTVAL, v_commission_value, :NEW.SALE_ID, v_parent_id);

SELECT AFFILIATE_PARENT_ID INTO v_parent_id
FROM AFFILIATE
WHERE AFFILIATE_ID = v_parent_id;
END LOOP;
END;
/

--Actualizar total carrito
CREATE OR REPLACE TRIGGER trg_update_cart_total
AFTER INSERT OR UPDATE OR DELETE ON CART_PRODUCT_DETAIL
    FOR EACH ROW
DECLARE
v_total NUMBER;
BEGIN
    -- Calcular el nuevo total del carrito
SELECT COALESCE(SUM(TOTAL_AMOUNT), 0)
INTO v_total
FROM CART_PRODUCT_DETAIL
WHERE CART_ID = :NEW.CART_ID;

-- Actualizar el total en la tabla CART
UPDATE CART
SET TOTAL = v_total
WHERE CART_ID = :NEW.CART_ID;
END;
/

---Trigger para desactivar carrito
CREATE OR REPLACE TRIGGER trg_deactivate_cart_on_sale
AFTER INSERT ON SALE
FOR EACH ROW
BEGIN
    -- Desactivar el carrito asociado a la venta
UPDATE CART
SET ACTIVATE = 0
WHERE CART_ID = :NEW.CART_ID;
END;

--Actulizar total carrito despues de quitar un prodcuto
    CREATE OR REPLACE TRIGGER TRG_UPDATE_CART_TOTAL_REMOVE
AFTER DELETE ON CART_PRODUCT_DETAIL
FOR EACH ROW
BEGIN
UPDATE CART
SET TOTAL = TOTAL - :OLD.TOTAL_AMOUNT
WHERE CART_ID = :OLD.CART_ID;
END;
/





--
---Calular nivel jerarquico del afiliado
CREATE OR REPLACE TRIGGER trg_update_hierarchical_level
AFTER INSERT ON AFFILIATE
FOR EACH ROW
DECLARE
v_num_children NUMBER;
    v_new_level_id NUMBER;
BEGIN
    -- Contar el número de hijos del afiliado padre
SELECT COUNT(*)
INTO v_num_children
FROM AFFILIATE
WHERE AFFILIATE_PARENT_ID = :NEW.AFFILIATE_PARENT_ID;

-- Obtener el nivel jerárquico más alto alcanzable según el número de hijos
SELECT MAX(HIERARCHICAL_LEVEL_ID)
INTO v_new_level_id
FROM HIERARCHICAL_LEVEL
WHERE AFFILIATE_REQUIREMENT <= v_num_children;

-- Actualizar el nivel jerárquico del afiliado padre
UPDATE AFFILIATE
SET HIERARCHICAL_LEVEL_ID = v_new_level_id
WHERE AFFILIATE_ID = :NEW.AFFILIATE_PARENT_ID;
END;

    --Trigger para reducir el stock al realizar una venta
    CREATE OR REPLACE TRIGGER TRG_UPDATE_PRODUCT_STOCK_AFTER_SALE
AFTER INSERT ON SALE
FOR EACH ROW
BEGIN
  -- Iterar sobre los productos vendidos en la venta asociada
FOR product IN (
    SELECT PRODUCT_ID, QUANTITY
    FROM CART_PRODUCT_DETAIL
    WHERE CART_ID = :NEW.CART_ID
  )
  LOOP
    -- Reducir el stock del producto
UPDATE PRODUCT
SET STOCK_QUANTITY = STOCK_QUANTITY - product.QUANTITY
WHERE PRODUCT_ID = product.PRODUCT_ID;
END LOOP;
END;
/












--Nuevo procedimiento del carrito para agregar
CREATE OR REPLACE PROCEDURE agregar_producto (
    codproducto NUMBER,
    cant NUMBER
) AS
    existencia NUMBER;
    transito NUMBER;
    yaencarro NUMBER;
    total NUMBER;
BEGIN
    -- Verificar si el producto existe
    IF (SELECT COUNT(*) FROM PRODUCT WHERE PRODUCT_ID = codproducto) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: el producto no existe');
END IF;

    -- Obtener la cantidad disponible en el inventario
SELECT STOCK_QUANTITY INTO existencia
FROM PRODUCT
WHERE PRODUCT_ID = codproducto;

-- Obtener la cantidad en tránsito (en carritos activos)
IF (SELECT COUNT(*) FROM CART_PRODUCT_DETAIL WHERE PRODUCT_ID = codproducto) > 0 THEN
SELECT SUM(QUANTITY) INTO transito
FROM CART_PRODUCT_DETAIL
WHERE PRODUCT_ID = codproducto;
ELSE
        transito := 0;
END IF;

    -- Verificar si hay suficiente inventario disponible
    IF (existencia - transito < cant) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: No hay suficientes existencias para el producto indicado');
END IF;

    -- Verificar si el producto ya está en el carrito activo del usuario
    IF (SELECT COUNT(*)
        FROM CART c
                 JOIN CART_PRODUCT_DETAIL d ON c.CART_ID = d.CART_ID
        WHERE c.ACTIVATE = 1 AND d.PRODUCT_ID = codproducto) > 0 THEN
SELECT QUANTITY INTO yaencarro
FROM CART c
         JOIN CART_PRODUCT_DETAIL d ON c.CART_ID = d.CART_ID
WHERE c.ACTIVATE = 1 AND d.PRODUCT_ID = codproducto;

-- Eliminar la entrada previa del carrito
DELETE FROM CART_PRODUCT_DETAIL
WHERE CART_ID = (SELECT CART_ID FROM CART WHERE ACTIVATE = 1)
  AND PRODUCT_ID = codproducto;
ELSE
        yaencarro := 0;
END IF;

    -- Calcular la nueva cantidad total
    total := yaencarro + cant;

    -- Insertar el producto en el carrito activo
INSERT INTO CART_PRODUCT_DETAIL (
    CART_PRODUCT_DETAIL_ID,
    QUANTITY,
    TOTAL_AMOUNT,
    CART_ID,
    PRODUCT_ID
)
VALUES (
           CART_PRODUCT_DETAIL_SEQ.NEXTVAL,
           total,
           total * (SELECT SALE_PRICE FROM PRODUCT WHERE PRODUCT_ID = codproducto),
           (SELECT CART_ID FROM CART WHERE ACTIVATE = 1),
           codproducto
       );

-- Mostrar mensaje de confirmación
DBMS_OUTPUT.PUT_LINE('Procedimiento: Producto agregado al carrito con éxito');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El producto no existe');
WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error desconocido al agregar el producto al carrito');
END;



-------------------------------------------------------------------------------------------------------------------------------
--FUNCIONES
-------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION F_CALCULAR_TOTAL_CARRITO (CARTID IN NUMBER)
RETURN NUMBER
IS
    V_CONTADOR NUMBER;
BEGIN
    
    SELECT SUM(TOTAL_AMOUNT) 
    INTO V_CONTADOR
    FROM CART_PRODUCT_DETAIL 
    WHERE CART_ID = CARTID
    GROUP BY CART_ID;
 
    RETURN V_CONTADOR;
END;

--Test
--Parametro1 :CARTID

begin
DBMS_OUTPUT.PUT_LINE(F_CALCULAR_TOTAL_CARRITO(81));
end;

select * from cart;


--Funcion para verificar si un carrito ya contiene un producto
CREATE OR REPLACE FUNCTION F_BUSCAR_PRODUCTO_EN_CARRITO (PRODUCID IN NUMBER, CARTID NUMBER)
RETURN NUMBER
IS
    V_CONTADOR NUMBER;
BEGIN
    
    SELECT NVL(SUM(PRODUCT_ID),0) 
    INTO V_CONTADOR
    FROM CART_PRODUCT_DETAIL 
    WHERE CART_ID = CARTID AND PRODUCT_ID = PRODUCID
    GROUP BY CART_ID;
    
    RETURN V_CONTADOR;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;  -- Devuelve 0 si no se encuentran datos
    WHEN OTHERS THEN
        -- Manejo genérico de errores
        RETURN -1;  
END;

--Test
--Parametro 1: PRODUCID
--Parametro 2: CARTID
BEGIN
   DBMS_OUTPUT.PUT_LINE(F_BUSCAR_PRODUCTO_EN_CARRITO(1,21)); 
END;

--Este metodo calcula el porcentaje total de descuento para cierta venta que realice un afiliado
CREATE OR REPLACE FUNCTION COMISIONES_TOTALES_PARA_VENTA(
    AFFILIATEID IN NUMBER
)
RETURN NUMBER
IS
    V_PORCENTAJE_DESCUENTO NUMBER;
    AFFILIATEID_PARENT NUMBER := 0;
    AFFILIATEID_ACTUAL NUMBER := AFFILIATEID;
    i NUMBER := 0;  -- Inicialización de 'i'
    V_BANDERA NUMBER := 0;
BEGIN

    --Obtiene el parent del afiliado actual
    SELECT AFFILIATE_PARENT_ID
    INTO AFFILIATEID_PARENT
    FROM AFFILIATE
    WHERE AFFILIATE_ID = AFFILIATEID_ACTUAL;

    -- Obtener el porcentaje de descuento
    SELECT DISCOUNT_PRODUCT 
    INTO V_PORCENTAJE_DESCUENTO
    FROM HIERARCHICAL_LEVEL
    WHERE HIERARCHICAL_LEVEL_ID = (
        SELECT HIERARCHICAL_LEVEL_ID 
        FROM AFFILIATE 
        WHERE AFFILIATE_ID = AFFILIATEID_ACTUAL
    );
    
    -- Ciclo WHILE
    WHILE i < 2 AND V_BANDERA = 0 LOOP
        -- Verificación de si 'AFFILIATEID_PARENT' no es NULL
        IF AFFILIATEID_PARENT IS NOT NULL THEN 
        
            SELECT AFFILIATE_PARENT_ID
            INTO AFFILIATEID_PARENT
            FROM AFFILIATE
            WHERE AFFILIATE_ID = AFFILIATEID_ACTUAL;
            
            AFFILIATEID_ACTUAL := AFFILIATEID_PARENT;
            
            
            CASE i
                WHEN 0 THEN
                    V_PORCENTAJE_DESCUENTO := V_PORCENTAJE_DESCUENTO + 3;
                WHEN 1 THEN
                    V_PORCENTAJE_DESCUENTO := V_PORCENTAJE_DESCUENTO + 2;
                WHEN 2 THEN
                    V_PORCENTAJE_DESCUENTO := V_PORCENTAJE_DESCUENTO + 1;
                
            END CASE;
            
        ELSE 
            V_BANDERA := 1;
        END IF;
        
        i := i + 1;  -- Incrementar el contador
    END LOOP;    
    
    -- Devolver el valor calculado (ajusta el valor de retorno según tu lógica)
    RETURN V_PORCENTAJE_DESCUENTO;
END;
/
--Test
-- parametro 1: AFFILIATEID
BEGIN
   DBMS_OUTPUT.PUT_LINE(COMISIONES_TOTALES_PARA_VENTA(5)); 
END;


CREATE OR REPLACE FUNCTION F_AGREGAR_AL_CARRITO(
AFFILIATE_ID IN NUMBER,
PRODUCT_ID IN NUMBER,
QUANTITY IN NUMBER
)
RETURN NUMBER
IS    
    V_CID NUMBER;
    V_PID NUMBER := PRODUCT_ID;
    V_PPRECIO NUMBER;
    V_AFFID NUMBER := AFFILIATE_ID;
    V_FLAG NUMBER;
    V_FLAG_PRODUCTO NUMBER;
    V_PPDID NUMBER := CART_PRODUCT_DETAIL_SEQ.NEXTVAL;
    
BEGIN
    --Se obtiene el precio de venta del producto para el calculo de los totales
    SELECT SALE_PRICE 
    INTO V_PPRECIO 
    FROM PRODUCT 
    WHERE PRODUCT_ID = V_PID;
    
    -- Validamos que hay carritos de compra activos para el usuario, de otra forma creamos uno
    SELECT COUNT(*)
    INTO V_FLAG
    FROM CART
    WHERE AFFILIATE_ID = V_AFFID AND ACTIVATE = 1 ;
    
    IF V_FLAG = 0 THEN 
        V_CID := CART_SEQ.NEXTVAL;  --Trabajamos con el nuevo id del nuevo carrito
        INSERT INTO CART (
            CART_ID,
            TOTAL,
            ACTIVATE,
            AFFILIATE_ID
        ) 
        VALUES(
            V_CID,
            0, 
            1, --- Se activa el carrito
            V_AFFID
        );
        
        --Debido a que es un carrito nuevo podemos agregar el primer producto sin inconvenientes
        INSERT INTO CART_PRODUCT_DETAIL(
            CART_PRODUCT_DETAIL_ID,
            QUANTITY,
            TOTAL_AMOUNT,
            CART_ID,
            PRODUCT_ID
        )
        VALUES (
            CART_SEQ.NEXTVAL,
            QUANTITY,
            V_PPRECIO*QUANTITY,
            V_CID,
            V_PID 
        );
    ELSE
        --Identidicamos cual es el carrito activo del cliente y lo asignamos a V_CID
        SELECT CART_ID 
        INTO V_CID 
        FROM CART
        WHERE ACTIVATE = 1 AND AFFILIATE_ID = V_AFFID;

        --Buscamos si en el carrito ya se encuentra añadido el mismo producto, con el fin de actualizar sus valores y no pegar otro registro
        V_FLAG_PRODUCTO := F_BUSCAR_PRODUCTO_EN_CARRITO(V_PID, V_CID);
        
        IF V_FLAG_PRODUCTO > 0 THEN

            INCREMENTAR_PRODUCTOS_EN_CARRITO(V_CID, V_PID, QUANTITY);
            
        ELSE
            --De lo contrario añadimos un nuevo producto
            INSERT INTO CART_PRODUCT_DETAIL(
                CART_PRODUCT_DETAIL_ID,
                QUANTITY,
                TOTAL_AMOUNT,
                CART_ID,
                PRODUCT_ID
            )
            VALUES (
                V_PPDID,
                QUANTITY,
                V_PPRECIO*QUANTITY,
                V_CID,
                V_PID 
            );
        END IF;
        
    END IF;
    --Se actualiza el precio total de lo que va en el carrito
    ACTUALIZAR_TOTAL_CARRITO(V_CID);
    
    RETURN V_PPDID;
    
END;

--Test
--PARAMETRO 1: AFFILIATE_ID
--PARAMETRO 2: PRODUCT_ID
--PARAMETRO 3: QUANTITY

BEGIN
   DBMS_OUTPUT.PUT_LINE(F_AGREGAR_AL_CARRITO(1,2,2)); 
END;

SELECT * FROM CART;

SELECT * FROM AFFILIATE;

select * from CART_PRODUCT_DETAIL;

--Este metodo me permite comprar un producto de forma instantanea
CREATE OR REPLACE FUNCTION F_COMPRAR_CARRITO(
AFFILIATE_ID IN NUMBER
)
RETURN NUMBER
IS    
    V_CID NUMBER;
    V_SHID NUMBER := SHIPPING_SEQ.NEXTVAL;
    V_DIRECCION VARCHAR(50);
    V_AFFID NUMBER := AFFILIATE_ID;
    V_PORCENTAJE_DESCUENTO NUMBER := 0;
    V_SALEID NUMBER:= SALE_SEQ.NEXTVAL;
    V_VALOR_VENTA NUMBER;
    V_CARRITOACTIVO NUMBER;
    V_SALIDA NUMBER := 0;
    
BEGIN
    
    SELECT COUNT(*) AS ACTIVO
    INTO V_CARRITOACTIVO
    FROM CART
    WHERE ACTIVATE = 1 AND AFFILIATE_ID = V_AFFID; 

    IF NVL(V_CARRITOACTIVO,0) != 0 THEN
        
        --Se obtiene el codigo del carrito
        SELECT CART_ID
        INTO V_CID
        FROM CART
        WHERE AFFILIATE_ID = V_AFFID AND ACTIVATE = 1;
        
        --Se obtiene la dirección del usuario para el envio
        SELECT ADRRESS 
        INTO V_DIRECCION
        FROM AFFILIATE
        WHERE AFFILIATE_ID = V_AFFID;
        
        --Creamos el envio y su estado va ser en proceso, esto debido a que necesita que se confirme la compra
        INSERT INTO SHIPPING (
            SHIPPING_ID,    
            DATE_CHANGED,  
            COMMENTS,
            ESTIMATED_DELIVERY_DATE,  
            ADRRESS,
            STATUS_SHIPPING_ID
        )
        VALUES (
            V_SHID,
            SYSDATE + 20,  -- Esto habilita 20 días de cambio 
            '',
            SYSDATE + 15,
            V_DIRECCION,
            1
        );
        
        --Calculamos cual es el valor porcentual que será descontado por todas las comisiones 
        V_PORCENTAJE_DESCUENTO := COMISIONES_TOTALES_PARA_VENTA(V_AFFID);
        V_VALOR_VENTA := F_CALCULAR_TOTAL_CARRITO(V_CID);
        
        --Ahora vamos a crear la compra
        INSERT INTO SALE (
            SALE_ID, 
            DATE_SALE,
            ORIGINAL_PRICE,
            FINAL_PRICE,
            SHIPPING_ID, 
            STATUS_SALE_ID,
            CART_ID       
        )
        VALUES (
            V_SALEID,
            SYSDATE,
            V_VALOR_VENTA,
            V_VALOR_VENTA -(V_VALOR_VENTA*(V_PORCENTAJE_DESCUENTO/100)),
            V_SHID,
            2,  -- Este estado nos indica de la compra está en transito
            V_CID
        );
        --Desactivamos el carrito
        UPDATE CART
        SET ACTIVATE = 0
        WHERE CART_ID  = V_CID;
        
        --Generamos todas las comisiones correspondientes
        GENERAR_COMISIONES_DE_VENTA(V_AFFID, V_SALEID);
        
        V_SALIDA := V_SALEID;
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('El afiliado no tiene carritos activos');
    END IF;

    RETURN V_SALIDA;
    
END;

--Test
--Parametro 1: AFFILIATE_ID
begin
    DBMS_OUTPUT.PUT_LINE(F_COMPRAR_CARRITO(1));
end;


select * from sale;

select * from cart;
-------------------------------------------------------------------------------------------------------------------------------
--PROCEDIMIENTOS
-------------------------------------------------------------------------------------------------------------------------------
--Este método nos permite la actualización del total del carrito
CREATE OR REPLACE PROCEDURE ACTUALIZAR_TOTAL_CARRITO(
V_CARRITOID NUMBER
)
AS
BEGIN
    UPDATE CART
    SET TOTAL = F_CALCULAR_TOTAL_CARRITO(V_CARRITOID)
    WHERE CART_ID = V_CARRITOID;    
END;
--Este metodo incrementa un producto de un carrito específico, para que funcione el metodo el carrito debe de estar creado
CREATE OR REPLACE PROCEDURE INCREMENTAR_PRODUCTOS_EN_CARRITO(
CARTID IN NUMBER,
PRODUCTID IN NUMBER,
QTY IN NUMBER
)
AS
    V_PPRECIO NUMBER;
BEGIN

    --Se obtiene el precio de venta del producto
    SELECT SALE_PRICE 
    INTO V_PPRECIO 
    FROM PRODUCT 
    WHERE PRODUCT_ID = PRODUCTID;

    UPDATE CART_PRODUCT_DETAIL 
    SET QUANTITY = QUANTITY + QTY, 
        TOTAL_AMOUNT = TOTAL_AMOUNT + (V_PPRECIO * QTY)
    WHERE PRODUCT_ID = PRODUCTID AND CART_ID = CARTID;
    
    ACTUALIZAR_TOTAL_CARRITO(CARTID);
    
    EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error inesperado: ' || SQLERRM);

END;



--Test
-- parametro 1: CARTID
-- parametro 2: PRODUCTID
-- parametro 3: QTY

EXECUTE INCREMENTAR_PRODUCTOS_EN_CARRITO(1, 1, 8);

SELECT * FROM CART_PRODUCT_DETAIL;

--Este metodo incrementa un producto de un carrito específico, para que funcione el metodo el carrito debe de estar creado
CREATE OR REPLACE PROCEDURE DECREMENTAR_PRODUCTOS_EN_CARRITO(
CARTID IN NUMBER,
PRODUCTID IN NUMBER,
QTY IN NUMBER
)
AS
    V_PPRECIO NUMBER;
    V_QTY_ACTUAL NUMBER;
    
BEGIN

    SELECT SALE_PRICE 
    INTO V_PPRECIO 
    FROM PRODUCT 
    WHERE PRODUCT_ID = PRODUCTID;

    --Calculamos la cantidad actual del registro
    SELECT QUANTITY
    INTO V_QTY_ACTUAL
    FROM CART_PRODUCT_DETAIL
    WHERE CART_ID =CARTID AND PRODUCT_ID = PRODUCTID ;

    IF (V_QTY_ACTUAL - QTY) >= 1 THEN
    
        UPDATE CART_PRODUCT_DETAIL 
        SET QUANTITY = QUANTITY - QTY, 
        TOTAL_AMOUNT = TOTAL_AMOUNT - (V_PPRECIO * QTY)
        WHERE PRODUCT_ID = PRODUCTID AND CART_ID = CARTID;
        
    ELSE
    
        UPDATE CART_PRODUCT_DETAIL 
        SET QUANTITY = 1, 
        TOTAL_AMOUNT = V_PPRECIO 
        WHERE PRODUCT_ID = PRODUCTID AND CART_ID = CARTID;
    
    END IF;

        ACTUALIZAR_TOTAL_CARRITO(CARTID);
        
    EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error inesperado: ' || SQLERRM);

END;



--Test
-- parametro 1: CARTID
-- parametro 2: PRODUCTID
-- parametro 3: QTY

EXECUTE DECREMENTAR_PRODUCTOS_EN_CARRITO(1, 1, 9);

SELECT * FROM CART_PRODUCT_DETAIL;

--Este método nos permite generar todas las comisiones de una venta especifica
CREATE OR REPLACE PROCEDURE GENERAR_COMISIONES_DE_VENTA( 
AFFILIATEID IN NUMBER,
SALEID IN NUMBER
)
AS
    V_PORCENTAJE_DESCUENTO NUMBER;
    AFFILIATEID_PARENT NUMBER := 0;
    i NUMBER := 0;  -- Inicialización de 'i'
    V_BANDERA NUMBER := 0;
    V_VALOR_VENTA NUMBER;
BEGIN

    --Obtenemos el valor de la venta
    SELECT ORIGINAL_PRICE 
    INTO V_VALOR_VENTA
    FROM SALE
    WHERE SALE_ID = SALEID;

    --Obtiene el parent del afiliado actual
    SELECT AFFILIATE_PARENT_ID
    INTO AFFILIATEID_PARENT
    FROM AFFILIATE
    WHERE AFFILIATE_ID = AFFILIATEID;

    -- Obtener el porcentaje de descuento
    SELECT DISCOUNT_PRODUCT 
    INTO V_PORCENTAJE_DESCUENTO
    FROM HIERARCHICAL_LEVEL
    WHERE HIERARCHICAL_LEVEL_ID = (
        SELECT HIERARCHICAL_LEVEL_ID 
        FROM AFFILIATE 
        WHERE AFFILIATE_ID = AFFILIATEID
    );
    
    --Generamos la comision del afiliado que hace la compra directa
    INSERT INTO COMMISSION (
        COMMISSION_ID,
        VALOR,
        SALE_ID, 
        AFFILIATE_ID
    )
    VALUES(
        COMMISSION_SEQ.NEXTVAL,
        V_VALOR_VENTA*(V_PORCENTAJE_DESCUENTO/100),
        SALEID,
        AFFILIATEID
    );
    
    -- Creamos las comisiones de los afiliados padres
    WHILE i < 2 AND V_BANDERA = 0 LOOP
        -- Verificación de si 'AFFILIATEID_PARENT' no es NULL
        IF AFFILIATEID_PARENT IS NOT NULL THEN 
            --Calculamos el nivel según la gerarquia del nivel
            CASE i
                WHEN 0 THEN
                    V_PORCENTAJE_DESCUENTO :=  3;
                WHEN 1 THEN
                    V_PORCENTAJE_DESCUENTO :=  2;
                WHEN 2 THEN
                    V_PORCENTAJE_DESCUENTO :=  1;
            END CASE;
            
            --Insertamos la comision al padre
            INSERT INTO COMMISSION (
                COMMISSION_ID,
                VALOR,
                SALE_ID, 
                AFFILIATE_ID
            )
            VALUES(
                COMMISSION_SEQ.NEXTVAL,
                V_VALOR_VENTA*(V_PORCENTAJE_DESCUENTO/100),
                SALEID,
                AFFILIATEID_PARENT
            );
            
            --Actualizamos el padre
            SELECT AFFILIATE_PARENT_ID
            INTO AFFILIATEID_PARENT
            FROM AFFILIATE
            WHERE AFFILIATE_ID = AFFILIATEID_PARENT;
        
        ELSE 
            V_BANDERA := 1;
        END IF;
        
        i := i + 1;  -- Incrementar el contador
    END LOOP;    
    
END;

--Test
--Parametro 1: AFFILIATEID
--Parametro 2: SALEID
EXECUTE  GENERAR_COMISIONES_DE_VENTA(5,24);
SELECT * FROM COMMISSION;

--Este metodo me permite comprar un producto de forma instantanea
CREATE OR REPLACE PROCEDURE PR_COMPRAR_AHORA(
AFFILIATE_ID IN NUMBER,
PRODUCT_ID IN NUMBER,
QUANTITY IN NUMBER
)
AS    
    V_CID NUMBER := CART_SEQ.NEXTVAL;
    V_PID NUMBER := PRODUCT_ID;
    V_SHID NUMBER := SHIPPING_SEQ.NEXTVAL;
    V_PPRECIO NUMBER;
    V_DIRECCION VARCHAR(50);
    V_AFFID NUMBER := AFFILIATE_ID;
    V_PORCENTAJE_DESCUENTO NUMBER := 0;
    V_VALOR_VENTA NUMBER := 0;
    V_SALEID NUMBER:= SALE_SEQ.NEXTVAL;
    
BEGIN

    --Se obtien la dirección del usuario para el envio
    SELECT ADRRESS 
    INTO V_DIRECCION
    FROM AFFILIATE
    WHERE AFFILIATE_ID = V_AFFID;
    
    
    --Se obtiene el precio de venta del producto
    SELECT SALE_PRICE 
    INTO V_PPRECIO 
    FROM PRODUCT 
    WHERE PRODUCT_ID = V_PID;
    
    --Se crea el carrito, este es necesario para hacer la compra
    INSERT INTO CART (
        CART_ID,
        TOTAL,
        ACTIVATE,
        AFFILIATE_ID
    ) 
    VALUES(
        V_CID,
        0, 
        0, --- vamos a definirlo inactivo debido a que se va hacer una compra directa
        V_AFFID
    );
    
    --Se agrega el producto y el carrito a la tabla detalle
    INSERT INTO CART_PRODUCT_DETAIL(
        CART_PRODUCT_DETAIL_ID,
        QUANTITY,
        TOTAL_AMOUNT,
        CART_ID,
        PRODUCT_ID
    )
    VALUES (
        CART_PRODUCT_DETAIL_SEQ.NEXTVAL,
        QUANTITY,
        V_PPRECIO*QUANTITY,
        V_CID,
        V_PID 
    );
    
    --Se actualiza el precio total de lo que va en el carrito
    ACTUALIZAR_TOTAL_CARRITO(V_CID);
    
    --Creamos el envio y su estado va ser en proceso, esto debido a que necesita que se confirme la compra
    INSERT INTO SHIPPING (
        SHIPPING_ID,    
        DATE_CHANGED,  
        COMMENTS,
        ESTIMATED_DELIVERY_DATE,  
        ADRRESS,
        STATUS_SHIPPING_ID
    )
    VALUES (
        V_SHID,
        SYSDATE + 20,  -- Esto habilita 20 días de cambio 
        '',
        SYSDATE + 15,
        V_DIRECCION,
        1
    );
    --Calculamos cual es el valor porcentual que será descontado por todas las comisiones 
    V_PORCENTAJE_DESCUENTO := COMISIONES_TOTALES_PARA_VENTA(V_AFFID);
    V_VALOR_VENTA := F_CALCULAR_TOTAL_CARRITO(V_CID);
    
    DBMS_OUTPUT.PUT_LINE(V_PORCENTAJE_DESCUENTO);
    --Ahora vamos a crear la compra
    INSERT INTO SALE (
        SALE_ID, 
        DATE_SALE,
        ORIGINAL_PRICE,
        FINAL_PRICE,
        SHIPPING_ID, 
        STATUS_SALE_ID,
        CART_ID       
    )
    VALUES (
        V_SALEID,
        SYSDATE,
        V_VALOR_VENTA,
        V_VALOR_VENTA -(V_VALOR_VENTA*(V_PORCENTAJE_DESCUENTO/100)),
        V_SHID,
        2,  -- Este estado nos indica de la compra está en transito
        V_CID
    );
    
    --Generamos todas las comisiones correspondientes
    GENERAR_COMISIONES_DE_VENTA(V_AFFID, V_SALEID);
    
END;

--Test
--Parametro 1: AFFILIATE_ID
--Parametro 2: PRODUCT_ID
--Parametro 3: QUANTITY
EXECUTE PR_COMPRAR_AHORA(3, 4, 6);

SELECT * FROM COMMISSION;

SELECT * FROM PRODUCT;

SELECT * FROM SALE;



CREATE OR REPLACE PROCEDURE PR_AGREGAR_AL_CARRITO(
AFFILIATE_ID IN NUMBER,
PRODUCT_ID IN NUMBER,
QUANTITY IN NUMBER
)
AS    
    V_CID NUMBER;
    V_PID NUMBER := PRODUCT_ID;
    V_PPRECIO NUMBER;
    V_AFFID NUMBER := AFFILIATE_ID;
    V_FLAG NUMBER;
    V_FLAG_PRODUCTO NUMBER;
    
BEGIN
    --Se obtiene el precio de venta del producto para el calculo de los totales
    SELECT SALE_PRICE 
    INTO V_PPRECIO 
    FROM PRODUCT 
    WHERE PRODUCT_ID = V_PID;
    
    -- Validamos que hay carritos de compra activos para el usuario, de otra forma creamos uno
    SELECT COUNT(*)
    INTO V_FLAG
    FROM CART
    WHERE AFFILIATE_ID = V_AFFID AND ACTIVATE = 1 ;
    
    IF V_FLAG = 0 THEN 
        V_CID := CART_SEQ.NEXTVAL;  --Trabajamos con el nuevo id del nuevo carrito
        INSERT INTO CART (
            CART_ID,
            TOTAL,
            ACTIVATE,
            AFFILIATE_ID
        ) 
        VALUES(
            V_CID,
            0, 
            1, --- Se activa el carrito
            V_AFFID
        );
        
        --Debido a que es un carrito nuevo podemos agregar el primer producto sin inconvenientes
        INSERT INTO CART_PRODUCT_DETAIL(
            CART_PRODUCT_DETAIL_ID,
            QUANTITY,
            TOTAL_AMOUNT,
            CART_ID,
            PRODUCT_ID
        )
        VALUES (
            CART_SEQ.NEXTVAL,
            QUANTITY,
            V_PPRECIO*QUANTITY,
            V_CID,
            V_PID 
        );
    ELSE
        --Identidicamos cual es el carrito activo del cliente y lo asignamos a V_CID
        SELECT CART_ID 
        INTO V_CID 
        FROM CART
        WHERE ACTIVATE = 1 AND AFFILIATE_ID = V_AFFID;

        --Buscamos si en el carrito ya se encuentra añadido el mismo producto, con el fin de actualizar sus valores y no pegar otro registro
        V_FLAG_PRODUCTO := F_BUSCAR_PRODUCTO_EN_CARRITO(V_PID, V_CID);
        
        IF V_FLAG_PRODUCTO > 0 THEN

            INCREMENTAR_PRODUCTOS_EN_CARRITO(V_CID, V_PID, QUANTITY);
            
        ELSE
            --De lo contrario añadimos un nuevo producto
            INSERT INTO CART_PRODUCT_DETAIL(
                CART_PRODUCT_DETAIL_ID,
                QUANTITY,
                TOTAL_AMOUNT,
                CART_ID,
                PRODUCT_ID
            )
            VALUES (
                CART_PRODUCT_DETAIL_SEQ.NEXTVAL,
                QUANTITY,
                V_PPRECIO*QUANTITY,
                V_CID,
                V_PID 
            );
        END IF;
        
        
        
        
    END IF;
    
    --Se actualiza el precio total de lo que va en el carrito
    ACTUALIZAR_TOTAL_CARRITO(V_CID);
    
END;

--Test
--PARAMETRO 1: AFFILIATE_ID
--PARAMETRO 2: PRODUCT_ID
--PARAMETRO 3: QUANTITY
EXECUTE PR_AGREGAR_AL_CARRITO(1, 3, 4);

CREATE OR REPLACE PROCEDURE ELIMINAR_PRODUCTO_DEL_CARRITO(
CARTID IN NUMBER,
PRODUCTID IN NUMBER
)
AS
    FLAG_EXISTENCIAP NUMBER := 0;
BEGIN
    
    SELECT COUNT(*) 
    INTO FLAG_EXISTENCIAP
    FROM CART_PRODUCT_DETAIL
    WHERE CART_ID = CARTID AND PRODUCT_ID = PRODUCTID;
    
    IF FLAG_EXISTENCIAP > 0 THEN 
    
        DELETE FROM CART_PRODUCT_DETAIL
        WHERE CART_ID = CARTID AND PRODUCT_ID = PRODUCTID;
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('El producto no existe');
    END IF;    
  
END;


CREATE OR REPLACE TRIGGER CONTROL_DE_INVENTARIO
    BEFORE INSERT
    ON CART_PRODUCT_DETAIL
    FOR EACH ROW
DECLARE
    V_PRODUCTID NUMBER;
    V_STOCK NUMBER;
    V_CANTIDAD_SOLICITADA NUMBER := :NEW.QUANTITY;
BEGIN
    
    -- Si PRODUCT_ID está en el registro de CART_PRODUCT_DETAIL que se va a insertar
    V_PRODUCTID := :NEW.PRODUCT_ID;
    
    -- Obtener el stock disponible del producto
    SELECT STOCK_QUANTITY
    INTO V_STOCK
    FROM PRODUCT
    WHERE PRODUCT_ID = V_PRODUCTID;

    -- Registrar la acción en la tabla de control
    INSERT INTO CONTROL (USERNAME, ACTION_DATE) 
    VALUES (USER, SYSDATE);

    -- Verificar si la cantidad solicitada excede el stock
    IF V_CANTIDAD_SOLICITADA > V_STOCK THEN
        -- Lanza una excepción si la cantidad solicitada es mayor que el stock disponible
        RAISE_APPLICATION_ERROR(-20001, 'La cantidad solicitada excede el stock disponible.');
    ELSE
        -- Actualizar el stock si la cantidad solicitada es válida
        UPDATE PRODUCT 
        SET STOCK_QUANTITY = V_STOCK - V_CANTIDAD_SOLICITADA
        WHERE PRODUCT_ID = V_PRODUCTID;
    END IF;

END;




--Test
--PARAMETRO 1: CARTID
--PARAMETRO 2: PRODUCTID
EXECUTE ELIMINAR_PRODUCTO_DEL_CARRITO(21, 763);

SELECT * FROM CART_PRODUCT_DETAIL
WHERE CART_ID = 21;

SELECT * FROM CART; 

SELECT * FROM AFFILIATE;



--------------PRCEDIMINETO DE CREAR UN AFILIADO------------


-- Ejecutar el procedimiento para agregar un afiliado
BEGIN
   insertar_affiliate(33, 'Juan', 'Pérez', 'juan.perez@gmail.com', 1, 'CLL22 #11-09', 1, NULL);
END;



CREATE OR REPLACE PROCEDURE insertar_affiliate (
    p_affiliate_id IN affiliate.AFFILIATE_ID%TYPE,
    p_first_name IN affiliate.FIRST_NAME%TYPE,
    p_last_name IN affiliate.LAST_NAME%TYPE,
    p_email IN affiliate.EMAIL%TYPE,
    p_contrasenia IN affiliate.PASSWORD%TYPE,
    p_activate IN affiliate.ACTIVATE%TYPE,
    p_address IN affiliate.ADRRESS%TYPE,
    /*Mirar con trgger*/
    /*p_hierarchical_level IN affiliate.HIERARCHICAL_LEVEL_ID%TYPE,*/
    p_affiliate_affiliate_id IN affiliate.AFFILIATE_PARENT_ID%TYPE
) IS
BEGIN
    -- Validación preliminar
    IF p_first_name IS NULL OR p_last_name IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre y apellido del afiliado son obligatorios.');
END IF;

    -- Inserción de datos
INSERT INTO affiliate (
    AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL,PASSWORD, ACTIVATE, ADRRESS, AFFILIATE_PARENT_ID
)
VALUES (
           p_affiliate_id, p_first_name, p_last_name, p_email,p_contrasenia, p_activate, p_address, p_affiliate_affiliate_id
       );

-- Mensaje de confirmación
DBMS_OUTPUT.PUT_LINE('El AFFILIATE_ID ' || p_affiliate_id || ' fue insertado exitosamente.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: El AFFILIATE_ID ' || p_affiliate_id || ' ya existe.');
WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error de tipo de dato o valor fuera de rango para el ID: ' || p_affiliate_id);
WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado al insertar el afiliado con ID: ' || p_affiliate_id || '. Código de error: ' || SQLCODE || ' Mensaje: ' || SQLERRM);
END insertar_affiliate;
/
--------ELMINAR AFILIADO---------------------------

CREATE OR REPLACE PROCEDURE eliminar_affiliate (
    p_affiliate_id IN affiliate.affiliate_id%TYPE
) IS
BEGIN
    -- Intentar eliminar el afiliado con el ID proporcionado
DELETE FROM affiliate
WHERE affiliate_id = p_affiliate_id;

-- Comprobar si la eliminación afectó a algún registro
IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: El AFFILIATE_ID no existe o ya ha sido eliminado.');
ELSE
        DBMS_OUTPUT.PUT_LINE('AFFILIATE_ID eliminado exitosamente.');
END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado al intentar eliminar el afiliado.');
END eliminar_affiliate;

-- Ejemplo de cómo usar el procedimiento para eliminar un afiliado
BEGIN
   eliminar_affiliate(5); -- Reemplaza "5" con el ID del afiliado que deseas eliminar
END;


/////login

CREATE OR REPLACE PROCEDURE login_email_affiliate(
    p_email IN affiliate.EMAIL%TYPE,
    p_password IN affiliate.PASSWORD%TYPE
)
IS
    v_count NUMBER; -- Variable para verificar si las credenciales coinciden
BEGIN
    -- Validar si existe un registro con el email y la contraseña proporcionados
SELECT COUNT(*)
INTO v_count
FROM affiliate
WHERE email = p_email
  AND password = p_password;

-- Comprobar si las credenciales son correctas
IF v_count = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Inicio de sesión exitoso para el usuario: ' || p_email);
ELSE
        DBMS_OUTPUT.PUT_LINE('Error: Credenciales incorrectas.');
END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END login_email_affiliate;

/////enviar parametros prueba

BEGIN
    -- Probar con credenciales correctas
    login_email_affiliate('juan.perez@gmail.com', 'juan.perez');

END;
/

