## Testovoe 1

- **Задача 1**
Вывести на экран товары из справочника товаров, удовлетворяющие следующим условиям: название товара содержит "сок" и объем единицы товара больше 0.5 литра.
Помимо названия товара нужно вывести объем.
    ```
    select "ART_NAME" as "Название товара",
       "ART_VOL"  as "Объем 1ой единицы товара"
    from "T_ART"
    WHERE "ART_NAME" like '%сок%'
      and "ART_VOL" > 0.5
    ```

- **Задача 2**
Вывести на экран список товаров из справочника товаров, удовлетворяющих следующим условиям: наименование товарной подгруппы – "Йогурты в бутылке" и 8
единиц товара, в случае если нам нужно будет объединить их в одну упаковку, будут иметь общий объем не более 1.5 литра. Необходимо также посчитать объем
получившейся упаковки из 8и шт.
    ```
    SELECT "ART_NAME" as "Название товара", SUM("ART_VOL") AS "Объем 1ой единицы товара"
    FROM "T_ART"
    WHERE "ART_GR_1" = 'Йогурты в бутылке'
    GROUP BY "ART_NAME"
    HAVING SUM("ART_VOL") <= 1.5
       AND COUNT("ART_VOL") <= 8;
    ```
- **Задача 3**
Вывести на экран кол-во товаров из справочника товаров, удовлетворяющих следующим условиям: вес единицы товара кратен 1 кг и находится в диапазоне от 1 до 3х кг
и объем единицы товара находитится в диапазоне от 3х до 5и литров. Данная информация нужна в разрезе товарной группы.
    ```
    SELECT "ART_GR_0" as "Товарная группа", COUNT(*) as "Кол-во товаров"
    FROM "T_ART"
    WHERE (CAST("ART_WEIGTH" * 100 AS INT) % 100 = 0)
      AND ("ART_WEIGTH" BETWEEN 1 AND 3)
      AND ("ART_VOL" BETWEEN 3 AND 5)
    GROUP BY "ART_GR_0"
    ```    
- **Задача 4**
В задаче №1 вы получили список соков, теперь необходимо вывести на экран суммарные продажи в рублях этих соков за весь 2021 г. в разрезе названий товаров.
Отсортируйте результат по убыванию суммарных продаж, выведите дополнительно группу и подгруппу товаров.
    ```
    WITH juice AS (
    SELECT "ART_ID", "ART_NAME", "ART_VOL", "ART_GR_0", "ART_GR_1"
    from "T_ART"
    WHERE "ART_NAME" like '%сок%'
      AND "ART_VOL" > 0.5)

    SELECT MAX("ART_GR_0") as "Товарная группа",
           MAX("ART_GR_1") as "Товарная подгруппа",
           "ART_NAME"      as "Название товара",
           SUM("SALE_RUB") as "Продажи за весь
    2021г., руб"
    FROM juice
             LEFT JOIN "T_SALES" as TS on juice."ART_ID" = TS."ART_ID"
    WHERE EXTRACT(YEAR FROM "DAY_ID") = 2021
    GROUP BY "ART_NAME"
    ORDER BY SUM("SALE_RUB") DESC
    ```
