CREATE TABLE zone (
    zone_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_id INTEGER NOT NULL,
    zone_name TEXT NOT NULL,
    zone_type TEXT NOT NULL,

    CONSTRAINT fk_zone_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),

    CONSTRAINT uq_zone
        UNIQUE(warehouse_id,zone_name),

    CONSTRAINT chk_zone_type
                  CHECK (zone_type IN ('RECEIVING', 'STORAGE', 'PICKING', 'SHIPPING')
                      )
);