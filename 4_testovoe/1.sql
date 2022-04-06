--------------------1.1-----------------
WITH t1 AS (
    SELECT deptno,
           count(empno)                                                                   as emp_count,
           count(CASE WHEN hiredate BETWEEN '2009-01-01' AND '2009-01-31' THEN empno END) as emp_count_jan,
           sum(sal)                                                                       as sum_salary
    FROM emp
    GROUP BY deptno),
     t2 AS (SELECT DISTINCT deptno,
                            sum(CASE WHEN hiredate BETWEEN '2009-01-01' AND '2009-01-31' THEN sal END) OVER w AS january_2009
            FROM emp window w as (
    partition by deptno
    rows between unbounded preceding and unbounded following
    )
ORDER BY deptno),
    t3 AS (
SELECT count (*) as cnt_emp_jan
FROM emp
WHERE hiredate BETWEEN '2009-01-01'
  AND '2009-01-31'
    )

SELECT t1.deptno                              AS "Номер подразделения",
       emp_count                              AS "Общее число сотрудников подразделения",
       emp_count_jan                          AS "Число сотрудников подразделения Январь 2009",
       sum_salary                             AS "Суммарный оклад всех сотрудников подразделения",
       round(100 * january_2009 / sum_salary) as "Процентная доля оклада 2009 от общего"


FROM t1
         LEFT JOIN t2 ON t1.deptno = t2.deptno
ORDER BY t1.deptno


-----------------------------Task 1.2-------------------------------

    WITH RECURSIVE
    r AS
        (
            SELECT emp.empno, emp.mgr, emp.job
            FROM emp
            WHERE empno = 7698
            UNION ALL
            SELECT e.empno, e.mgr, e.job
            FROM emp as e
                     JOIN r
                          ON e.mgr = r.empno
        ),
    t1 AS (
        SELECT deptno,
               count(empno)                                                                   as emp_count,
               count(CASE WHEN hiredate BETWEEN '2009-01-01' AND '2009-01-31' THEN empno END) as emp_count_jan,
               sum(sal)                                                                       as sum_salary
        FROM emp
        WHERE empno in (SELECT empno FROM r WHERE r.empno <> 7698)
        GROUP BY deptno),
    t2 AS (SELECT DISTINCT deptno,
                           sum(CASE WHEN hiredate BETWEEN '2009-01-01' AND '2009-01-31' THEN sal END) OVER w AS january_2009
           FROM emp window w as (
    partition by deptno
    rows between unbounded preceding and unbounded following
    )
ORDER BY deptno),
    t3 AS (
SELECT count (*) as cnt_emp_jan
FROM emp
WHERE hiredate BETWEEN '2009-01-01'
  AND '2009-01-31'
    )
SELECT t1.deptno                              AS "Номер подразделения",
       emp_count                              AS "Общее число сотрудников подразделения",
       emp_count_jan                          AS "Число сотрудников подразделения Январь 2009",
       sum_salary                             AS "Суммарный оклад всех сотрудников подразделения",
       round(100 * january_2009 / sum_salary) as "Процентная доля оклада 2009 от общего"
FROM t1
         LEFT JOIN t2 ON t1.deptno = t2.deptno;
ORDER BY t1.deptno



