CREATE TABLE employee (
    employee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    position TEXT NOT NULL,
    warehouse_id INTEGER NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_employee_warehouse
                      FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),

    CONSTRAINT uq_employee_code
                      UNIQUE (employee_code),

    CONSTRAINT chk_first_name
                      CHECK ( trim(first_name)<> '' ),

    CONSTRAINT chk_last_name
                      CHECK ( trim(last_name)<> '' ),

    CONSTRAINT chk_employee_position
                      CHECK ( position IN ('PICKER',
                                          'RECEIVER',
                                          'PACKER',
                                          'SUPERVISOR',
                                          'ADMIN')
                          )
);

COMMENT ON TABLE employee IS 'Сотрудники';
COMMENT ON COLUMN employee.employee_id IS 'Идентификатор сотрудника';
COMMENT ON COLUMN employee.employee_code IS 'Код сотрудника';
COMMENT ON COLUMN employee.first_name IS 'Имя';
COMMENT ON COLUMN employee.last_name IS 'Фамилия';
COMMENT ON COLUMN employee.position IS 'Позиция сотрудника';
COMMENT ON COLUMN employee.warehouse_id IS 'Идентификатор склада';
COMMENT ON COLUMN employee.active IS 'Активность';
COMMENT ON COLUMN employee.created_at IS 'Дата создания';