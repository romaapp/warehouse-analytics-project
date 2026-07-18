CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku TEXT NOT NULL,
    product_name TEXT NOT NULL,
    unit TEXT NOT NULL,
    weight NUMERIC(10,3) NOT NULL,
    length NUMERIC NOT NULL,
    width NUMERIC NOT NULL,
    height NUMERIC NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    lot_tracking BOOLEAN NOT NULL DEFAULT FALSE,
    serial_tracking BOOLEAN NOT NULL DEFAULT FALSE,
    expiration_tracking BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT uq_product_article
                     UNIQUE(sku),

    CONSTRAINT chk_product_unit
                     CHECK (unit IN ('PCS', 'BOX', 'PALLET')
                         ),

    CONSTRAINT chk_product_weight
                     CHECK(weight >0),

    CONSTRAINT chk_product_length
                     CHECK(length >0),

    CONSTRAINT chk_product_width
                     CHECK(width >0),

    CONSTRAINT chk_product_height
                     CHECK(height >0)

);