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
                  CHECK (zone_type IN ('RECEIVING',
                                       'STORAGE',
                                       'PICKING',
                                       'SHIPPING')
                      ),

    CONSTRAINT chk_zone_type_not_empty
                  CHECK (trim(zone_type)<> ''),

    CONSTRAINT chk_zone_name
                  CHECK (trim(zone_name)<> '')
);

COMMENT ON TABLE zone IS 'Технозоны';
COMMENT ON COLUMN zone.warehouse_id IS 'Идентификатор склада';
COMMENT ON COLUMN zone.zone_id IS 'Идентификатор зоны';
COMMENT ON COLUMN zone.zone_name IS 'Наименование зоны';
COMMENT ON COLUMN zone.zone_type IS 'Тип технологической зоны';