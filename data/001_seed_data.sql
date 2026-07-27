--OWNER

INSERT INTO owner (owner_code,
                   owner_name
)
VALUES
    ('NESTLE', 'Nestlé'),
    ('UNILEVER', 'Unilever'),
    ('COCA_COLA', 'Coca-Cola');


--WAREHOUSE

INSERT INTO warehouse (warehouse_code, warehouse_name, city
)
VALUES
    ('WH_MSK', 'Основной склад Москва', 'Москва'),
    ('WH_SPB', 'Основной склад Санкт-Петербург', 'Санкт-Петербург');


--ZONE

INSERT INTO zone (warehouse_id,
                  zone_name,
                  zone_type)
SELECT
    w.warehouse_id,
    z.zone_name,
    z.zone_type
FROM warehouse w
CROSS JOIN (
    VALUES
        ('RECEIVING', 'RECEIVING'),
        ('STORAGE',   'STORAGE'),
        ('PICKING',   'PICKING'),
        ('SHIPPING',  'SHIPPING')
)
AS z(zone_name, zone_type);


--LOCATION

INSERT INTO  location (zone_id,
                       address,
                       capacity)
SELECT
    z.zone_id,
    'ST-' ||
    LPAD(r.row_num::text,2,'0') || '-' ||
LPAD(s.section_num::text,2,'0') || '-' ||
LPAD(l.level_num::text,2,'0'),
    1
FROM  zone z
CROSS JOIN generate_series(1,10) AS r(row_num)
CROSS JOIN generate_series(1,5) AS s(section_num)
CROSS JOIN generate_series(1,3) AS l(level_num)
WHERE  z.zone_type = 'STORAGE';


--EMPLOYEE

INSERT INTO employee (employee_code,
                      first_name,
                      last_name,
                      position,
                      warehouse_id
)
VALUES
('EMP-0001','Иван','Иванов','RECEIVER',1),
('EMP-0002','Петр','Петров','PICKER',1),
('EMP-0003','Сергей','Сергеев','PACKER',1),
('EMP-0004','Алексей','Смирнов','SUPERVISOR',1),
('EMP-0005','Мария','Кузнецова','ADMIN',1),

('EMP-0006','Анна','Орлова','RECEIVER',2),
('EMP-0007','Дмитрий','Васильев','PICKER',2),
('EMP-0008','Елена','Федорова','PACKER',2),
('EMP-0009','Николай','Морозов','SUPERVISOR',2),
('EMP-0010','Ольга','Соколова','ADMIN',2);


--PRODUCT

