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


-- 33
-- Товары, у которых доступный остаток выше среднего доступного остатка по всем товарам.

WITH
    product_totals AS(
        SELECT (SUM(quantity) - SUM(reserved_qty)) AS available_qty,
               product_id
        FROM stock
        GROUP BY product_id
    ),

avg_available AS(
    SELECT AVG(available_qty) AS avg_available_qty
    FROM product_totals
)

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

CROSS JOIN avg_available

GROUP BY
    p.sku,
    p.product_name,
    avg_available.avg_available_qty

HAVING
    (SUM(s.quantity) - SUM(s.reserved_qty)) > avg_available.avg_available_qty

ORDER BY
    available_quantity DESC;


-- 34
-- Товары, у которых доступный остаток выше среднего доступного остатка по всем товарам.

SELECT
    p.sku,
    p.product_name,
    p.base_unit

FROM
    product AS p

LEFT JOIN
        stock AS s
ON s.product_id = p.product_id

WHERE
    s.quantity IS NULL

ORDER BY
    p.sku ASC;


-- 35
-- Поиск товаров, у которых есть остаток, но весь товар полностью зарезервирован.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    SUM(s.quantity) > 0
AND (SUM(s.quantity) - SUM(s.reserved_qty)) = 0


ORDER BY
    p.sku ASC;


-- 36
-- Поиск товаров, у которых доступный остаток составляет менее 20%
-- от общего количества товара.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity,
    ROUND(((SUM(s.quantity) - SUM(s.reserved_qty))/SUM(s.quantity)*100),2) AS available_percent

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    SUM(s.quantity) > 0
AND ((SUM(s.quantity) - SUM(s.reserved_qty))/SUM(s.quantity)*100) < 20

ORDER BY
    available_percent ASC,
    p.sku ASC;


-- 37
-- Поиск товаров с максимальным количеством stock-записей.

SELECT
    p.sku,
    p.product_name,
    COUNT(s.stock_id) AS stock_count

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    stock_count DESC,
    p.sku ASC;


-- 38
-- Поиск товаров, которые хранятся более чем в одной транспортной упаковке.

SELECT
    p.sku,
    p.product_name,
    COUNT(DISTINCT(tp.package_id)) AS package_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    COUNT(DISTINCT(tp.package_id)) > 1

ORDER BY
    package_count DESC,
    total_quantity DESC,
    p.sku ASC;


-- 39
-- Поиск складов, на которых хранится более 1000 единиц товара.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    SUM(s.quantity) AS total_quantity,
    COUNT(tp.package_id) AS package_count

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

JOIN
        warehouse AS w
ON w.warehouse_id = z.warehouse_id

GROUP BY
    w.warehouse_code,
    w.warehouse_name

HAVING
    SUM(s.quantity) > 1000

ORDER BY
    total_quantity DESC,
    warehouse_code ASC;


-- 40
-- Поиск складов, на которых хранится более 5 различных товаров.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    COUNT(DISTINCT (p.product_id)) AS product_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

JOIN
        warehouse AS w
ON w.warehouse_id = z.warehouse_id

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    w.warehouse_code,
    w.warehouse_name

HAVING
    COUNT(DISTINCT (p.product_id)) > 5

ORDER BY
    product_count DESC,
    warehouse_code ASC;


-- 41
-- Поиск зон, в которых хранится более 500 единиц товара.

SELECT
    z.zone_name,
    z.zone_type,
    COUNT(tp.package_id) AS package_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

GROUP BY
    z.zone_name,
    z.zone_type

HAVING
    SUM(s.quantity) > 500

ORDER BY
    total_quantity DESC,
    z.zone_name ASC;


-- 42
-- Поиск зон с наибольшим количеством зарезервированного товара.

SELECT
    z.zone_name,
    z.zone_type,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity


FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

GROUP BY
    z.zone_name,
    z.zone_type

HAVING
    SUM(s.reserved_qty) > 100

ORDER BY
    total_reserved DESC,
    z.zone_name ASC;


-- 43
-- Поиск складов, на которых доступный остаток составляет более 70%
-- от общего количества товара.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity,
    ROUND((SUM(s.quantity) - SUM(s.reserved_qty))/SUM(s.quantity)*100,2) AS available_percent

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

JOIN
        warehouse AS w
ON w.warehouse_id = z.warehouse_id

GROUP BY
    w.warehouse_code,
    w.warehouse_name

HAVING
    SUM(s.quantity) > 0
AND ((SUM(s.quantity) - SUM(s.reserved_qty))/SUM(s.quantity)*100) > 70

ORDER BY
    available_percent DESC,
    warehouse_code ASC;


-- 44
-- Поиск товаров, которые хранятся в нескольких разных зонах.

