--STOCK

WITH stock_data AS (

    SELECT
        tp.package_id,
        p.product_id,
        (floor(random()*191)+10)::numeric(12,3) AS quantity,

        CASE
            WHEN p.lot_tracking
    THEN CURRENT_DATE-((random()*60)::int)
    ELSE NULL
    END AS production_date,

        p.lot_tracking,
        p.expiration_tracking,
        p.shelf_life_days

    FROM  transport_package tp

    JOIN product p
    ON p.product_id=((tp.package_id-1)%31)+1
)

INSERT INTO stock (package_id,
                   product_id,
                   quantity,
                   reserved_qty,
                   lot_number,
                   production_date,
                   expiration_date
)
SELECT
    package_id,
    product_id,
    quantity,
    0::numeric(12,3),

    CASE
        WHEN lot_tracking
THEN 'LOT-' ||LPAD(package_id::text,6,'0')
ELSE NULL
END,

    production_date,

    CASE
        WHEN expiration_tracking
            AND production_date IS NOT NULL
THEN  production_date + shelf_life_days
        ELSE NULL
END

FROM stock_data;