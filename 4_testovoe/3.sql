--------3.1-----------
SELECT org_name           "Организация",
       operation_date     "Дата",
       operation_sum      "Выручка по организации",
       sum(operation_sum) OVER(partition by operation_date) as  "Общая выручка за день", ROUND(100 * operation_sum / sum(operation_sum) OVER(partition by operation_date), 2) AS "Доля выручки"
FROM summary
         LEFT JOIN org ON org.org_id = summary.org_id
ORDER BY operation_date

------------------------ 3.2 ------------

    SET search_path TO lux;
DROP TABLE IF EXISTS lookup;
DROP TABLE IF EXISTS temp_rec;
CREATE
TEMP TABLE lookup
as
SELECT org_name,
       parent_id,
       org.org_id,
       operation_date,
       operation_sum,
       sum(operation_sum) OVER(partition by operation_date) as  full_money, ROUND(100 * operation_sum / sum(operation_sum) OVER(partition by operation_date), 2) AS percent_money
FROM summary
         RIGHT JOIN org ON org.org_id = summary.org_id
ORDER BY operation_date, org_id;

WITH RECURSIVE r AS
                   (
                       SELECT 1                    AS "depth",
                              lookup.org_id,
                              lookup.parent_id,
                              lookup.org_name,
                              lookup.operation_sum,
                              lookup.operation_sum as total
                       FROM lookup
                       WHERE parent_id is NULL
                       UNION ALL
                       SELECT r."depth" + 1,
                              l.org_id,
                              l.parent_id,
                              l.org_name,
                              l.operation_sum,
                              sum(l.operation_sum) OVER (partition by l.parent_id) as total
                       FROM lookup as l
                                JOIN r ON l.parent_id:: int = r.org_id

    )
SELECT max(depth) as depth, max(parent_id::Int) as parent_id, max(total) as total
INTO temporary table temp_rec
FROM r
GROUP BY parent_id;
SELECT *
FROM temp_rec;


SELECT org_name,
       lookup.parent_id,
       lookup.org_id,
       operation_date,
       CASE WHEN operation_sum IS NULL THEN total ELSE operation_sum END,
       full_money,
       percent_money
FROM lookup
         LEFT JOIN temp_rec ON lookup.org_id = temp_rec.parent_id
ORDER BY operation_date DESC, org_id;