SELECT
    p.sku,
    p.product_name,
    COUNT(DISTINCT l.zone_id) AS zone_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    COUNT(DISTINCT l.zone_id) >2

ORDER BY
    zone_count DESC,
    p.sku ASC;


-- 45
-- Поиск зон, в которых хранится более 5 различных товаров.

SELECT
    z.zone_name,
    z.zone_type,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    z.zone_name,
    z.zone_type

HAVING
    COUNT(DISTINCT p.product_id) > 5

ORDER BY
    product_count DESC,
    z.zone_name ASC;


-- 46
-- Поиск ячеек, в которых хранится более одной транспортной упаковки.

SELECT
    l.address,
    l.location_status,
    COUNT(DISTINCT tp.package_id) AS package_count,
    SUM(tp.gross_weight) AS total_weight

FROM
    location AS l

JOIN
        transport_package AS tp
ON l.location_id = tp.location_id
AND tp.package_status = 'STORED'

GROUP BY
    l.address,
    l.location_status

HAVING
    COUNT(DISTINCT tp.package_id) > 1

ORDER BY
    package_count DESC,
    l.address ASC;


-- 47
-- Поиск складов, на которых есть заблокированные транспортные упаковки.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    COUNT(tp.block_code) AS blocked_packages,
    SUM(tp.gross_weight) AS blocked_weight

FROM
    transport_package AS tp

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
AND tp.block_code IS NOT NULL

GROUP BY
    w.warehouse_code,
    w.warehouse_name

HAVING
    COUNT(DISTINCT tp.package_id) >= 1

ORDER BY
    blocked_packages DESC,
    w.warehouse_code ASC;


-- 48
-- Поиск складов, на которых есть товары с истекающим сроком годности
-- в ближайшие 30 дней.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(s.quantity) AS total_quantity

FROM
    stock AS s

JOIN
        product AS p
        ON p.product_id = s.product_id

JOIN
    transport_package AS tp
        ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

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
    s.expiration_date IS NOT NULL
  AND s.expiration_date >= CURRENT_DATE
  AND s.expiration_date <= (CURRENT_DATE + INTERVAL '30 days')
AND s.quantity > 0

GROUP BY
    w.warehouse_code,
    w.warehouse_name

ORDER BY
    total_quantity DESC,
    w.warehouse_code ASC;


-- 49
-- Поиск владельцев, у которых доступный остаток превышает 1000 единиц.

SELECT
    o.owner_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS reserved_quantity,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
        AND tp.package_status = 'STORED'

JOIN
        owner_product AS op
ON op.product_id = s.product_id

JOIN
        owner AS o
ON o.owner_id = op.owner_id

GROUP BY
    o.owner_name

HAVING
    (SUM(s.quantity) - SUM(s.reserved_qty)) > 1000

ORDER BY
    available_quantity DESC,
    owner_name ASC;


-- 50
-- Поиск товаров, у которых весь доступный остаток находится
-- только в одной транспортной упаковке.

SELECT
    p.sku,
    p.product_name,
    COUNT(DISTINCT s.package_id) AS package_count,
    SUM(s.quantity) AS total_quantity,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
AND tp.package_status = 'STORED'

GROUP BY
    p.sku,
    p.product_name

HAVING
    COUNT(DISTINCT s.package_id) = 1
AND (SUM(s.quantity) - SUM(s.reserved_qty)) > 0

ORDER BY
    available_quantity DESC,
    p.sku ASC;


-- 51
-- Поиск товаров, которые хранятся в нескольких транспортных упаковках,
-- но при этом имеют менее 100 единиц доступного остатка.

SELECT
    p.sku,
    p.product_name,
    COUNT(DISTINCT s.package_id) AS package_count,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id
AND tp.package_status = 'STORED'

GROUP BY
    p.sku,
    p.product_name

HAVING
    COUNT(DISTINCT s.package_id) > 1
AND (SUM(s.quantity) - SUM(s.reserved_qty)) > 0
AND (SUM(s.quantity) - SUM(s.reserved_qty)) < 100

ORDER BY
    available_quantity ASC,
    package_count DESC,
    p.sku ASC;


-- 52
-- Классификация товаров по доступному остатку.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity) - SUM(s.reserved_qty)) AS available_quantity,
    CASE
        WHEN (SUM(s.quantity) - SUM(s.reserved_qty)) = 0 THEN 'OUT_OF_STOCK'
        WHEN (SUM(s.quantity) - SUM(s.reserved_qty)) < 100 THEN 'LOW'
        WHEN (SUM(s.quantity) - SUM(s.reserved_qty)) < 500 THEN 'MEDIUM'
ELSE 'HIGH'
END  AS stock_category

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    available_quantity ASC,
    p.sku ASC;


