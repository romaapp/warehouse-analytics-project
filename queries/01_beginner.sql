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
    total_quantity DESC

