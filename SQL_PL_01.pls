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
