## Testovoe 1

- **Задача 1**
<br>Как удалить столбец temp из таблицы MyTable ?
    ```
    ALTER TABLE "MyTable" DROP COLUMN temp; 
    ```

- **Задача 2**
<br>Есть таблица MyTable, в которой есть столбец Age с типом данных – целое число.
Необходимо написать запрос, который бы отображал все столбцы таблицы + столбец с условием,
- если поле Age меньше 13, тогда выводится '' ребенок '', от 13 до 21 '' – подросток '', с 22 до 60 – '' зрелый '', с 61 – '' пенсионер ''.
    ```
    SELECT *,
           CASE
               WHEN MT."Age" < 13 THEN 'Ребенок'
               WHEN MT."Age" >= 13 AND MT."Age" < 22 THEN 'подросток'
               WHEN MT."Age" >= 22 AND MT."Age" < 61 THEN 'зрелый'
               WHEN MT."Age" >= 61 THEN 'пенсионер'
               END TypeAge
    FROM public."MyTable" MT
    ORDER BY id ASC 
    ```
- **Задача 3**
  <br>Необходимо получить список фамилий из таблицы authors, начинающихся на D,
  заканчивающихся на k, и содержащих 1 букву в середине.    
      ```
      SELECT * 
      FROM authors
      WHERE "family" ~ 'D[a-zA-Z]k';
      ```    
- **Задача 4**
<br>Есть таблица для каждого дня месяца: клиент, дата (день), сумма остатка на депозите (баланс).
По каждому клиенту вывести все периоды, в которые баланс отличен от нуля, и средний баланс.
    ```
    WITH grouped_client AS (
    SELECT id_client,
           date,
           balance,
           SUM(CASE WHEN balance = 0 THEN 1 ELSE 0 END) OVER w AS group_from_date
    FROM sber.daily AS D
        WINDOW w AS (PARTITION BY id_client
            		 ORDER BY D.date ASC)
    )
    SELECT  ROUND(avg(id_client)) AS "Клиент",
             MIN(date) AS "Дата 1",
             MAX(date) AS "Дата 2",
             ROUND(avg(balance)) AS "Ср.Баланс"
    FROM grouped_client
    WHERE balance <> 0
    GROUP BY id_client, group_from_date
    ORDER BY id_client, MIN(date);
    ```

    
    
