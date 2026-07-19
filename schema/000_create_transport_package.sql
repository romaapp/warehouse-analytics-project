CREATE TABLE transport_package (
    package_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    package_type TEXT NOT NULL,
    location_id INTEGER NOT NULL,
    package_status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gross_weight NUMERIC(10,3) NOT NULL,
    owner_id INTEGER NOT NULL,
    block_code TEXT,
    sscc VARCHAR(18) NOT NULL,
    barcode VARCHAR(50) NOT NULL,
    parent_package_id BIGINT,
    created_by INTEGER NOT NULL,
    updated_at TIMESTAMP NOT NULL NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_trpack_weight
        CHECK (gross_weight>0),

    CONSTRAINT fk_parent_package
        FOREIGN KEY (parent_package_id) REFERENCES transport_package(package_id),

    CONSTRAINT fk_trpack_locations
        FOREIGN KEY (location_id) REFERENCES location (location_id),

--    CONSTRAINT fk_trpack_owner
--        FOREIGN KEY (owner_id) REFERENCES owner(owner_id),

--    CONSTRAINT fk_trpack_created_by
--        FOREIGN KEY (created_by) REFERENCES employee(employee_id),

    CONSTRAINT chk_trpack_package_type
                               CHECK (package_type IN ('PALLET',
                                                       'BOX',
                                                       'CONTAINER',
                                                       'ROLL')
                                   ),

    CONSTRAINT chk_trpack_package_status
                               CHECK (package_status IN ('RECEIVED',
                                                        'PUTAWAY',
                                                        'STORED',
                                                        'PICKING',
                                                        'SHIPPED',
                                                        'LOST',
                                                        'DESTROYED',
                                                        'RESERVED')
                                   )

);