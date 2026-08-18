-- 69
-- Нумерация товаров по размеру общего остатка.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    ROW_NUMBER() OVER (
        ORDER BY SUM(s.quantity) DESC,
            p.sku ASC
        ) AS row_num

FROM
    product AS p

JOIN
        stock AS s
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    row_num ASC;


-- 70
-- Ранжирование товаров по общему остатку.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    RANK() OVER (
        ORDER BY SUM(s.quantity) DESC
        ) AS rank_num

FROM
    product AS p

JOIN
        stock AS s
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    rank_num ASC,
    p.sku ASC;


-- 71
-- Ранжирование товаров по общему остатку
-- без пропусков в рангах.

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_quantity,
    DENSE_RANK() OVER (
        ORDER BY SUM(s.quantity) DESC
        ) AS rank_num

FROM
    product AS p

JOIN
        stock AS s
ON p.product_id = s.product_id

GROUP BY
    p.sku,
    p.product_name

ORDER BY
    rank_num ASC,
    p.sku ASC;


-- 72
-- Расчёт общего количества товара на складе
-- с сохранением отдельных stock-записей.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    SUM(s.quantity) OVER () AS warehouse_total

FROM
    stock AS s

ORDER BY
    s.stock_id ASC;


-- 73
-- Расчёт общего количества товара по каждому product_id
-- с сохранением отдельных stock-записей.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    SUM(s.quantity) OVER (
        PARTITION BY s.product_id
        ) AS product_total

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 74
-- Расчёт среднего количества товара
-- для каждого product_id с сохранением отдельных stock-записей.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    AVG(s.quantity) OVER (
        PARTITION BY s.product_id
        ) AS avg_product_quantity

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 75
-- Поиск stock-записей, количество товара в которых
-- выше среднего количества для соответствующего товара.

SELECT
    stock_with_avg.stock_id,
    stock_with_avg.product_id,
    stock_with_avg.quantity,
    stock_with_avg.avg_quantity

FROM (
    SELECT
        stock_id,
        product_id,
        quantity,
        AVG(quantity) OVER (
            PARTITION BY product_id
            ) AS avg_quantity
    FROM
        stock
     ) AS stock_with_avg

WHERE
    stock_with_avg.quantity > stock_with_avg.avg_quantity

ORDER BY
    stock_with_avg.product_id ASC,
    stock_with_avg.quantity DESC,
    stock_with_avg.stock_id ASC;


-- 76
-- Расчёт накопительного количества товара
-- по stock-записям.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    SUM(s.quantity) OVER (
        ORDER BY s.stock_id
        ) AS running_total

FROM
    stock AS s

ORDER BY
    s.stock_id ASC;


-- 77
-- Расчёт накопительного количества товара
-- отдельно для каждого product_id.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    SUM(s.quantity) OVER (
        PARTITION BY s.product_id
        ORDER BY s.stock_id
        ) AS running_product_total

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 78
-- Сравнение количества товара в текущей stock-записи
-- с количеством в предыдущей stock-записи.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    LAG(s.quantity) OVER (
        ORDER BY s.stock_id
        ) AS previous_quantity

FROM
    stock AS s

ORDER BY
    s.stock_id ASC;


-- 79
-- Сравнение количества товара в текущей stock-записи
-- с предыдущей stock-записью этого же товара.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    LAG(s.quantity) OVER  (
        PARTITION BY s.product_id
        ORDER BY s.stock_id
        ) AS previous_quantity

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 80
-- Расчёт изменения количества товара
-- относительно предыдущей stock-записи этого же товара.

SELECT
    pq.stock_id,
    pq.product_id,
    pq.quantity,
    pq.previous_quantity,
    pq.quantity - pq.previous_quantity AS quantity_change

FROM (
    SELECT
        stock_id,
        product_id,
        quantity,
        LAG(quantity) OVER (
            PARTITION BY product_id
            ORDER BY stock_id
            ) AS previous_quantity
    FROM stock
     ) AS pq

ORDER BY
    pq.product_id ASC,
    pq.stock_id ASC;


-- 81
-- Получение количества товара
-- в следующей stock-записи этого же товара.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    LEAD(s.quantity) OVER (
        PARTITION BY s.product_id
        ORDER BY s.stock_id
        ) AS next_quantity

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 82
-- Расчёт изменения количества товара
-- относительно следующей stock-записи этого же товара.

SELECT
    nq.stock_id,
    nq.product_id,
    nq.quantity,
    nq.next_quantity,
    nq.quantity - nq.next_quantity AS quantity_change

FROM (
    SELECT
        stock_id,
        product_id,
        quantity,
        LEAD(quantity) OVER (
            PARTITION BY product_id
            ORDER BY stock_id
            ) AS next_quantity
    FROM
        stock
     ) AS nq

ORDER BY
    nq.product_id ASC,
    nq.stock_id ASC;


-- 83
-- Получение количества товара
-- в первой stock-записи каждого product_id.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    FIRST_VALUE(s.quantity) OVER (
        PARTITION BY s.product_id
        ORDER BY s.stock_id
        ) AS first_quantity

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 84
-- Получение количества товара
-- в последней stock-записи каждого product_id.

SELECT
    s.stock_id,
    s.product_id,
    s.quantity,
    LAST_VALUE(s.quantity) OVER (
        PARTITION BY s.product_id
        ORDER BY s.stock_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS first_quantity

FROM
    stock AS s

ORDER BY
    s.product_id ASC,
    s.stock_id ASC;


-- 85
-- Расчёт изменения количества товара
-- относительно первой stock-записи этого же товара.

SELECT
    fq.stock_id,
    fq.product_id,
    fq.quantity,
    fq.first_quantity,
    fq.quantity - fq.first_quantity AS quantity_change

FROM (
    SELECT
        stock_id,
        product_id,
        quantity,
        FIRST_VALUE(quantity) OVER (
            PARTITION BY product_id
            ORDER BY stock_id
            ) AS first_quantity
    FROM
        stock
     ) AS fq

ORDER BY
    fq.product_id ASC,
    fq.stock_id ASC;


-- 86
-- Распределение товаров по четырём группам
-- в зависимости от общего остатка.

SELECT
    sq.sku,
    sq.product_name,
    sq.total_quantity,
    NTILE(4) OVER (
        ORDER BY sq.total_quantity DESC
        ) AS quantity_group

FROM (
    SELECT
        p.sku,
        p.product_name,
        SUM(s.quantity) AS total_quantity
    FROM
        product AS p
    JOIN
        stock AS s
    ON p.product_id = s.product_id
    GROUP BY
       p.sku,
       p.product_name
     ) AS sq

ORDER BY
    quantity_group ASC,
    total_quantity DESC,
    sq.sku ASC;


-- 87
-- Распределение товаров по четырём группам
-- в зависимости от доступного остатка.
