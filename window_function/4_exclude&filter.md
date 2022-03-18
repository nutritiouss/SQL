## Exclude and FILTER
Стандарт SQL предусматривает четыре разновидности EXCLUDE:

- EXCLUDE NO OTHERS. Ничего не исключать. Вариант по умолчанию: если явно не указать exclude, сработает именно он.
- EXCLUDE CURRENT ROW. Исключить текущую запись (как мы сделали на предыдущем шаге с сотрудником).
- EXCLUDE GROUP. Исключить текущую запись и все равные ей (по значению столбцов из order by).
- EXCLUDE TIES. Оставить текущую запись, но исключить равные ей.
<br>
<br>
<br>

- **Задача 1**
<br>Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим посчитать среднюю зарплату сотрудников, которые получают столько же или больше, чем он — 
но не более чем +20 тыс. ₽ (p20_sal). При этом зарплату самого сотрудника учитывать не следует:

    ```
    SELECT id,name,salary,
    ROUND(avg(salary) OVER w) as p20_sal 
    FROM employees
    WINDOW w AS (
    order by salary 
    range between current row and 20 following
    exclude current row
    )
    ```

- **Задача 2**
<br>хотим посчитать, сколько процентов составляет зарплата сотрудника от средней по Москве и средней по Самаре
    ```
      select
      id, name, salary,
      round(salary * 100 / avg(salary) over ()) as "perc",
      round(salary * 100 / avg(salary) filter(where city<>"Самара") over ()) as "msk",
      round(salary * 100 / avg(salary) filter(where city<>"Москва") over ()) as "sam"
      FROM employees
      ORDER BY id;
    ```
 
