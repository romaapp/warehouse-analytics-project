SELECT
    p.sku,
    p.product_name,
    p.base_unit,
    p.weight,
    p.active

FROM
    product p

ORDER BY
    p.sku
