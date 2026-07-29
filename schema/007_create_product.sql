CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    base_unit TEXT NOT NULL,
    weight NUMERIC(10,3) NOT NULL,
    length NUMERIC(10,2) NOT NULL,
    width NUMERIC(10,2) NOT NULL,
    height NUMERIC(10,2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    lot_tracking BOOLEAN NOT NULL DEFAULT FALSE,
    serial_tracking BOOLEAN NOT NULL DEFAULT FALSE,
    expiration_tracking BOOLEAN NOT NULL DEFAULT FALSE,
    shelf_life_days INTEGER,

    CONSTRAINT uq_product_sku
                     UNIQUE(sku),

    CONSTRAINT chk_product_base_unit
                     CHECK (base_unit IN ('PCS', 'BOX', 'PALLET')
                         ),

    CONSTRAINT chk_product_weight
                     CHECK(weight >0),

    CONSTRAINT chk_product_length
                     CHECK(length >0),

    CONSTRAINT chk_product_width
                     CHECK(width >0),

    CONSTRAINT chk_product_height
                     CHECK(height >0),

    CONSTRAINT chk_product_shelf_life
                     CHECK ( shelf_life_days IS NULL
                         OR shelf_life_days>0)

);

COMMENT ON TABLE product IS 'Артикулы';
COMMENT ON COLUMN product.product_id IS 'Идентификатор артикула';
COMMENT ON COLUMN product.sku IS 'СКУ';
COMMENT ON COLUMN product.product_name IS 'Название артикула';
COMMENT ON COLUMN product.base_unit IS 'Базовая единица измерения';
COMMENT ON COLUMN product.weight IS 'Вес';
COMMENT ON COLUMN product.length IS 'Длина';
COMMENT ON COLUMN product.width IS 'Ширина';
COMMENT ON COLUMN product.height IS 'Высота';
COMMENT ON COLUMN product.active IS 'Активность';
COMMENT ON COLUMN product.lot_tracking IS 'Отслеживание партии';
COMMENT ON COLUMN product.serial_tracking IS'Отслеживание серийного номера';
COMMENT ON COLUMN product.expiration_tracking IS 'Отслеживание срока годности';
COMMENT ON COLUMN product.shelf_life_days IS 'Срок годности в днях';