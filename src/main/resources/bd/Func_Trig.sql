
/*Trigger 1: Actualizar inventario después de una venta
Este trigger reducirá la cantidad en el inventario cuando un producto sea agregado al carrito.*/

CREATE OR REPLACE TRIGGER trg_update_inventory
AFTER INSERT ON CART_PRODUCT_DETAIL
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT STOCK_QUANTITY INTO v_stock FROM PRODUCT WHERE PRODUCT_ID = :NEW.PRODUCT_ID;

    IF v_stock < :NEW.QUANTITY THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente para el producto');
    ELSE
        UPDATE PRODUCT
        SET STOCK_QUANTITY = STOCK_QUANTITY - :NEW.QUANTITY
        WHERE PRODUCT_ID = :NEW.PRODUCT_ID;
    END IF;
END;

/*
Trigger 2: Asignar comisión automáticamente después de una venta
Este trigger calculará la comisión para el afiliado cuando se realice una venta.
*/
CREATE OR REPLACE TRIGGER trg_assign_commission
AFTER INSERT ON SALE
FOR EACH ROW
DECLARE
    v_commission_rate NUMBER := 0.05;
    v_commission_value NUMBER;
BEGIN
    v_commission_value := :NEW.FINAL_PRICE * v_commission_rate;

    INSERT INTO COMMISSION (COMMISSION_ID, VALOR, SALE_ID, AFFILIATE_ID)
    VALUES (COMMISSION_SEQ.NEXTVAL, v_commission_value, :NEW.SALE_ID, 
            (SELECT AFFILIATE_ID FROM CART WHERE CART_ID = :NEW.CART_ID));
END;

/*
Trigger 3: Desactivar afiliado después de 6 meses sin ventas
Automáticamente desactiva a un afiliado si no ha realizado ventas en los últimos 6 meses.*/

CREATE OR REPLACE TRIGGER trg_deactivate_affiliate
AFTER UPDATE ON SALE
FOR EACH ROW
BEGIN
    UPDATE AFFILIATE
    SET ACTIVATE = 0
    WHERE AFFILIATE_ID = :NEW.AFFILIATE_ID 
      AND (SYSDATE - (SELECT MAX(DATE_SALE) FROM SALE WHERE AFFILIATE_ID = :NEW.AFFILIATE_ID)) > 180;
END;

/*
Trigger 4: Actualizar estado de envío
Este trigger cambia automáticamente el estado de envío cuando la fecha de entrega es alcanzada.
*/
CREATE OR REPLACE TRIGGER trg_update_shipping_status
BEFORE UPDATE ON SHIPPING
FOR EACH ROW
BEGIN
    IF SYSDATE >= :NEW.ESTIMATED_DELIVERY_DATE THEN
        :NEW.STATUS_SHIPPING_ID := 3; -- 3: Entregado
    END IF;
END;


/*Función 1: Calcular el descuento basado en el nivel jerárquico
Calcula el descuento aplicable al afiliado según su nivel.*/
CREATE OR REPLACE FUNCTION get_discount(affiliate_id NUMBER) RETURN NUMBER IS
    v_discount NUMBER;
BEGIN
    SELECT DISCOUNT_PRODUCT INTO v_discount 
    FROM HIERARCHICAL_LEVEL hl
    JOIN AFFILIATE a ON a.HIERARCHICAL_LEVEL_ID = hl.HIERARCHICAL_LEVEL_ID
    WHERE a.AFFILIATE_ID = affiliate_id;

    RETURN v_discount;
END;


/*Función 2: Obtener el total de comisiones de un afiliado
Retorna la suma total de las comisiones obtenidas por un afiliado.*/
CREATE OR REPLACE FUNCTION get_total_commission(affiliate_id NUMBER) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(VALOR) INTO v_total
    FROM COMMISSION
    WHERE AFFILIATE_ID = affiliate_id;

    RETURN NVL(v_total, 0);
END;


/*Función 3: Validar stock de producto
Verifica si hay suficiente stock para un producto dado.*/
CREATE OR REPLACE FUNCTION check_stock(product_id NUMBER, quantity NUMBER) RETURN BOOLEAN IS
    v_stock NUMBER;
BEGIN
    SELECT STOCK_QUANTITY INTO v_stock FROM PRODUCT WHERE PRODUCT_ID = product_id;

    RETURN v_stock >= quantity;
END;


/*Función 4: Calcular precio final con descuento
Calcula el precio final aplicando un descuento al precio original.*/
CREATE OR REPLACE FUNCTION calculate_final_price(original_price NUMBER, affiliate_id NUMBER) RETURN NUMBER IS
    v_discount NUMBER := get_discount(affiliate_id);
BEGIN
    RETURN original_price * (1 - v_discount / 100);
END;


/*
Procedimiento 1: Registrar un nuevo afiliado
Registra un nuevo afiliado en el sistema.*/

sql
Copiar código
CREATE OR REPLACE PROCEDURE register_affiliate(
    p_first_name VARCHAR2,
    p_last_name VARCHAR2,
    p_email VARCHAR2,
    p_parent_id NUMBER,
    p_level_id NUMBER
) IS
BEGIN
    INSERT INTO AFFILIATE (AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL, ACTIVATE, ADRRESS, HIERARCHICAL_LEVEL_ID, AFFILIATE_PARENT_ID)
    VALUES (AFFILIATE_SEQ.NEXTVAL, p_first_name, p_last_name, p_email, 1, NULL, p_level_id, p_parent_id);
END;
/*
Procedimiento 2: Crear una nueva venta
Genera una nueva venta y actualiza el estado del inventario.*/


CREATE OR REPLACE PROCEDURE create_sale(
    p_cart_id NUMBER,
    p_shipping_id NUMBER,
    p_status_sale_id NUMBER
) IS
    v_total_price NUMBER;
    v_final_price NUMBER;
BEGIN
    SELECT TOTAL INTO v_total_price FROM CART WHERE CART_ID = p_cart_id;

    v_final_price := calculate_final_price(v_total_price, (SELECT AFFILIATE_ID FROM CART WHERE CART_ID = p_cart_id));

    INSERT INTO SALE (SALE_ID, DATE_SALE, ORIGINAL_PRICE, FINAL_PRICE, SHIPPING_ID, STATUS_SALE_ID, CART_ID)
    VALUES (SALE_SEQ.NEXTVAL, SYSDATE, v_total_price, v_final_price, p_shipping_id, p_status_sale_id, p_cart_id);
END;
/*
Procedimiento 3: Actualizar nivel jerárquico de afiliado
Actualiza el nivel de un afiliado basado en la cantidad de afiliados reclutados.*/

CREATE OR REPLACE PROCEDURE update_affiliate_level(p_affiliate_id NUMBER) IS
    v_affiliate_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_affiliate_count
    FROM AFFILIATE
    WHERE AFFILIATE_PARENT_ID = p_affiliate_id;

    UPDATE AFFILIATE
    SET HIERARCHICAL_LEVEL_ID = (SELECT HIERARCHICAL_LEVEL_ID FROM HIERARCHICAL_LEVEL WHERE AFFILIATE_REQUIREMENT <= v_affiliate_count)
    WHERE AFFILIATE_ID = p_affiliate_id;
END;
/*
Procedimiento 4: Desactivar un afiliado manualmente
Permite desactivar un afiliado si es necesario.*/

CREATE OR REPLACE PROCEDURE deactivate_affiliate(p_affiliate_id NUMBER) IS
BEGIN
    UPDATE AFFILIATE
    SET ACTIVATE = 0
    WHERE AFFILIATE_ID = p_affiliate_id;
END;
/