INSERT INTO product (sku,
                     product_name,
                     base_unit,
                     weight,
                     length,
                     width,
                     height,
                     lot_tracking,
                     serial_tracking,
                     expiration_tracking
)
VALUES
('NES0001', 'Кофе Nescafe Gold 190 г', 'PCS', 0.190, 8, 8, 15, TRUE, FALSE, TRUE),
('NES0002', 'Кофе Nescafe Classic 250 г', 'PCS', 0.250, 9, 9, 18, TRUE, FALSE, TRUE),
('UNI0001', 'Шампунь Dove 400 мл', 'PCS', 0.450, 6, 6, 22, FALSE, FALSE, FALSE),
('UNI0002', 'Гель для душа Axe 250 мл', 'PCS', 0.300, 5, 5, 20, FALSE, FALSE, FALSE),
('CC0001', 'Coca-Cola 1.5 л', 'PCS', 1.600, 9, 9, 32, TRUE, FALSE, TRUE),
('CC0002', 'Fanta 1.5 л', 'PCS', 1.600, 9, 9, 32, TRUE, FALSE, TRUE),
('SPR0001', 'Вода минеральная Borjomi 0.5 л', 'PCS', 0.550, 7, 7, 20, TRUE, FALSE, FALSE),
('SPR0002', 'Сок J7 яблочный 1 л', 'PCS', 1.100, 8, 8, 25, TRUE, FALSE, FALSE),
('MILK001', 'Молоко Parmalat 1 л', 'PCS', 1.050, 8, 8, 22, TRUE, FALSE, TRUE),
('MILK002', 'Йогурт Danone 125 г', 'PCS', 0.140, 5, 5, 10, TRUE, FALSE, TRUE),
('CHS0001', 'Сыр Hochland 200 г', 'PCS', 0.220, 6, 6, 12, TRUE, FALSE, TRUE),
('CHS0002', 'Творог Простоквашино 400 г', 'PCS', 0.420, 7, 7, 14, TRUE, FALSE, TRUE),
('MEAT001', 'Фарш свиной 500 г', 'PCS', 0.520, 8, 8, 15, TRUE, FALSE, TRUE),
('MEAT002', 'Куриная грудка 1 кг', 'PCS', 1.050, 10, 10, 18, TRUE, FALSE, TRUE),
('FISH001', 'Филе трески 600 г', 'PCS', 0.620, 9, 9, 16, TRUE, FALSE, TRUE),
('VEG001', 'Картофель 2.5 кг', 'PCS', 2.600, 12, 12, 20, TRUE, FALSE, TRUE),
('VEG002', 'Морковь 1 кг', 'PCS', 1.050, 8, 8, 15, TRUE, FALSE, TRUE),
('FRT001', 'Яблоки 1 кг', 'PCS', 1.050, 9, 9, 16, TRUE, FALSE, TRUE),
('FRT002', 'Бананы 1 кг', 'PCS', 1.050, 9, 9, 18, TRUE, FALSE, TRUE),
('BAK001', 'Хлеб ржаной 400 г', 'PCS', 0.450, 7, 7, 12, TRUE, FALSE, TRUE),
('BAK002', 'Батон нарезной 350 г', 'PCS', 0.400, 6, 6, 14, TRUE, FALSE, TRUE),
('SWT001', 'Шоколад Alpen Gold 100 г', 'PCS', 0.120, 4, 4, 8, TRUE, TRUE, FALSE),
('SWT002', 'Печенье Юбилейное 200 г', 'PCS', 0.220, 6, 6, 10, TRUE, TRUE, FALSE),
('TEA001', 'Чай Lipton 50 пак.', 'PCS', 0.150, 5, 5, 12, TRUE, TRUE, FALSE),
('TEA002', 'Чай Greenfield 100 г', 'PCS', 0.120, 4, 4, 10, TRUE, TRUE, FALSE),
('OIL001', 'Масло подсолн. Золотая Семечка 1 л', 'PCS', 0.950, 8, 8, 25, TRUE, TRUE, FALSE),
('OIL002', 'Масло сливочное 180 г', 'PCS', 0.200, 5, 5, 10, TRUE, TRUE, FALSE),
('PAST001', 'Макароны Barilla 500 г', 'PCS', 0.520, 7, 7, 18, TRUE, TRUE, FALSE),
('PAST002', 'Рис Мистраль 800 г', 'PCS', 0.850, 8, 8, 20, TRUE, TRUE, FALSE),
('CEREAL001', 'Овсянка 500 г', 'PCS', 0.520, 7, 7, 16, TRUE, TRUE, FALSE),
('CEREAL002', 'Гречка 900 г', 'PCS', 0.950, 8, 8, 20, TRUE, TRUE, FALSE);


--OWNER PRODUCT

INSERT INTO owner_product (owner_id,
                           product_id,
                           owner_sku
)
VALUES
(1,1,'NES-9A2'),
(1,2,'NES-K7M'),
(2,3,'UNI-QP4'),
(2,4,'UNI-5R1'),
(3,5,'CC-8F9'),
(3,6,'CC-3H2'),
(1,7,'SPR-6E4'),
(1,8,'SPR-1B7'),
(1,9,'MILK-9C3'),
(1,10,'MILK-7D8'),
(1,11,'CHS-2F5'),
(1,12,'CHS-4G6'),
(1,13,'MEAT-8H1'),
(1,14,'MEAT-3J9'),
(2,15,'FISH-5K2'),
(2,16,'VEG-7L4'),
(2,17,'VEG-1M6'),
(2,18,'FRT-9N3'),
(2,19,'FRT-2P8'),
(2,20,'BAK-4Q1'),
(2,21,'BAK-6R5'),
(2,22,'SWT-3S7'),
(3,23,'SWT-8T9'),
(3,24,'TEA-1U2'),
(3,25,'TEA-5V4'),
(3,26,'OIL-7W6'),
(3,27,'OIL-9X8'),
(3,28,'PAST-2Y3'),
(3,29,'PAST-4Z1'),
(3,30,'CEREAL-6A7'),
(3,31,'CEREAL-8B9');