CREATE TABLE transport_package (
    package_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sscc VARCHAR(18) NOT NULL,
    package_code VARCHAR(18) NOT NULL,
    package_type TEXT NOT NULL,
    location_id INTEGER NOT NULL,
    package_status TEXT NOT NULL,
    gross_weight NUMERIC(10,3) NOT NULL,
    owner_id INTEGER NOT NULL,
    block_code TEXT,
    barcode VARCHAR(50) NOT NULL,
    parent_package_id BIGINT,
    created_by INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_trpack_sscc
        UNIQUE (sscc),

    CONSTRAINT uq_trpack_package_code
        UNIQUE (package_code),

    CONSTRAINT chk_block_code
        CHECK ( block_code IS NULL OR trim(block_code)<> ''),

    CONSTRAINT chk_trpack_weight
        CHECK (gross_weight>0),

    CONSTRAINT fk_parent_package
        FOREIGN KEY (parent_package_id) REFERENCES transport_package(package_id),

    CONSTRAINT fk_trpack_locations
        FOREIGN KEY (location_id) REFERENCES location (location_id),

    CONSTRAINT fk_trpack_owner
        FOREIGN KEY (owner_id) REFERENCES owner(owner_id),

    CONSTRAINT fk_trpack_created_by
        FOREIGN KEY (created_by) REFERENCES employee(employee_id),

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

COMMENT ON TABLE transport_package IS 'Транспортные упаковки';
COMMENT ON COLUMN transport_package.package_id IS 'Идентификатор упаковки';
COMMENT ON COLUMN transport_package.sscc IS 'Уникальный код';
COMMENT ON COLUMN transport_package.package_code IS 'Код упаковки';
COMMENT ON COLUMN transport_package.package_type IS 'Тип упаковки';
COMMENT ON COLUMN transport_package.location_id IS 'Идентификатор ячейки';
COMMENT ON COLUMN transport_package.package_status IS 'Статус упаковки';
COMMENT ON COLUMN transport_package.gross_weight IS 'Вес брутто';
COMMENT ON COLUMN transport_package.owner_id IS 'Идентификатор владельца';
COMMENT ON COLUMN transport_package.block_code IS 'Код блокировки упаковки';
COMMENT ON COLUMN transport_package.barcode IS 'Штрихкод';
COMMENT ON COLUMN transport_package.parent_package_id IS 'Родительская упаковка';
COMMENT ON COLUMN transport_package.created_by IS 'Кем создано';
COMMENT ON COLUMN transport_package.created_at IS 'Дата создания';
COMMENT ON COLUMN transport_package.updated_at IS 'Дата обновления';