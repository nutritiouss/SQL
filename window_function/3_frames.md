## Фрэймы
 ROWS | GROUPS | RANGE
- **Задача 1**
<br>Напишите запрос, который для каждого сотрудника выведет:
  - размер з/п предыдущего по зарплате сотрудника (среди коллег по департаменту);
  - максимальную з/п по департаменту.
    ```
    SELECT
    id, name, department, salary,
    first_value(salary) OVER w AS prev_salary,
    last_value(salary) OVER w AS max_salary
    FROM employees
    WINDOW w AS (
    partition by department order by salary
    rows between 1 preceding and unbounded following
    )
    ORDER BY department, id;
    ```

- **Задача 2**
<br>Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим посчитать 
количество сотрудников, которые получают такую же или большую зарплату ```(ge_cnt)```:
    ```
    SELECT id,name,salary,
    COUNT(salary) OVER w as ge_cnt 
    FROM employees
    WINDOW w as (
    order by salary DESC
    groups between unbounded preceding and current row)
    ORDER BY salary ASC
    ```
- **Задача 3**
  <br>Есть таблица сотрудников ``employees``. Предположим, для 
каждого человека мы хотим увидеть ближайшую большую зарплату ```(next_salary)```
    ```
      SELECT id,name,salary,
      last_value(salary) OVER w as next_salary 
      FROM employees
      WINDOW w as (
      order by salary 
      groups between 1 following  and 1 following 
      )
   ```    
- **Задача 4**
<br>Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим посчитать количество сотрудников,
которые получают такую же или большую зарплату, но не более чем +10 тыс. ₽ ``(p10_cnt)``:
    ```
    SELECT id,name,salary,
    COUNT(salary) OVER w as p10_cnt 
    FROM employees
    WINDOW w as (
    ORDER BY salary 
    range between current row  and 10 following  
    )
    ```
- **Задача 5**
<br>Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим определить 
 максимальную зарплату среди тех, у кого зарплата на 10–30 тыс. ₽ меньше чем у него:

  ```
    SELECT id,name,salary,
    last_value(salary) OVER w as lower_sal 
    FROM employees
    WINDOW w as (
    order by salary 
    range between 30 preceding  and 10 preceding  
    )
