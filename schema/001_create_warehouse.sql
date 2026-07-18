CREATE TABLE warehouse (
    warehouse_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_name TEXT NOT NULL UNIQUE,
    city TEXT NOT NULL,
    CONSTRAINT chk_warehouse_name
                       CHECK(trim(warehouse_name)<> ''),
    CONSTRAINT chk_city
                       CHECK(trim(city)<> '')
)