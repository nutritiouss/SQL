## Агрегаты
В данной части решаются задачи агрегации, в т.ч. скользящие агрегаты.
- **Задача 1**
<br>Мы хотим для каждого сотрудника увидеть, сколько процентов составляет его 
зарплата от общего фонда труда по городу
    ```
    SELECT name, city, salary,
    sum(salary) over w as fund,
    round(salary * 100.0 / sum(salary) over w) as perc 
    FROM employees
    WINDOW w as (partition by city) 
    ORDER BY city, salary, id; 
    ```

- **Задача 2**
<br>Мы хотим для каждого сотрудника увидеть:
  - сколько человек трудится в его отделе ```(emp_cnt)```;
  - какая средняя зарплата по отделу ``(sal_avg)``;
  - на сколько процентов отклоняется его зарплата от средней по отделу ``(diff)``.
     ```
    SELECT name, department, salary, 
    COUNT(*) OVER (partition by department) as emp_cnt,
    ROUND(AVG(salary) OVER (partition by department)) as sal_avg,
    ROUND(salary * 100.0 / AVG(salary) OVER (partition by department))-100  AS diff  
    FROM employees 
    ORDER BY department, salary, id;
     ```
- **Задача 3**
  <br>Мы хотим рассчитать скользящее среднее по доходам за предыдущий и текущий месяц    
  ```
  SELECT
  year, month, income
  ,round(avg(income) over w) as roll_avg
  FROM expenses
  WINDOW w as (
  OFDER BY year, month
  rows between 1 preceding and 0 following
  )
  ORDER BY year, month;
  ```    
- **Задача 4**
<br> Мы хотим посчитать фонд оплаты труда нарастающим итогом независимо для каждого департамента
   ```
   SELECT
   year, month, income
   ,ROUND(AVG(income) OVER w) AS roll_avg
   FROM expenses
   WINDOW w AS (
   order by year, month
   ROWS between 1 preceding and 0 following
    )
   order by year, month;
    ```

- **Задача 5**
<br> Посчитайте выручку нарастающим итогом по каждому тарифному плану за первые три месяца 2020 года.
   ```
   SELECT plan,
       year,
       month,
       revenue,
       sum(revenue) OVER (PARTITION BY plan ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total
  FROM sales
  WHERE year = '2020'
  AND month BETWEEN 1 AND 3
  ORDER BY plan, month
  ```

- **Задача 6**
<br>Посчитайте выручку по месяцам для тарифа silver. Для каждого месяца дополнительно укажите:
- выручку за декабрь этого же года (december);
- процент, который составляет выручка текущего месяца от december (perc).
  - Процент округлите до целого.

   ```
     SELECT year, month, revenue, nth_value(revenue, 12) over w as december, 
     ROUND((revenue /  nth_value(revenue, 12) over w) * 100) as perc
     FROM sales
     WHERE plan = 'silver'
     window w as (partition by year
              order by year, month
              rows between unbounded preceding and unbounded following)
    ORDER BY year, month
   ```
  другое решение
   ```
    SELECT year,
       month,
       revenue,
       max(CASE WHEN month = 12 THEN revenue END)
       OVER w AS december,
       round(
                       100.0 * revenue / max(CASE WHEN month = 12 THEN revenue END)
                                         OVER w
           )  AS perc
       FROM sales
        WHERE plan = 'silver'
    WINDOW w AS (
        PARTITION BY year
        )
     ORDER BY year, month;
    ```
   другое решение
   ```
   SELECT year,
       month,
       revenue,
       last_value(revenue) OVER w                          AS december,
       round(revenue * 100.0 / last_value(revenue) OVER w) AS perc
   FROM sales
   WHERE plan = 'silver'
   WINDOW w AS (
        PARTITION BY year
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )
   ORDER BY year, month; 
   ```
  решение без оконных функций
   ```
   SELECT a.year,
       a.month,
       a.revenue,
       b.revenue                          AS december,
       round(a.revenue * 100 / b.revenue) AS perc
   FROM sales a
         LEFT JOIN sales b ON a.year = b.year AND a.plan = b.plan
   WHERE a.plan = 'silver'
   AND b.month = 12
   ```

- **Задача 7**
<br> Посчитайте выручку нарастающим итогом по каждому тарифному плану за первые три месяца 2020 года.
   ```
  SELECT year
     , plan
     , sum(revenue)                                         revenue
     , sum(sum(revenue)) OVER w                             total
     , round(sum(revenue) * 100 / sum(sum(revenue)) OVER w) perc
   FROM sales
   GROUP BY year, plan
    WINDOW w AS (PARTITION BY year)
   ORDER BY year, plan
  ```
     другое решение
   ```
  WITH group_revenue  as(
  SELECT  year, plan, SUM(revenue) as revenue
  FROM
    sales
  GROUP BY year,plan
  ORDER BY year, plan)
  
  SELECT *,
  SUM(revenue) OVER (partition by year) as total,
  ROUND(revenue*100/SUM(revenue) OVER (partition by year)) as prec
  FROM group_revenue
  order by year, plan;
   ```
