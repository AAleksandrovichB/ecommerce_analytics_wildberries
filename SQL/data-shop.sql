-- Переименовали необходимые колонки [в таблице sales]
ALTER TABLE sales
RENAME COLUMN `Бренд` TO brand,
RENAME COLUMN `Предмет` TO category,
RENAME COLUMN `Наименование` TO title,
RENAME COLUMN `Размер` TO ssize,
RENAME COLUMN `Склад` TO warehouse,
RENAME COLUMN `шт.` TO qty,
RENAME COLUMN `Выкупили, шт.` TO  ordered_qty;
-- Переименовали необходимые колонки [в таблице sales]
ALTER TABLE sales
RENAME COLUMN qty TO orders_qty;
-- Переименовали необходимые колонки [в таблице sales
ALTER TABLE sales
RENAME COLUMN ordered_qty TO bought_qty;
-- Для удобства меням артикул с INT на VARCHAR [в таблице sales] 
ALTER TABLE sales
MODIFY COLUMN sku_WB VARCHAR(50);
-- Удаляем колонку collection 162 строки пустые и не несёт аналитической ценности [в таблице sales]
ALTER TABLE sales
DROP COLUMN collection;
-- Меняем значение размера регистраторов с 0 на 'без размера' [в таблице sales]
UPDATE sales
SET ssize = 'без размера'
WHERE ssize = '0';
-- Меняем Символ М с кирилицы на латиницу [в таблице sales]
UPDATE sales
SET ssize = 'M'
WHERE ssize = 'М';
-- Выставляем флаги buyout_anomaly на строки где вкупов больше, чем заказов. Для удовбства в дальнейших расчетах. [в таблице sales]
ALTER TABLE sales
ADD COLUMN buyout_anomaly INT DEFAULT 0;
UPDATE sales
SET buyout_anomaly = 1
WHERE bought_qty > orders_qty OR payout < 0;
-- Объединяем три #статистические#рекламные#помесячные таблицы за февраль, март и апрел в одну [rek_stat].
CREATE TABLE rek_stat AS 
SELECT * FROM rek_stat_feb
UNION ALL
SELECT * FROM rek_stat_mar
UNION ALL 
SELECT * FROM rek_stat_apr;
-- Удаляем колонку duration не несёт аналитической ценности [в таблице rek_stat]
ALTER TABLE rek_stat
DROP COLUMN duration;
-- Меням начало и кончание рекламной компании с VARCHAR на DATETIME [в таблице rek_stat]
ALTER TABLE rek_stat
MODIFY COLUMN started_at DATETIME,
MODIFY COLUMN finished_at DATETIME;
-- Создаю колонку месяц для дальнейшего удобства анализа динамики.
ALTER TABLE rek_stat
ADD COLUMN month VARCHAR(50);
UPDATE rek_stat
SET month = CASE
    WHEN started_at >= '2026-02-01' AND started_at < '2026-03-01' THEN 'february'
    WHEN started_at >= '2026-03-01' AND started_at < '2026-04-01' THEN 'march'
    WHEN started_at >= '2026-04-01' AND started_at < '2026-05-01' THEN 'april'
END;
-- Обнаружил, что рекламные компании ведутся годами, а изначально были представлоенны, как компании првоеденные в конкретных месяцах одного года.
ALTER TABLE rek_stat
DROP COLUMN MONTH;
-- Как выяснилось позже при проверке гипотез, все данные в трёх раннее соединеных таблица rek_stat, данные одни и 
-- теже, а не как было заявленно по месяцам. Удаляем дубликаты.
-- Создаем временную таблицу только с уникальными строками
CREATE TABLE rek_stat_clean AS
SELECT DISTINCT * FROM rek_stat;
-- Удаляем старую таблицу с дублями
DROP TABLE rek_stat;
-- Переименовываем чистую таблицу в оригинальное название
ALTER TABLE rek_stat_clean RENAME TO rek_stat;
-- Удаляем старые  таблицы за ненадобностью
DROP TABLE rek_stat_feb;
DROP TABLE rek_stat_mar;
DROP TABLE rek_stat_apr;

