-- pgsql
--Дается таблица "create table dt (date_tt date, id_tt int, summa money)".
--Надо пронумеровать записи внутри каждого значения поля "id_tt",
--SQL 1

SELECT date_tt,
       id_tt,
       summa,
       dense_rank() OVER (PARTITION BY "id_tt"
           ORDER BY summa DESC) AS rn
FROM dt
    WINDOW W AS (PARTITION BY "id_tt"
        ORDER BY summa DESC);

-- SQL 2
--В таблице собраны агрегированные данные по продажам за весь период работы компании в разрезе дата, магазин, товар
--Вывести идентификаторы товаров-новинок ( id_tov) , которые стали продаваться впервые за последние 30 дней.

WITH tmp_table AS (
    SELECT *, dense_rank() OVER w AS rrank
    FROM dtt
        WINDOW w AS (PARTITION BY id_tov ORDER BY date_tt)
)

SELECT DISTINCT id_tov
FROM tmp_table
WHERE rrank = 1
  AND date_tt >= current_date AT TIME ZONE 'UTC' - INTERVAL '30 days'
ORDER BY id_tov DESC;
