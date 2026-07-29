CREATE TABLE owner_product (
    owner_product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    owner_sku VARCHAR(50) NOT NULL ,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_owner_product_owner
                           FOREIGN KEY (owner_id) REFERENCES owner(owner_id),

    CONSTRAINT fk_owner_product_product
                           FOREIGN KEY (product_id) REFERENCES product(product_id),

    CONSTRAINT uq_owner_product
                           UNIQUE (owner_id, product_id),

    CONSTRAINT uq_owner_product_owner_sku
                           UNIQUE (owner_id, owner_sku)
);

COMMENT ON TABLE owner_product IS 'Артикулы владельцев';
COMMENT ON COLUMN owner_product.owner_product_id IS 'Идентификатор владельца артикула';
COMMENT ON COLUMN owner_product.owner_id IS 'Идентификатор владельца товара';
COMMENT ON COLUMN owner_product.product_id IS 'Идентификатор артикула';
COMMENT ON COLUMN owner_product.owner_sku IS 'СКУ владельца';
COMMENT ON COLUMN owner_product.active IS 'Активность';
COMMENT ON COLUMN owner_product.created_at IS 'Дата создания';