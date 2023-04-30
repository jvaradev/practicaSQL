/*1. Crear un bloque PL que visualice el país de una tienda que se pida al usuario por teclado*/

DECLARE
    v_pais tienda.pais%type;

BEGIN
    SELECT lower(pais) into lower(v_pais) from tienda
    where codtienda = &cod;
    dbms_output.put_line ('País de la tienda = '||v_pais);
END;

/*2. Dado un tipo de producto introducido por teclado, obtener el número de productos asociados a 
este tipo de producto*/

DECLARE
    v_stock producto.stock%type;
    v_producto producto.codproducto%type;
BEGIN
    SELECT codproducto, stock into v_producto, v_stock from producto
    where codproducto = &codproducto;
    DBMS_OUTPUT.PUT_LINE ('Producto: '||v_producto||'. Cantidad: '||v_stock);
END;

/*3. Incrementar el precio de venta en 5€ a todos los productos para los que su stock sea menor de
25 unidades*/

DECLARE
    v_stock producto.stock%type;
    CURSOR productos is (Select codproducto, precioventa, stock from producto
                            where stock < 25);
BEGIN
    
    FOR i IN productos LOOP
        DBMS_OUTPUT.PUT_LINE ('Producto: '||i.codproducto||'. Precio: '||i.precioventa
                                ||'. Stock; '||i.stock||'. Nuevo precio: '||(i.precioventa+5));
    END LOOP;
END;

/*4. Haz un bloque anónimo que asigne a una variable declarada el código de un cliente y cuente el
número de pediddos del cliente*/
DECLARE
    v_contador_pedidos number:=0;
    v_cliente cliente.codcliente%type;
BEGIN
    select count (pe.codpedido), cl.codcliente into v_contador_pedidos, v_cliente
    from pedido pe join cliente cl on cl.codcliente = pe.codcliente
    where cl.codcliente = &codcliente
    group by cl.codcliente;
    
    DBMS_OUTPUT.PUT_LINE ('Cliente: '||v_cliente||'. Pedidos: '||v_contador_pedidos);  
END;

/*5.Pide dos tiendas por teclado e indica cuál de las dos tiendas ingresó más dinero por los pedidos
hechos por sus cliente*/
DECLARE
    v_ingresos1 pago.importetotal%type;
    v_ingresos2 pago.importetotal%type;
    v_tienda1 tienda.codtienda%type;
    v_tienda2 tienda.codtienda%type;
BEGIN
    SELECT SUM(pa.importetotal), t.codtienda into v_ingresos1, v_tienda1 from pago pa
    join cliente cl on cl.codcliente = pa.codcliente
    join empleado emp on emp.codempleado = cl.codempleadoventas
    join tienda t on t.codtienda = emp.codtienda
    where t.codtienda = &codtienda1
    group by t.codtienda;
    
    SELECT SUM(pa.importetotal), t.codtienda into v_ingresos2, v_tienda2 from pago pa
    join cliente cl on cl.codcliente = pa.codcliente
    join empleado emp on emp.codempleado = cl.codempleadoventas
    join tienda t on t.codtienda = emp.codtienda
    where t.codtienda = &codtienda2
    group by t.codtienda;
    
    IF v_ingresos1 > v_ingresos2 THEN
        DBMS_OUTPUT.PUT_LINE ('La tienda '||v_tienda1||' tiene más ingresos.');
    END IF;
    
    IF v_ingresos2 > v_ingresos1 THEN
        DBMS_OUTPUT.PUT_LINE ('La tienda '||v_tienda2||' tiene más ingresos.');
    END IF;
END;

/*6. Para un producto introducido por teclado calcula y muestra si su margen de beneficio
es alto (mayor o igual que el 30%), normal (entre el 30% y el 20%) o bajo (menor o
igual que el 20%).
El margen se calculará como ( (precio de venta - precio proveedor)/precio
proveedor) *100 siempre el que precio proveedor sea distinto de 0. Si es 0
pondremos SIN DATOS*/
DECLARE
    v_producto producto.codproducto%type;
    v_precio_venta producto.precioventa%type;
    v_precio_prov producto.precioproveedor%type;
    e_sin_datos EXCEPTION;
BEGIN
    SELECT codproducto, precioventa, precioproveedor into v_producto, v_precio_venta, v_precio_prov
    from producto
    where codproducto = &codproducto;
    
    IF v_precio_prov =0 THEN
        RAISE e_sin_datos;
    END IF;
    
    IF ((v_precio_venta - v_precio_prov) / v_precio_prov) * 100 >= 30 THEN
        DBMS_OUTPUT.PUT_LINE ('Producto: '||v_producto||'. Beneficio: Alto');
    ELSIF ((v_precio_venta - v_precio_prov) / v_precio_prov) * 100 = 30 THEN
        DBMS_OUTPUT.PUT_LINE ('Producto: '||v_producto||'. Beneficio: Medio');
    ELSE
        DBMS_OUTPUT.PUT_LINE ('Producto: '||v_producto||'. Beneficio: Bajo');
    END IF;
EXCEPTION
    WHEN e_sin_datos THEN
        DBMS_OUTPUT.PUT_LINE ('SIN DATOS');
END;

/*7. Para un cliente que se pase por teclado indica si su ciudad coincide con la de la tienda
en la que trabaja el empleado que tiene asignado o no.*/
DECLARE
    v_cliente cliente.codcliente%type;
    v_empleado empleado.codempleado%type;
    v_ciudad_cliente cliente.ciudad%type;
    v_ciudad_empleado tienda.ciudad%type;
BEGIN
    SELECT cl.codcliente, cl.ciudad, emp.codempleado, t.ciudad 
    into v_cliente, v_ciudad_cliente, v_empleado, v_ciudad_empleado
    from tienda t
    join empleado emp on t.codtienda = emp.codtienda
    join cliente cl on cl.codempleadoventas = emp.codempleado
    where cl.codcliente = &codcliente;
        
    IF v_ciudad_cliente = v_ciudad_empleado THEN
        DBMS_OUTPUT.PUT_LINE ('La tienda del cliente '||v_cliente||
                                ' y del empleado '||v_empleado||' es la misma');
    ELSE
        DBMS_OUTPUT.PUT_LINE ('La tienda del cliente '||v_cliente||
                                ' y del empleado '||v_empleado||' no es la misma');
    END IF;
    
END;

/*8.Renombra el tipo de producto Utensilios y llamalo Herramientas. Para ello tendrás que
hacer los siguientes pasos
    1. Inserta un nuevo tipo de producto llamado Herramientas. El resto de campos deben
    ser los que tenga actualmente el tipo de Utensilios.
    2. Actualiza todos los productos que tuvieran como tipo Utensilios para que tengan el
    nuevo tipo de Herramientas
    3. Borra el tipo de producto Utensilios.
    4. Al final de todo, haz commit.*/

DECLARE
    v_descripcion_tipo tipoproducto.descripcion_texto%type;
    v_descripcion_html tipoproducto.descripcion_html%type;
    v_imagen tipoproducto.imagen%type;
BEGIN
    
    SELECT descripcion_texto, descripcion_html, imagen
    into v_descripcion_tipo, v_descripcion_html, v_imagen
    from tipoproducto where lower(tipo) = 'utensilios';

    INSERT INTO tipoproducto VALUES ('Herramientas', v_descripcion_tipo, v_descripcion_html, v_imagen);
    
    UPDATE producto p SET p.tipoproducto = 'Herramientas' where lower(p.tipoproducto) = 'utensilios';
    
    DELETE FROM tipoproducto WHERE lower(tipo) = 'utensilios';
END;