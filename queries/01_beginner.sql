--1

SELECT
    p.sku,
    p.product_name,
    p.base_unit,
    p.weight,
    p.active

FROM
    product p

ORDER BY
    p.sku ASC;


--2

SELECT
    p.sku,
    p.product_name,
    p.weight

FROM
    product p

WHERE
    p.active = TRUE
  AND p.weight > 1

ORDER BY
    p.weight DESC,
    p.sku ASC;


--3

SELECT
    tp.package_id,
    tp.package_code,
    tp.package_type,
    tp.package_status,
    tp.gross_weight

FROM
    transport_package tp

WHERE
    tp.package_type IN ('PALLET', 'BOX')
  AND tp.package_status = 'STORED'

ORDER BY
    tp.package_type ASC,
    tp.gross_weight DESC;


--4

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


--5

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


--6

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


--10

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


--13

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


--14

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


--15

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


--16

SELECT
    p.sku,
    p.product_name,
    tp.package_code,
    s.quantity,
    s.expiration_date

FROM
    stock AS s

JOIN
        product AS p
ON p.product_id = s.product_id

JOIN
        transport_package AS tp
ON tp.package_id = s.package_id

WHERE
    s.expiration_date IS NOT NULL
    AND s.expiration_date > CURRENT_DATE
AND s.expiration_date <= (CURRENT_DATE + INTERVAL '30 days')
AND s.quantity > 0

ORDER BY
    s.expiration_date ASC,
    p.sku ASC;


--17

SELECT
    p.sku,
    p.product_name,
    tp.package_code,
    s.quantity,
    s.expiration_date,
    l.address

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
    s.expiration_date IS NOT NULL
AND s.quantity > 0
AND tp.package_status = 'STORED'
AND s.expiration_date > CURRENT_DATE

ORDER BY
    s.expiration_date ASC,
    p.sku ASC,
    l.address ASC;


--18

SELECT
    p.sku,
    p.product_name,
    tp.package_code,
    s.quantity,
    s.expiration_date,
    l.address

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
    s.expiration_date IS NOT NULL
AND s.quantity > 0
AND tp.package_status = 'STORED'
AND s.expiration_date < CURRENT_DATE

ORDER BY
    s.expiration_date ASC,
    p.sku ASC,
    l.address ASC;


--19

SELECT
    p.sku,
    p.product_name,
    tp.package_code,
    s.quantity,
    s.expiration_date,
    l.address

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
    s.expiration_date IS NOT NULL
AND s.quantity > 0
AND tp.package_status = 'STORED'
AND s.expiration_date = CURRENT_DATE

ORDER BY
    p.sku ASC,
    l.address ASC;


--20

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


--21

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    SUM(s.reserved_qty) AS total_reserved,
    (SUM(s.quantity)-SUM(s.reserved_qty)) AS available_quantity,
    ROUND((SUM(s.reserved_qty)/SUM(s.quantity)*100),2) AS reserved_percent

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
AND (SUM(s.reserved_qty)/SUM(s.quantity)*100) > 20

ORDER BY
    reserved_percent DESC;


--22

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


--23

SELECT
    l.address,
    l.capacity,
    COUNT(tp.sscc) AS package_count,
    ROUND(
            COUNT(tp.sscc)::numeric/l.capacity*100,2) AS occupancy_percent

FROM
    location AS l

LEFT JOIN
        transport_package AS tp
ON tp.location_id = l.location_id
AND tp.package_status = 'STORED'

GROUP BY
    l.address,
    l.capacity

HAVING
    (COUNT(tp.sscc)::numeric/l.capacity*100) > 80

ORDER BY
    occupancy_percent DESC;


--24

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


--25

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


--28

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


--29

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


--32

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