- **Задача 8**
<br> Разбейте месяцы 2020 года на три группы по выручке:

  <br> tile = 1 — высокая,
  <br> tile = 2 — средняя,
  <br> tile = 3 — низкая. <br> 
    
  ```
  WITH group_revenue  as(
  SELECT  year, month, SUM(revenue) as revenue
  FROM
    sales
  WHERE year = 2020
  GROUP BY month
  ORDER BY  revenue DESC)
  
  SELECT *, ntile(3) over () as tile FROM group_revenue
    ```
- **Задача 9**
<br> Посчитайте выручку по кварталам 2020 года. Для каждого квартала дополнительно укажите:

  1. выручку за аналогичный квартал 2019 года (prev);
  2. процент, который составляет выручка текущего квартала от prev (perc).
    
  ```
  WITH group_revenue_2020  as(
  SELECT  year, quarter, SUM(revenue) as revenue
  FROM
    sales
  WHERE year = 2020
  GROUP BY quarter
  ORDER BY  quarter ),
  
  group_revenue_2019  as(
  SELECT  year, quarter, SUM(revenue) as revenue
  FROM
    sales
  WHERE year = 2019
  GROUP BY quarter
  ORDER BY  quarter )
  
  SELECT f.year,f.quarter,
  f.revenue,
  s.revenue as prev,
  ROUND(f.revenue*100/s.revenue) as perc
  FROM group_revenue_2020 as f
  LEFT JOIN group_revenue_2019 as s on f.quarter = s.quarter 
  ```
  другое решение
  ```
  WITH t AS
         (SELECT year
               , quarter
               , sum(revenue)AS revenue
               , first_value(sum(revenue)) OVER (PARTITION BY quarter) AS prev
          FROM sales
          GROUP BY year, quarter)

  SELECT *
       , round(revenue * 100.00 / prev, 0) AS perc
  FROM t
  WHERE year = '2020'
  ```
  другое решение
  ```
  WITH data AS (
    SELECT year,
           quarter,
           sum(revenue) AS revenue,
           lag(sum(revenue), 4) OVER w AS prev,
           round(sum(revenue) * 100.0 / lag(sum(revenue), 4) OVER ()
               )AS perc
    FROM sales
    GROUP BY year, quarter
        WINDOW w AS (RDER BY year, quarter )
    )
  SELECT year,
         quarter,
         revenue,
         prev,
         perc
  FROM data
  WHERE year = 2020
  ORDER BY quarter;
  ```



- **Задача 10**
<br>Составьте рейтинг месяцев 2020 года с точки зрения количества продаж (quantity)
по каждому из тарифов. Чем больше подписок тарифа P было продано в месяц M, тем выше место M в рейтинге по тарифу P:
Например, в декабре было продано больше подписок silver, чем в любой другой месяц (1-е место в столбце silver). 
Для тарифа gold декабрь на 9-м месте, для platinum — на 6-м. Январь же оказался самым слабым месяцем для всех трех тарифов.

 ```
  WITH t_base AS
         (SELECT year
               , month
               , sum(CASE WHEN plan = 'silver' THEN quantity END) AS silver
               , sum(CASE WHEN plan = 'gold' THEN quantity END) AS gold
               , sum(CASE WHEN plan = 'platinum' THEN quantity END) AS platinum
          FROM sales
          GROUP BY year, month)

  SELECT year
       , month
       , rank() OVER (ORDER BY silver DESC )   AS silver
       , rank() OVER (ORDER BY gold DESC)      AS gold
       , rank() OVER (ORDER BY platinum DESC ) AS platinum
  FROM t_base
  WHERE year = '2020'
  ORDER BY month
  ```  
другое решение
  ```
  SELECT year
     , month
     , rank() OVER (ORDER BY sum(CASE WHEN plan = 'silver' THEN quantity END) DESC)   silver
     , rank() OVER (ORDER BY sum(CASE WHEN plan = 'gold' THEN quantity END) DESC)     gold
     , rank() OVER (ORDER BY sum(CASE WHEN plan = 'platinum' THEN quantity END) DESC) platinum
  FROM sales
  WHERE year = 2020
  GROUP BY month
  ORDER BY month
  ```

другое решение
  ```
  WITH data AS (
      SELECT year,
             month,
             plan,
             quantity,
             rank() OVER w AS qrank
      FROM sales
      WHERE year = 2020
          WINDOW w AS (PARTITION BY plan
              ORDER BY quantity DESC  )
  )
  SELECT year,
         month,
         sum(CASE WHEN plan = 'silver' THEN qrank ELSE 0 END)   AS silver,
         sum(CASE WHEN plan = 'gold' THEN qrank ELSE 0 END)     AS gold,
         sum(CASE WHEN plan = 'platinum' THEN qrank ELSE 0 END) AS platinum
  FROM data
  GROUP BY year, month
  ```