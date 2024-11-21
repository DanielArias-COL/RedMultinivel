CREATE SEQUENCE cart_seq
START WITH 1
INCREMENT BY 1;

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

CREATE TABLE CATEGORY (
    CATEGORY_ID NUMBER PRIMARY KEY NOT NULL,
    NAME VARCHAR2(50) NOT NULL,
    DESCRIPTION VARCHAR2(500) NOT NULL
);

CREATE TABLE PRODUCT (
    PRODUCT_ID NUMBER PRIMARY KEY NOT NULL,
    NAME VARCHAR2(50) NOT NULL,
    UNIT_PRICE NUMBER NOT NULL,
    SALE_PRICE NUMBER NOT NULL,
    STOCK_QUANTITY NUMBER NOT NULL,
    PATH_IMAGE VARCHAR2(50) NOT NULL,
    CATEGORY_ID NUMBER NOT NULL,
    FOREIGN KEY (CATEGORY_ID) REFERENCES CATEGORY(CATEGORY_ID)
);




CREATE TABLE HIERARCHICAL_LEVEL (
    HIERARCHICAL_LEVEL_ID NUMBER PRIMARY KEY NOT NULL,
    NAME VARCHAR2(50) NOT NULL,
    AFFILIATE_REQUIREMENT INTEGER NOT NULL,
    DISCOUNT_PRODUCT INTEGER NOT NULL,
    LEVEL_NUMBER NUMBER NOT NULL
);

CREATE TABLE STATUS_SALE (
    STATUS_SALE_ID NUMERIC PRIMARY KEY NOT NULL,
    TYPE VARCHAR2(50) NOT NULL
);

CREATE TABLE STATUS_SHIPPING (
    STATUS_SHIPPING_ID NUMERIC PRIMARY KEY NOT NULL,
    TYPE VARCHAR2(50) NOT NULL
);

CREATE TABLE SHIPPING (
    SHIPPING_ID NUMERIC PRIMARY KEY NOT NULL,
    DATE_CHANGED TIMESTAMP NOT NULL,
    COMMENTS VARCHAR2(200),
    ESTIMATED_DELIVERY_DATE DATE NOT NULL,
    ADRRESS VARCHAR2(50),
    STATUS_SHIPPING_ID NUMERIC NOT NULL,
    FOREIGN KEY (STATUS_SHIPPING_ID) REFERENCES STATUS_SHIPPING(STATUS_SHIPPING_ID)
);

CREATE TABLE AFFILIATE (
    AFFILIATE_ID NUMBER PRIMARY KEY NOT NULL,
    FIRST_NAME VARCHAR2(50) NOT NULL,
    LAST_NAME VARCHAR2(50) NOT NULL,
    EMAIL VARCHAR2(50) NOT NULL,
    PASSWORD VARCHAR2(50) NOT NULL,
    ACTIVATE NUMBER(1) NOT NULL,  -- Utilizamos NUMBER(1) para representar BOOLEAN en Oracle
    ADRRESS VARCHAR2(50),
    HIERARCHICAL_LEVEL_ID NUMBER NOT NULL,
    AFFILIATE_PARENT_ID NUMBER ,
    FOREIGN KEY (HIERARCHICAL_LEVEL_ID) REFERENCES HIERARCHICAL_LEVEL(HIERARCHICAL_LEVEL_ID),
    FOREIGN KEY (AFFILIATE_PARENT_ID) REFERENCES AFFILIATE(AFFILIATE_ID)  -- Auto-referencia para el padre
);

CREATE TABLE CART (
    CART_ID NUMERIC NOT NULL,
    TOTAL NUMERIC NOT NULL,
    ACTIVATE NUMBER(1) NOT NULL,  -- Utilizamos NUMBER(1) para representar BOOLEAN en Oracle
    AFFILIATE_ID NUMBER NOT NULL,
    PRIMARY KEY (CART_ID),
    FOREIGN KEY (AFFILIATE_ID) REFERENCES AFFILIATE(AFFILIATE_ID)
);

CREATE TABLE SALE (
    SALE_ID NUMERIC NOT NULL,
    DATE_SALE DATE NOT NULL,
    ORIGINAL_PRICE NUMERIC NOT NULL,
    FINAL_PRICE NUMERIC NOT NULL,
    SHIPPING_ID NUMERIC NOT NULL,
    STATUS_SALE_ID NUMERIC NOT NULL,
    CART_ID NUMERIC NOT NULL,
    PRIMARY KEY (SALE_ID),
    FOREIGN KEY (SHIPPING_ID) REFERENCES SHIPPING(SHIPPING_ID),
    FOREIGN KEY (STATUS_SALE_ID) REFERENCES STATUS_SALE(STATUS_SALE_ID),
    FOREIGN KEY (CART_ID) REFERENCES CART(CART_ID)
);

