## Функции ранжирования и смещения

- **Задача 1**
<br>В компании работают сотрудники из Москвы и Самары. Предположим, мы хотим разбить их на две группы по зарплате
:
    ```
    SELECT
    ntile(2) over w as tile,
    name, city, salary
    FROM employees
    WINDOW w AS (partition by city 
                 order by salary )
    ORDER BY city, tile,salary  ;
 
    ```

- **Задача 2**
<br> Мы хотим узнать самых высокооплачиваемых людей по каждому департаменту
  ```
  SELECT
  dense_rank() over w as `rank`,
  name, department, salary
  FROM employees
  WINDOW w as (order by salary desc)
  ORDER BY `rank`, id;
    ```
- **Задача 3**
  <br>Предположим, мы хотим для каждого сотрудника увидеть зарплаты предыдущего и следующего коллеги    
    ```
    SELECT  name, department,
    lag(salary, 1) over (order by salary)   as prev,
    salary,
    lead(salary, 1) over (order by salary) as next
    FROM employees
    ORDER BY salary, id;
    ```    
- **Задача 4**
<br>Предположим, мы хотим для каждого сотрудника увидеть, сколько процентов составляет его зарплата от максимальной в городе

    ```
    SELECT name,city,salary,
      ROUND(1-1.0 *(max_city-salary)/max_city,2)*100 as percent  
    FROM(
    SELECT
      *,last_value(salary)over w as max_city
    FROM employees
    WINDOW w AS (
      partition by city
      order by salary
      rows between unbounded preceding and unbounded following
    )
    ORDER BY city,salary, id) as tmp
    ```

    
    
