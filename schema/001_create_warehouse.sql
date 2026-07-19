CREATE TABLE warehouse (
    warehouse_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_code VARCHAR(20) NOT NULL,
    warehouse_name TEXT NOT NULL,
    city TEXT NOT NULL,

    CONSTRAINT uq_warehouse_code
        UNIQUE  (warehouse_code),

    CONSTRAINT  chk_warehouse_code
        CHECK (trim(warehouse_code)<> ''),

    CONSTRAINT uq_warehouse_name
        UNIQUE (city, warehouse_name),

    CONSTRAINT chk_warehouse_name
                       CHECK(trim(warehouse_name)<> ''),

    CONSTRAINT chk_city
                       CHECK(trim(city)<> '')
);

COMMENT ON TABLE warehouse IS 'Склад';
COMMENT ON COLUMN warehouse.warehouse_id IS 'Идентификатор склада';
COMMENT ON COLUMN warehouse.warehouse_code IS 'Код склада';
COMMENT ON COLUMN warehouse.warehouse_name IS 'Наименование склада';
COMMENT ON COLUMN warehouse.city IS 'Город расположения склада';