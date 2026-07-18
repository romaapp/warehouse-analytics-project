CREATE TABLE location (
    location_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    zone_id INTEGER NOT NULL,
    adress TEXT NOT NULL,
    capacity INTEGER,

    CONSTRAINT fk_location_zone
                      FOREIGN KEY (zone_id) REFERENCES zone(zone_id),

    CONSTRAINT uq_location_adress
                      UNIQUE(zone_id, adress),

    CONSTRAINT chk_location_capacity
                      CHECK (capacity >0 )

);