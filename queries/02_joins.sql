-- JOIN и работа с несколькими таблицами

--4
--Поиск товаров, которые присутствуют в остатках склада.
--Показывает SKU, название товара и количество.
--Используется INNER JOIN между stock и product.

SELECT
    DISTINCT p.sku,
    p.product_name,
    s.quantity

FROM
    stock s

INNER JOIN
        product p
ON
    p.product_id = s.product_id

WHERE
    s.quantity > 0

ORDER BY
    s.quantity DESC,
    p.sku ASC;


--6
--Расчёт общего количества товара по каждому владельцу.
--Связывает остатки, товары, товары владельцев и владельцев.

SELECT
    o.owner_name,
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
    product AS p
    ON s.product_id = p.product_id

JOIN
    owner_product AS op
    ON s.product_id = op.product_id

JOIN
    owner AS o
    ON op.owner_id = o.owner_id

GROUP BY
    o.owner_id,
    p.sku,
    p.product_name

ORDER BY
    o.owner_name ASC,
    total_quantity DESC;


--7
--Поиск заблокированных транспортных упаковок, находящихся в статусе STORED,
--с указанием ячейки хранения и причины блокировки.

SELECT
    tp.package_code,
    tp.package_type,
    tp.package_status,
    tp.block_code,
    tp.gross_weight,
    l.address

FROM
    transport_package AS tp

JOIN
        location AS l
ON tp.location_id = l.location_id

WHERE
    tp.block_code IS NOT NULL
  AND trim(tp.block_code)<>''
AND tp.package_status = 'STORED'

ORDER BY
    tp.block_code ASC,
    tp.gross_weight DESC;


--8
--Вывод содержимого складских ячеек:
--ячейка, упаковка, товар и количество товара в упаковке.

SELECT
    l.address,
    tp.package_code,
    p.sku,
    p.product_name,
    s.quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id

JOIN
        location AS l
ON l.location_id = tp.location_id

WHERE
    s.quantity>0
AND tp.package_status = 'STORED'
ORDER BY
    l.address ASC,
    p.sku ASC;


--9
--Расчёт доступного остатка каждого товара:
--из общего количества вычитается зарезервированное количество.

SELECT
    p.sku,
    p.product_name,
    s.quantity,
    s.reserved_qty,
    (s.quantity-s.reserved_qty) AS available_qty

FROM
    product AS p

JOIN
    stock AS s
ON s.product_id = p.product_id

WHERE
    s.quantity-s.reserved_qty>0

ORDER BY
    available_qty DESC;


--13
--Поиск товаров, для которых отсутствуют записи об остатках в таблице stock.
--Используется LEFT JOIN и проверка IS NULL.

SELECT
    p.sku,
    p.product_name

FROM
    product AS p

LEFT JOIN
    stock AS s
    ON p.product_id = s.product_id

WHERE
    s.stock_id IS NULL

ORDER BY
    p.sku ASC;


--15
--Поиск заблокированных транспортных упаковок и товаров,
--которые находятся внутри этих упаковок.

SELECT
    tp.package_code,
    tp.package_type,
    tp.block_code,
    p.sku,
    p.product_name,
    s.quantity,
    l.address

FROM
    transport_package AS tp

JOIN
    stock AS s
ON s.package_id = tp.package_id

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        location AS l
ON l.location_id = tp.location_id

WHERE
    tp.package_status = 'STORED'
AND tp.block_code IS NOT NULL

ORDER BY
    tp.block_code ASC,
    p.sku ASC;


--25
--Расчёт количества упаковок и общего количества товара
--по каждому складу.
--Для определения склада используется цепочка warehouse → zone → location.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    COUNT(tp.sscc) AS package_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id

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
    w.warehouse_name

ORDER BY
    total_quantity DESC,
    w.warehouse_code ASC;


--26
--Расчёт остатков каждого товара отдельно по каждому складу.
--Показывает общий, зарезервированный и доступный остаток.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

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
    p.sku,
    w.warehouse_name,
    p.product_name

HAVING
    (SUM(s.quantity) - SUM(s.reserved_qty)) > 0

ORDER BY
    warehouse_code ASC,
    available_quantity DESC,
    sku ASC;


--27
--Расчёт общего количества, зарезервированного и доступного товара
--по каждому складу.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id

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
    w.warehouse_name

HAVING
    (SUM(s.quantity) - SUM(s.reserved_qty)) > 0

ORDER BY
    available_quantity DESC;


--29
--Расчёт количества упаковок, общего, зарезервированного
--и доступного остатка по каждому владельцу товара.

SELECT
    o.owner_name,
    COUNT(s.package_id) AS package_count,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity)-SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        owner_product AS op
ON op.product_id = s.product_id

JOIN
        owner AS o
ON o.owner_id = op.owner_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
AND tp.package_status = 'STORED'

GROUP BY
    o.owner_name

HAVING
    (SUM(s.quantity)-SUM(s.reserved_qty))  > 0

ORDER BY
    available_quantity DESC,
    owner_name ASC;


--30
--Поиск остатков, в которых полностью зарезервировано всё доступное количество товара
--или количество резерва превышает количество товара.

SELECT
    s.stock_id,
    s.package_id,
    p.sku,
    p.product_name,
    s.quantity,
    s.reserved_qty,
    (s.quantity - s.reserved_qty) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

WHERE
    s.reserved_qty >= s.quantity

ORDER BY
    available_quantity ASC,
    p.sku ASC;


--31
--Поиск складских остатков, у которых отсутствует резервирование.
--Показывает товары с положительным количеством и нулевым резервом.

SELECT
    s.stock_id,
    s.package_id,
    p.sku,
    p.product_name,
    s.quantity,
    s.reserved_qty,
    (s.quantity - s.reserved_qty) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

WHERE
    s.reserved_qty = 0
AND  s.quantity > 0

ORDER BY
    s.quantity DESC,
    p.sku ASC;


