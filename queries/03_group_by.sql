-- JOIN и работа с несколькими таблицами

--5
--Расчёт общего количества каждого товара на складе.
--Группировка выполняется по SKU и названию товара.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) total_quantity

FROM
    stock s

INNER JOIN
        product p
ON s.product_id = p.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    total_quantity DESC;


--10
--Расчёт общего, зарезервированного и доступного количества
--по каждому товару.
--В результат попадают только товары с положительным доступным остатком.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity)-SUM(s.reserved_qty)) AS available_qty

FROM
    product AS p

JOIN
    stock AS s
ON s.product_id = p.product_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    (SUM(s.quantity)-SUM(s.reserved_qty))>0

ORDER BY
    available_qty DESC;


--11
--Поиск товаров, общий остаток которых превышает 500 единиц.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    SUM(s.quantity)>500

ORDER BY
    total_quantity DESC;


--12
--Вывод всех товаров с их общим остатком.
--Если у товара отсутствует остаток, вместо NULL выводится 0.

SELECT
    p.sku,
    p.product_name,
    COALESCE(SUM(s.quantity),0) AS total_quantity

FROM
    product AS p

LEFT JOIN
        stock AS s
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    total_quantity DESC;


--14
--Расчёт общего, зарезервированного и доступного количества товара
--в разрезе владельцев.

SELECT
    o.owner_name,
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity)-SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        owner_product AS op
ON op.product_id = p.product_id

JOIN
        owner AS o
ON o.owner_id = op.owner_id

GROUP BY
    p.sku,
    p.product_name,
    o.owner_name

HAVING
    (SUM(s.quantity)-SUM(s.reserved_qty)) > 0

ORDER BY
    o.owner_name ASC,
    available_quantity DESC;


--20
--Поиск товаров, для которых существует зарезервированное количество.
--Показывает общий остаток, резерв и доступный остаток.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity)-SUM(s.reserved_qty)) AS available_quantity
FROM
    stock AS s
JOIN
        product AS p
ON p.product_id = s.product_id
GROUP BY
    p.sku,
    p.product_name
HAVING
    SUM(s.reserved_qty) > 0
ORDER BY
    total_reserved DESC;


--22
--Расчёт количества сохранённых транспортных упаковок
--и их общего веса по каждой складской ячейке.

SELECT
    l.address,
    l.location_status,
    COUNT(tp.sscc) AS package_count,
    SUM(tp.gross_weight) AS total_gross_weight

FROM
    location AS l

LEFT JOIN
        transport_package AS tp
ON tp.location_id = l.location_id
AND tp.package_status ='STORED'

GROUP BY
    l.address,
    l.location_status

HAVING
    COUNT(tp.sscc) > 0

ORDER BY
    package_count DESC;


--24
--Расчёт количества упаковок и общего количества товара
--по складским зонам.

SELECT
    z.zone_name,
    z.zone_type,
    COUNT(tp.sscc) AS package_count,
    SUM(s.quantity) AS total_quantity

FROM
    zone AS z

JOIN
    location AS l
ON l.zone_id = z.zone_id

JOIN
    transport_package AS tp
ON tp.location_id = l.location_id

JOIN
        stock AS s
ON s.package_id = tp.package_id

WHERE
    tp.package_status = 'STORED'

GROUP BY
    z.zone_name,
    z.zone_type

ORDER BY
    total_quantity DESC,
    zone_name ASC;


--28
--Поиск товаров на складах, у которых более 50% общего количества
--зарезервировано.
--Показывает общий, зарезервированный и доступный остаток.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity,
    ROUND(SUM(s.reserved_qty)::numeric/SUM(s.quantity)*100,2) reserved_percent

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

JOIN
        warehouse AS w
ON w.warehouse_id = z.warehouse_id

WHERE
    tp.package_status = 'STORED'

GROUP BY
    w.warehouse_code,
    w.warehouse_name,
    p.sku,
    p.product_name

HAVING
    SUM(s.quantity) > 0
AND (SUM(s.reserved_qty)::numeric/SUM(s.quantity)*100) > 50

ORDER BY
    reserved_percent DESC,
    warehouse_code ASC,
    sku ASC;


--32
--Поиск товаров, общий складской остаток которых превышает
--средний общий остаток по всем товарам.
--Для расчёта используются два CTE: общий остаток по товару
--и среднее значение этих остатков.

WITH
    product_totals AS(
        SELECT SUM(quantity) AS total_quantity,
               product_id
        FROM stock
        GROUP BY
            product_id

    ),

avg_total_quantity AS (
    SELECT AVG(total_quantity) AS avg_quantity
    FROM product_totals
    )

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity

FROM
    product AS p

JOIN
        stock AS s
ON s.product_id = p.product_id

CROSS JOIN
        avg_total_quantity

GROUP BY
    p.sku,
    p.product_name,
    avg_total_quantity.avg_quantity

HAVING
    SUM(s.quantity) > avg_total_quantity.avg_quantity

ORDER BY
    total_quantity DESC;