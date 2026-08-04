-- практические аналитические задачи WMS

--16
--Поиск товаров, срок годности которых истекает в течение ближайших 30 дней.
--Используется для контроля потенциально проблемного остатка.

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
--Вывод всех товаров с действующим сроком годности,
--которые находятся на хранении, с указанием конкретной ячейки.

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
--Поиск просроченных товаров, которые всё ещё находятся
--на складе в статусе STORED.

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
--Поиск товаров, срок годности которых истекает сегодня.

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


--21
--Поиск товаров, у которых более 20% общего остатка зарезервировано.
--Используется для анализа уровня резервирования запасов.

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


--23
--Поиск складских ячеек, заполненных более чем на 80%.
--Рассчитывается процент заполненности ячейки.

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