-- 53
-- Классификация товаров по проценту зарезервированного остатка.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    ROUND(SUM(s.reserved_qty)/SUM(s.quantity)*100,2) AS reserved_percent,
    CASE
        WHEN (SUM(s.reserved_qty)/SUM(s.quantity)*100) = 0 THEN 'NO_RESERVE'
        WHEN (SUM(s.reserved_qty)/SUM(s.quantity)*100) < 30 THEN 'LOW'
        WHEN (SUM(s.reserved_qty)/SUM(s.quantity)*100) < 70 THEN 'MEDIUM'
ELSE 'HIGH'
END  AS reservation_level

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

HAVING
    SUM(s.quantity) > 0

ORDER BY
    reserved_percent DESC,
    p.sku ASC;


--54
-- Подсчёт количества транспортных упаковок разных статусов
-- по каждому складу.

SELECT
    w.warehouse_code,
    w.warehouse_name,
    SUM(
    CASE
        WHEN tp.package_status = 'STORED' THEN 1
    ELSE 0
    END
    ) AS stored_count,
    SUM(
    CASE
        WHEN tp.block_code IS NOT NULL THEN 1
    ELSE 0
    END
    ) AS blocked_count,
    COUNT(tp.package_id) AS total_count

FROM
    transport_package AS tp

JOIN
        location AS l
ON l.location_id = tp.location_id

JOIN
        zone AS z
ON z.zone_id = l.zone_id

JOIN
        warehouse AS w
ON w.warehouse_id = z.warehouse_id

GROUP BY
    w.warehouse_code,
    w.warehouse_name

ORDER BY
    total_count DESC,
    w.warehouse_code ASC;


-- 55
-- Подсчёт количества товара в зависимости от наличия резерва.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(
    CASE
        WHEN s.reserved_qty > 0 THEN s.quantity
    ELSE 0
    END
    ) AS reserved_quantity,
    SUM(
            CASE
                WHEN s.reserved_qty = 0 THEN s.quantity
    ELSE 0
    END
    ) AS free_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    free_quantity DESC,
    p.sku ASC;


-- 56
-- Подсчёт количества stock-записей и количества товара
-- с резервом и без резерва по каждому товару.

SELECT
    p.sku,
    p.product_name,
    SUM(
    CASE
        WHEN s.reserved_qty > 0 THEN 1
    ELSE 0
    END
    ) AS reserved_stock_count,

    SUM(
            CASE
                WHEN s.reserved_qty = 0 THEN 1
    ELSE 0
    END
    ) AS free_stock_count,
    SUM(
    CASE
        WHEN s.reserved_qty > 0 THEN s.quantity
    ELSE 0
    END
    ) AS reserved_quantity,
    SUM(
            CASE
                WHEN s.reserved_qty = 0 THEN s.quantity
    ELSE 0
    END
    ) AS free_quantity

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    reserved_quantity DESC,
    p.sku ASC;


-- 57
-- Классификация stock-записей по доступному количеству.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    s.reserved_qty,
    s.quantity - s.reserved_qty AS available_quantity,

    CASE
        WHEN s.quantity - s.reserved_qty  = 0 THEN 'EMPTY'
    WHEN s.quantity - s.reserved_qty < 50 THEN 'LOW'
    WHEN s.quantity - s.reserved_qty <100 THEN 'MEDIUM'
    ELSE 'OK'
    END
     AS availability_status

FROM
    stock AS s

ORDER BY
    available_quantity ASC,
    s.stock_id ASC;


-- 58
-- Поиск всех товаров и расчёт их общего остатка.

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
    total_quantity DESC,
    p.sku ASC;


-- 59
-- Поиск всех товаров и расчёт общего и зарезервированного остатка.

SELECT
    p.sku,
    p.product_name,
    COALESCE(SUM(s.quantity),0) AS total_quantity,
    COALESCE(SUM(s.reserved_qty),0) AS total_reserved,
    COALESCE(SUM(s.quantity)-SUM(s.reserved_qty),0) AS available_quantity

FROM
    product AS p

LEFT JOIN
        stock AS s
ON s.product_id = p.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    available_quantity DESC,
    p.sku ASC;


-- 60
-- Расчёт процента зарезервированного товара по каждому товару.

SELECT
    p.sku,
    p.product_name,
    COALESCE(SUM(s.quantity),0) AS total_quantity,
    COALESCE(SUM(s.reserved_qty),0) AS reserved_quantity,
    COALESCE(ROUND(SUM(s.reserved_qty)/NULLIF(SUM(s.quantity),0)*100,2),0) AS reserved_percent

FROM
    product AS p

LEFT JOIN
        stock AS s
ON s.product_id = p.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    reserved_percent DESC,
    p.sku ASC;