CREATE TABLE COMMISSION (
    COMMISSION_ID NUMBER NOT NULL,
    VALOR NUMBER NOT NULL,
    SALE_ID NUMERIC NOT NULL,
    AFFILIATE_ID NUMBER NOT NULL,
    PRIMARY KEY (COMMISSION_ID),
    FOREIGN KEY (SALE_ID) REFERENCES SALE(SALE_ID),
    FOREIGN KEY (AFFILIATE_ID) REFERENCES AFFILIATE(AFFILIATE_ID)
);

CREATE TABLE CART_PRODUCT_DETAIL (
    CART_PRODUCT_DETAIL_ID NUMERIC NOT NULL,
    QUANTITY NUMBER NOT NULL,
    TOTAL_AMOUNT NUMBER NOT NULL,
    CART_ID NUMERIC NOT NULL,
    PRODUCT_ID NUMBER NOT NULL,
    PRIMARY KEY (CART_PRODUCT_DETAIL_ID),
    FOREIGN KEY (CART_ID) REFERENCES CART(CART_ID),
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(PRODUCT_ID)
);

--- Se inisertan los datos

INSERT INTO CATEGORY (CATEGORY_ID, NAME, DESCRIPTION) VALUES (1, 'Salud', 'Categoría de productos relacionados con la salud.');
INSERT INTO CATEGORY (CATEGORY_ID, NAME, DESCRIPTION) VALUES (2, 'Nutrición', 'Categoría de productos que apoyan la nutrición y el bienestar.');
INSERT INTO CATEGORY (CATEGORY_ID, NAME, DESCRIPTION) VALUES (3, 'Belleza', 'Categoría de productos para el cuidado personal y la belleza.');
INSERT INTO CATEGORY (CATEGORY_ID, NAME, DESCRIPTION) VALUES (4, 'Fitness', 'Categoría de productos que ayudan en el entrenamiento físico.');
INSERT INTO CATEGORY (CATEGORY_ID, NAME, DESCRIPTION) VALUES (5, 'Cuidado de la Piel', 'Productos diseñados para el cuidado de la piel.');

INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (1, 'Suplemento de Vitamina C', 10.00, 12.00, 100, 'src/main/resources/images/1.png', 1);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (2, 'Proteína en Polvo', 25.00, 30.00, 50, 'src/main/resources/images/2.png', 2);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (3, 'Crema Hidratante', 15.00, 18.00, 75, 'src/main/resources/images/3.png', 3);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (4, 'Barras Energéticas', 5.00, 7.00, 200, 'src/main/resources/images/4.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (5, 'Limpiador Facial', 20.00, 24.00, 60, 'src/main/resources/images/5.png', 5);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (6, 'Gel Energizante', 12.00, 15.00, 150, 'src/main/resources/images/6.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (7, 'Aceite Esencial Relajante', 8.00, 10.00, 120, 'src/main/resources/images/7.png', 5);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (8, 'Batido Nutricional', 22.00, 26.00, 80, 'src/main/resources/images/8.png', 2);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (9, 'Shampoo Fortificante', 18.00, 22.00, 90, 'src/main/resources/images/9.png', 3);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (10, 'Gafas para Deporte', 30.00, 35.00, 40, 'src/main/resources/images/10.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (11, 'Toalla Deportiva', 12.00, 15.00, 200, 'src/main/resources/images/11.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (12, 'Crema Antiarrugas', 25.00, 30.00, 70, 'src/main/resources/images/12.png', 3);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (13, 'Snacks Saludables', 5.00, 6.50, 300, 'src/main/resources/images/13.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (14, 'Mascarilla Facial', 15.00, 18.00, 100, 'src/main/resources/images/14.png', 5);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (15, 'Protector Solar', 10.00, 12.50, 150, 'src/main/resources/images/15.png', 5);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (16, 'Botella Deportiva', 8.00, 10.00, 180, 'src/main/resources/images/16.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (17, 'Sérum Facial', 30.00, 35.00, 50, 'src/main/resources/images/17.png', 3);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (18, 'Multivitamínico Completo', 20.00, 25.00, 100, 'src/main/resources/images/18.png', 1);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (19, 'Camiseta Deportiva', 15.00, 18.00, 120, 'src/main/resources/images/19.png', 4);
INSERT INTO PRODUCT (PRODUCT_ID, NAME, UNIT_PRICE, SALE_PRICE, STOCK_QUANTITY, PATH_IMAGE, CATEGORY_ID) VALUES (20, 'Calcetines Antideslizantes', 8.00, 9.50, 200, 'src/main/resources/images/20.png', 4);


INSERT INTO HIERARCHICAL_LEVEL (HIERARCHICAL_LEVEL_ID, NAME, AFFILIATE_REQUIREMENT, DISCOUNT_PRODUCT, LEVEL_NUMBER) VALUES (1, 'Nivel 1', 0, 5, 1);
INSERT INTO HIERARCHICAL_LEVEL (HIERARCHICAL_LEVEL_ID, NAME, AFFILIATE_REQUIREMENT, DISCOUNT_PRODUCT, LEVEL_NUMBER) VALUES (2, 'Nivel 2', 10, 10, 2);
INSERT INTO HIERARCHICAL_LEVEL (HIERARCHICAL_LEVEL_ID, NAME, AFFILIATE_REQUIREMENT, DISCOUNT_PRODUCT, LEVEL_NUMBER) VALUES (3, 'Nivel 3', 20, 15, 3);
INSERT INTO HIERARCHICAL_LEVEL (HIERARCHICAL_LEVEL_ID, NAME, AFFILIATE_REQUIREMENT, DISCOUNT_PRODUCT, LEVEL_NUMBER) VALUES (4, 'Nivel 4', 30, 20, 4);

INSERT INTO STATUS_SALE (STATUS_SALE_ID, TYPE) VALUES (1, 'Confirmada');
INSERT INTO STATUS_SALE (STATUS_SALE_ID, TYPE) VALUES (2, 'En Proceso');
INSERT INTO STATUS_SALE (STATUS_SALE_ID, TYPE) VALUES (3, 'Finalizada');
INSERT INTO STATUS_SALE (STATUS_SALE_ID, TYPE) VALUES (4, 'Cancelada');

INSERT INTO STATUS_SHIPPING (STATUS_SHIPPING_ID, TYPE) VALUES (1, 'En preparación');
INSERT INTO STATUS_SHIPPING (STATUS_SHIPPING_ID, TYPE) VALUES (2, 'En tránsito');
INSERT INTO STATUS_SHIPPING (STATUS_SHIPPING_ID, TYPE) VALUES (3, 'Entregado');
INSERT INTO STATUS_SHIPPING (STATUS_SHIPPING_ID, TYPE) VALUES (4, 'Devuelto');
INSERT INTO STATUS_SHIPPING (STATUS_SHIPPING_ID, TYPE) VALUES (5, 'Cancelado');

INSERT INTO AFFILIATE (AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL, PASSWORD, ACTIVATE, ADRRESS, HIERARCHICAL_LEVEL_ID, AFFILIATE_PARENT_ID) 
VALUES (1, 'Juan', 'Pérez', 'juan.perez@gmail.com', 'juan.perez', 1, 'CLL22 #11-09', 1, NULL);

INSERT INTO AFFILIATE (AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL, PASSWORD, ACTIVATE, ADRRESS, HIERARCHICAL_LEVEL_ID, AFFILIATE_PARENT_ID) 
VALUES (2, 'María', 'Gómez', 'maria.gomez@gmail.com', 'maria.gomez', 1, 'CLL14 #09-52', 1, 1);

INSERT INTO AFFILIATE (AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL, PASSWORD, ACTIVATE, ADRRESS, HIERARCHICAL_LEVEL_ID, AFFILIATE_PARENT_ID) 
VALUES (3, 'Carlos', 'Lopez', 'carlos.lopez@gmail.com', 'carlos.lopez', 1, 'CLL32 #23-09', 2, 1);

INSERT INTO AFFILIATE (AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL, PASSWORD, ACTIVATE, ADRRESS, HIERARCHICAL_LEVEL_ID, AFFILIATE_PARENT_ID) 
VALUES (4, 'Ana', 'Martínez', 'ana.martinez@gmail.com', 'ana.martinez', 1, 'CLL43 #04-41', 2, 2);

INSERT INTO AFFILIATE (AFFILIATE_ID, FIRST_NAME, LAST_NAME, EMAIL, PASSWORD, ACTIVATE, ADRRESS, HIERARCHICAL_LEVEL_ID, AFFILIATE_PARENT_ID) 
VALUES (5, 'Luis', 'Fernández', 'luis.fernandez@gmail.com', 'luis.fernandez', 0, 'CLL10 #87-01', 3, 3);


-- En caso de querer eliminar las tablas y su contenido ejecute el siguiente script


DROP TABLE CART_PRODUCT_DETAIL CASCADE CONSTRAINTS;
DROP TABLE COMMISSION CASCADE CONSTRAINTS;
DROP TABLE SALE CASCADE CONSTRAINTS;
DROP TABLE CART CASCADE CONSTRAINTS;
DROP TABLE SHIPPING CASCADE CONSTRAINTS;
DROP TABLE AFFILIATE CASCADE CONSTRAINTS;
DROP TABLE PRODUCT CASCADE CONSTRAINTS;
DROP TABLE STATUS_SALE CASCADE CONSTRAINTS;
DROP TABLE STATUS_SHIPPING CASCADE CONSTRAINTS;
DROP TABLE HIERARCHICAL_LEVEL CASCADE CONSTRAINTS;
DROP TABLE CATEGORY CASCADE CONSTRAINTS;

