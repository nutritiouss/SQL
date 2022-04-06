WITH t1 as (SELECT *,
                   CASE WHEN agreement_num is NULL THEN '00is_null' ELSE agreement_num END as agr_num,
                   row_number()                                                               OVER (partition by operation_type,agreement_num
				  rows between unbounded preceding and current row)
				  	 as row_n
            FROM operations
            ORDER BY agr_num
),

     t2 as (
         SELECT operation_date,
                agr_num,
                account_id,
                agreement_num,
                last_value(row_n) over w as roww , first_value(operation_type) over w as low_type , last_value(operation_type) over w as high_type, count(*) over w as cnt, last_value(operation_id) over w as id_deb, first_value(operation_id) over w as id_cred , last_value(amount) over w as deb_sum , first_value(amount) over w as cred_sum

         FROM t1 WINDOW W as (partition by row_n, agr_num
    order by operation_type
    rows between unbounded preceding and 1 preceding
    )

ORDER BY operation_date, agr_num
    ),

    t3 as (
SELECT operation_date, agr_num, account_id, agreement_num,
    last_value(row_n) over w as roww,
    first_value(operation_type) over w as low_type,
    last_value(operation_type) over w as high_type,
    count (*) over w as cnt,
    last_value(operation_id) over w as id_deb,
    first_value(operation_id) over w as id_cred,
    last_value(amount) over w as deb_sum,
    first_value(amount) over w as cred_sum

FROM t1
    WINDOW W as (partition by row_n, agr_num
    order by operation_type
    rows between unbounded preceding and unbounded following
    )
ORDER BY operation_date, agr_num ),
    t4 as (
SELECT *
FROM t3
EXCEPT
SELECT *
FROM t2
WHERE id_deb >0)


SELECT account_id,
       operation_date,
       agreement_num,
       id_deb,
       CASE
           WHEN (low_type = high_type AND high_type = 'D') THEN deb_sum
           WHEN (low_type <> high_type) THEN deb_sum
           END as debet,
       id_cred,
       CASE
           WHEN (low_type = high_type AND high_type = 'C' AND id_deb <> id_cred) THEN cred_sum
           WHEN (low_type <> high_type) THEN cred_sum
           WHEN (low_type = high_type) THEN cred_sum
           END as credit
FROM t4
ORDER BY operation_date, agr_num
