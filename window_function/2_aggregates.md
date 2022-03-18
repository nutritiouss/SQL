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

    
    
