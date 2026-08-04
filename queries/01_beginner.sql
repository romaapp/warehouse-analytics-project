-- базовый SELECT, WHERE, ORDER BY

--1
--Вывод списка всех активных и неактивных товаров с их SKU, названием,
--базовой единицей измерения и весом, отсортированного по SKU.

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
--Поиск активных товаров с весом более 1 кг.
--Результат отсортирован по весу от большего к меньшему.

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
--Поиск сохранённых транспортных упаковок типа PALLET или BOX.
--Упаковки отсортированы сначала по типу, затем по весу от большего к меньшему.

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