- **Задача 5**
В задаче №2 вы определяли, какие йогурты можно объединить в упаковки по 8 шт. таким образом чтобы объем получившейся упаковки не превышал 1.5 литра. В
табличке "Продажи" есть статистика по продажам товаров в штуках. Посчитайте сколько упаковок Йогуртов по 8 шт. с общим объемом до 1.5 литра нужно было сделать
чтобы продавать йогурты не поштучно, а блокам, сохранив при этом итоговый объем продаж 2021г. Так же нужно понимать что упаковка требует дополнительных
расходов, каждый литр итоговой упаковки стоит 15 рублей, затраты на упаковку тоже нужно посчитать.
    ```
    WITH task2 AS (
    select "ART_ID",
           "ART_NAME",
           SUM("ART_VOL") as "Объем итоговой
    упаковки из 8и шт, л"
    from "T_ART"
    WHERE "ART_GR_1" = 'Йогурты в бутылке'
    GROUP BY "ART_ID", "ART_NAME"
    HAVING SUM("ART_VOL") <= 1.5
       AND COUNT("ART_VOL") <= 8),

     pack AS (
         SELECT "ART_ID",
                count(*)        as overall_count,
                count(*) / 8    as "division",
                count(*) % 8    as "residue",
                SUM("SALE_RUB") as summa_pack
         FROM "T_SALES"
         WHERE "ART_ID" in (
             SELECT "ART_ID"
             FROM task2
         )
           and extract(year from "DAY_ID") = 2022
         GROUP BY "ART_ID")

    SELECT "ART_NAME"                 as "Наименование товара",
           division                   as "Сколько упаковок нужно было сделать,шт",
           summa_pack + division * 15 as "Итоговая стоимость"
    FROM pack
             LEFT JOIN "T_ART" ON pack."ART_ID" = "T_ART"."ART_ID"
    ```
    
- **Задача 6**
В задаче №3 вы получили список Групп с кол-вом товаров удовлетворяющих ряду условий. Получите топ 5(по кол-ву товаров из задачи №3) Групп. Для полученных 5и
групп выведите остатки в рублях на 30 июня 2020 г., остатки в рублях за 30 июня 2021 г., суммарные продажи за весь 2021 г.
Отсортируйте результат по возрастанию по кол-ву товаров из задачи №3

    ```
    WITH task3 AS (
    SELECT "ART_GR_0", COUNT(*) as "quant_good"
    FROM "T_ART"
    WHERE (CAST("ART_WEIGTH" * 100 AS INT) % 100 <> 0)
      AND ("ART_WEIGTH" BETWEEN 0 AND 3)
      AND ("ART_VOL" BETWEEN 0 AND 5)
    GROUP BY "ART_GR_0"
    ORDER BY quant_good DESC
    LIMIT 5),

     art_filter_task3 AS (
         SELECT "ART_ID", "ART_GR_0"
         FROM "T_ART"
         WHERE "ART_GR_0" in (SELECT "ART_GR_0" FROM task3)),

     june_2020 AS (
         SELECT "ART_GR_0", SUM("REST_RUB") AS june_2020
         FROM art_filter_task3
                  RIGHT JOIN "T_REST" TR on art_filter_task3."ART_ID" = TR."ART_ID"
         WHERE "DAY_ID" <= '2021-06-30'
         GROUP BY art_filter_task3."ART_GR_0"),
     june_2021 AS (
         SELECT "ART_GR_0", SUM("REST_RUB") AS june_2021
         FROM art_filter_task3
                  RIGHT JOIN "T_REST" TR on art_filter_task3."ART_ID" = TR."ART_ID"
         WHERE "DAY_ID" <= '2022-06-30'
         GROUP BY art_filter_task3."ART_GR_0"),
     year_2021 AS (
         SELECT "ART_GR_0", SUM("REST_RUB") AS year_2021
         FROM art_filter_task3
                  RIGHT JOIN "T_REST" TR on art_filter_task3."ART_ID" = TR."ART_ID"
         WHERE "DAY_ID" BETWEEN '2022-01-01' AND '2022-12-31'
         GROUP BY art_filter_task3."ART_GR_0")
    SELECT june_2021."ART_GR_0" "Товарная группа",
           quant_good "Кол-во товаров из задачи №3",
           june_2020 "Остатки по всей группе на 30 июня 2020 г, руб",
           june_2021 "Остатки по всей группе на 30 июня 2021 г, руб",
           year_2021"Продажи по всей группе за весь 2021г,руб"

    FROM june_2021
             INNER JOIN june_2020 on june_2020."ART_GR_0" = june_2021."ART_GR_0"
             INNER JOIN year_2021 on june_2021."ART_GR_0" = year_2021."ART_GR_0"
             INNER JOIN task3 on june_2021."ART_GR_0" = task3."ART_GR_0"
    ORDER BY quant_good ASC
    ```

    
    
