CREATE TABLE owner (
    owner_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_code VARCHAR(30) NOT NULL,
    owner_name TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_owner_code
                   UNIQUE (owner_code),
    CONSTRAINT chk_owner_code
                   CHECK(trim(owner_code) <> ''),
    CONSTRAINT chk_owner_name
                   CHECK(trim(owner_name) <> '')

);

COMMENT ON TABLE owner IS 'Владелец товара';
COMMENT ON COLUMN owner.owner_code IS 'Уникальный код владельца';
COMMENT ON COLUMN owner.owner_name IS 'Наименование владельца';