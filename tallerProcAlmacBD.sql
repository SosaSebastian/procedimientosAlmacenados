-- Primer punto

DELIMITER //

CREATE PROCEDURE saludar()
BEGIN
   SELECT '¡Hola mundo!';
END //

DELIMITER ;

call saludar();

-- Segundo punto 

DELIMITER //

CREATE PROCEDURE notas(IN nota DECIMAL(4,2))
BEGIN
    IF nota >= 0 AND nota < 5 THEN
        SELECT 'Insuficiente';
    ELSEIF nota >= 5 AND nota < 6 THEN
        SELECT 'Aprobado';
    ELSEIF nota >= 6 AND nota < 7 THEN
        SELECT 'Bien';
    ELSEIF nota >= 7 AND nota < 9 THEN
        SELECT 'Notable';
    ELSEIF nota >= 9 AND nota <= 10 THEN
        SELECT 'Sobresaliente';
    ELSE
        SELECT 'Nota no válida';
    END IF;
END //

DELIMITER ;

CALL notas(4.5);

USE myfood;

-- Tercer punto

DELIMITER //

CREATE PROCEDURE cantidadProductos(IN tipo VARCHAR(100))
BEGIN
    SELECT COUNT(*) AS cantidad
    FROM productos
    WHERE idTipoProducto = (
        SELECT idTipoProducto
        FROM tipoproductos
        WHERE nombreTipoProducto = tipo
        LIMIT 1
    );
END //

DELIMITER ;


CALL cantidadProductos('frutas');

-- Cuarto punto

DELIMITER //

CREATE PROCEDURE preciosProductos(
    IN tipo_producto VARCHAR(100)
)
BEGIN
    SELECT 
        MAX(inventario.valor) AS precio_maximo,
        MIN(inventario.valor) AS precio_minimo,
        AVG(inventario.valor) AS precio_promedio
    FROM 
        inventario
    WHERE 
        inventario.idProducto IN (
            SELECT productos.idProducto
            FROM productos
            WHERE productos.idTipoProducto = (
                SELECT tipoproductos.idTipoProducto
                FROM tipoproductos
                WHERE tipoproductos.nombreTipoProducto = tipo_producto
                LIMIT 1
            )
        );
END //

DELIMITER ;

CALL preciosProductos('proteinas');

-- Quinto punto 

DELIMITER //

CREATE FUNCTION funcionIVA(producto VARCHAR(100))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE idProd INT;
    DECLARE precioBase DECIMAL(10,2);
    DECLARE precioIVA DECIMAL(10,2);

    SELECT idProducto INTO idProd
    FROM productos
    WHERE nombreProducto = producto
    LIMIT 1;

    SELECT valor INTO precioBase
    FROM inventario
    WHERE idProducto = idProd
    LIMIT 1;

    SET precioIVA = precioBase * 1.19;

    RETURN precioIVA;
END //

DELIMITER ;


SELECT funcionIVA('Manzana');

-- Sexto punto 

CREATE TABLE pais (
    idpais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cantidadSucursales INT DEFAULT 0
);

DELIMITER //

CREATE PROCEDURE sucursales_pais(IN nombre_pais VARCHAR(100))
BEGIN

    DECLARE cantidad INT;

    SELECT cantidadSucursales INTO cantidad
    FROM pais
    WHERE nombre = nombre_pais;

    IF cantidad IS NOT NULL THEN
        SELECT cantidad AS 'Cantidad de sucursales'
        FROM pais
        WHERE nombre = nombre_pais;
    ELSE
        SELECT 'El país no existe en la tabla pais' AS mensaje;
    END IF;
END //

DELIMITER ;

CALL sucursales_pais('Canada');


-- Septimo punto

ALTER TABLE usuarios
ADD COLUMN edad INT;

SET SQL_SAFE_UPDATES = 0;
UPDATE usuarios
SET edad = FLOOR(DATEDIFF(CURDATE(), fechaNacimiento) / 365);
SET SQL_SAFE_UPDATES = 1;


-- Octavo punto

DELIMITER //

CREATE FUNCTION calcularEdad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN YEAR(CURDATE()) - YEAR(fecha_nacimiento);
END //

DELIMITER ;

SELECT calcularEdad('1997-06-15') AS 'Edad calculada';

-- Noveno punto

DELIMITER //

CREATE PROCEDURE actualizarEdad()
BEGIN
    DECLARE usuario_id INT;
    DECLARE fecha_nacimiento DATE;
    DECLARE finished INT DEFAULT 0;
    DECLARE cur CURSOR FOR 
        SELECT idUsuarios, fechaNacimiento FROM usuarios;

    DECLARE CONTINUE HANDLER 
		FOR NOT FOUND SET finished = 1;

    OPEN cur;

    getEdad: LOOP
        FETCH cur INTO usuario_id, fecha_nacimiento;

        IF finished = 1 THEN
            LEAVE getEdad;
        END IF;

        UPDATE usuarios
        SET edad = calcularEdad(fecha_nacimiento)
        WHERE idUsuarios = usuario_id;

    END LOOP;

    CLOSE cur;
END //

DELIMITER ;


CALL actualizarEdad();

SELECT idUsuarios, nombre, fechaNacimiento, edad FROM usuarios;


-- Decimo punto

use GAIT;

DELIMITER //

CREATE FUNCTION rol_usuario (id_usuario INT) 
RETURNS VARCHAR(500) 
DETERMINISTIC 
BEGIN
    DECLARE rol INT;
    DECLARE nombre_rol VARCHAR(45);
    DECLARE permisos TEXT;

    SELECT id_role INTO rol 
    FROM users 
    WHERE id = id_usuario;

    SELECT name INTO nombre_rol 
    FROM roles 
    WHERE id = rol;

    IF nombre_rol = 'Admin' THEN
        SET permisos = 'Crear usuario, crear pedido, generar pago, ver historial de pago, 
						ver historial de pedidos, ver estado del pedido';
    ELSEIF nombre_rol = 'Moderador' THEN
        SET permisos = 'Crear pedido, generar pago, ver historial de pago, 
						ver historial de pedidos, ver estado del pedido';
    ELSEIF nombre_rol = 'Viewer' THEN
        SET permisos = 'Ver historial de pago, ver historial de pedidos, 
						ver estado del pedido';
    END IF;

    RETURN CONCAT('Rol: ', nombre_rol, ' - Permisos: ', permisos);
END //

DELIMITER ;

select gait.rol_usuario('Moderador');














