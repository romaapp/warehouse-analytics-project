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