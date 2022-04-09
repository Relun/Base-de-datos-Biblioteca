--Parte 1 - Creación del modelo conceptual, lógico y físico
--Primera parte se encuentra en la imagen Modelos.jpg dentro de la carpeta

--Parte 2 - Creando el modelo en la base de datos
--1. Crear el modelo en una base de datos llamada biblioteca, considerando las tablas definidas y sus atributos
 CREATE DATABASE biblioteca;
\c biblioteca clau
-- creación de las tablas desde pgadmin
BEGIN;

CREATE TABLE IF NOT EXISTS public.socios
(
    rut character varying(15),
    nombre_apellido character varying(50),
    direccion character varying(50),
    telefono character varying(50),
    PRIMARY KEY (rut)
);

CREATE TABLE IF NOT EXISTS public.libros
(
    isbn character varying(20),
    titulo character varying(50),
    pag integer,
    PRIMARY KEY (isbn)
);

CREATE TABLE IF NOT EXISTS public.historial_prestamo
(
    id_prestamo integer,
    fecha_prestamo date,
    fecha_dev_esp date,
    fecha_dev_real date,
    rut_socio character varying(15),
    isbn_libros character varying(20),
    PRIMARY KEY (id_prestamo)
);

CREATE TABLE IF NOT EXISTS public.autores
(
    cod_autor integer,
    nombre character varying(20),
    apellido character varying(20),
    fecha_nac character varying(10),
    fecha_muerte character varying(10),
    PRIMARY KEY (cod_autor)
);

CREATE TABLE IF NOT EXISTS public.libros_autores
(
    id_la integer,
    cod_autor_la integer,
    isbn_la character varying(20),
    tipo_autor character varying(20),
    PRIMARY KEY (id_la)
);

ALTER TABLE IF EXISTS public.historial_prestamo
    ADD FOREIGN KEY (rut_socio)
    REFERENCES public.socios (rut) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.historial_prestamo
    ADD FOREIGN KEY (isbn_libros)
    REFERENCES public.libros (isbn) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.libros_autores
    ADD FOREIGN KEY (cod_autor_la)
    REFERENCES public.autores (cod_autor) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.libros_autores
    ADD FOREIGN KEY (isbn_la)
    REFERENCES public.libros (isbn) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

--2. Se deben insertar los registros en las tablas correspondientes
\copy libros FROM 'C:\Users\claud\Desktop\EmprendimientoRuby\7. Intro-Bases-Datos\biblioteca\Libros.csv' csv header;
\copy autores FROM 'C:\Users\claud\Desktop\EmprendimientoRuby\7. Intro-Bases-Datos\biblioteca\autores.csv' csv header;
\copy libros_autores FROM 'C:\Users\claud\Desktop\EmprendimientoRuby\7. Intro-Bases-Datos\biblioteca\libro_autor.csv' csv header;
\copy socios FROM 'C:\Users\claud\Desktop\EmprendimientoRuby\7. Intro-Bases-Datos\biblioteca\socios.csv' csv header;
\copy historial_prestamo FROM 'C:\Users\claud\Desktop\EmprendimientoRuby\7. Intro-Bases-Datos\biblioteca\historial.csv' csv header;
--3. Realizar las siguientes consultas:
--a. Mostrar todos los libros que posean menos de 300 páginas
SELECT * FROM libros WHERE pag < 300;
--b. Mostrar todos los autores que hayan nacido después del 01-01-1970.
SELECT * FROM autores WHERE CAST(fecha_nac AS INT) > 1970;
--c. ¿Cuál es el libro más solicitado?
--*primero agrego columna titulo y los titulos correspondientes a la tabla historial_prestamo
--*hice esto para mostrar el titulo además del isbn
ALTER TABLE historial_prestamo ADD titulo VARCHAR(50);
UPDATE historial_prestamo SET titulo='CUENTOS DE TERROR' WHERE isbn_libros='111-1111111-111'; 
UPDATE historial_prestamo SET titulo='POESIAS CONTEMPORANEAS' WHERE isbn_libros='222-2222222-222'; 
UPDATE historial_prestamo SET titulo='HISTORIA DE ASIA' WHERE isbn_libros='333-3333333-333'; 
UPDATE historial_prestamo SET titulo='MANUAL DE MECANICA' WHERE isbn_libros='444-4444444-444'; 
--*luego aplico el select correspondiente
SELECT isbn_libros, titulo 
FROM historial_prestamo GROUP BY isbn_libros, titulo HAVING COUNT(*) =(SELECT COUNT( isbn_libros ) total
FROM historial_prestamo GROUP BY isbn_libros, titulo
ORDER BY total DESC LIMIT 1);
--d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.
SELECT rut_socio, (fecha_dev_real-fecha_dev_esp) AS dias_de_atraso, (fecha_dev_real-fecha_dev_esp)*100 AS multa
FROM historial_prestamo WHERE fecha_dev_real-fecha_dev_esp > 0;


