CREATE TABLE stock (
    stock_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    package_id BIGINT NOT NULL,
    product_id INTEGER NOT NULL,
    quantity NUMERIC(12,3) NOT NULL,
    reserved_qty NUMERIC(12,3) NOT NULL DEFAULT 0,
    lot_number VARCHAR(50),
    production_date DATE,
    expiration_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_stock_product
                   FOREIGN KEY (product_id) REFERENCES product (product_id),

    CONSTRAINT fk_stock_package
                   FOREIGN KEY (package_id) REFERENCES transport_package (package_id),

    CONSTRAINT chk_quantity
                   CHECK ( quantity>0 ),

    CONSTRAINT chk_reserved_qty
                   CHECK ( reserved_qty>=0
                       AND reserved_qty<=quantity ),

    CONSTRAINT uq_stock_package
                   UNIQUE (package_id),

    CONSTRAINT chk_stock_dates
                   CHECK ( expiration_date IS NULL
                       OR production_date IS NULL
                       OR production_date<=expiration_date)
);

COMMENT ON TABLE stock IS 'Сток';
COMMENT ON COLUMN stock.stock_id IS 'Идентификатор стока';
COMMENT ON COLUMN stock.package_id IS 'Идентификатор упаковки';
COMMENT ON COLUMN stock.product_id IS 'Идентификатор артикула';
COMMENT ON COLUMN stock.quantity IS 'Общее количество';
COMMENT ON COLUMN stock.reserved_qty IS 'Зарезервированное количество';
COMMENT ON COLUMN stock.lot_number IS 'Номер партии';
COMMENT ON COLUMN stock.production_date IS 'Дата производства';
COMMENT ON COLUMN stock.expiration_date IS 'Срок годности';
COMMENT ON COLUMN stock.created_at IS 'Дата создания';
COMMENT ON COLUMN stock.updated_at IS 'Дата обновления';