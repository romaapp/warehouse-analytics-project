CREATE TABLE location (
    location_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    zone_id INTEGER NOT NULL,
    address VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 1,
    location_status TEXT NOT NULL DEFAULT 'FREE',
CONSTRAINT fk_location_zone
                  FOREIGN KEY (zone_id) REFERENCES zone(zone_id),

CONSTRAINT uq_location_address
                  UNIQUE(zone_id, address),

CONSTRAINT chk_location_capacity
                  CHECK (capacity >0 ),

CONSTRAINT  chk_location_address
                  CHECK ( trim(address)<> ''),

CONSTRAINT  chk_location_status
                  CHECK ( location_status IN ('FREE',
                                             'OCCUPIED',
                                             'BLOCKED',
                                             'DISABLED') )
);
COMMENT ON TABLE location IS 'Ячейки хранения склада';
COMMENT ON COLUMN location.location_id IS 'Идентификатор ячейки';
COMMENT ON COLUMN location.zone_id IS 'Идентификатор технологической зоны';
COMMENT ON COLUMN location.address IS 'Адрес ячейки';
COMMENT ON COLUMN location.capacity IS 'Максимальная вместимость';
COMMENT ON COLUMN location.location_status IS 'Статус ячейки';