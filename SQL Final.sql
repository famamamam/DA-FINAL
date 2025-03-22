create database final;
use final;

update customer_info set Gender = NULL WHERE Gender = '';
update customer_info set Age = NULL WHERE Age = '';

ALTER TABLE customer_info Modify AGE INT NULL;
SELECT * FROM transactions_info;
SELECT * FROM customer_info;

CREATE TABLE transactions_info(
date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL(10,3),
Sum_payment DECIMAL(10,2)
);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions_info.csv"
INTO TABLE transactions_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#1
SELECT 
    c.Id_client,
    c.Gender,
    c.Age,
    COUNT(DISTINCT t.date_new) AS months_active,  -- количество месяцев активности клиента
    AVG(t.Sum_payment) AS avg_check,  -- средний чек за год
    AVG(t.Count_products) AS avg_month_spent,  -- средняя сумма покупок за месяц
    COUNT(t.Id_check) AS total_operations  -- количество операций за период
FROM
    customer_info c
JOIN
    transactions_info t ON c.Id_client = t.ID_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'  -- период за год
GROUP BY
    c.Id_client, c.Gender, c.Age  -- добавляем поле Age в GROUP BY
HAVING
    months_active = 12;  -- только клиенты, которые активны каждый месяц в течение года

#2
SELECT 
    MONTH(t.date_new) AS month,
    YEAR(t.date_new) AS year,
    AVG(t.Sum_payment) AS avg_check_month,  -- средняя сумма чека в месяц
    AVG(t.Count_products) AS avg_operations_month,  -- среднее количество операций в месяц
    COUNT(DISTINCT t.ID_client) AS active_clients_month,  -- количество клиентов, совершивших операции в месяц
    (COUNT(t.Id_check) / (SELECT COUNT(*) FROM transactions_info WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) * 100 AS operation_percentage,  -- доля операций в год
    (SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions_info WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) * 100 AS payment_percentage,  -- доля суммы в месяц
    ROUND(SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100, 2) AS male_payment_percentage,  -- доля расходов мужчин
    ROUND(SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100, 2) AS female_payment_percentage,  -- доля расходов женщин
    ROUND(SUM(CASE WHEN c.Gender NOT IN ('M', 'F') THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100, 2) AS na_payment_percentage  -- доля расходов без данных по полу
FROM
    transactions_info t
JOIN
    customer_info c ON t.ID_client = c.Id_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month, year;
    
#3
SELECT 
    CASE 
        WHEN c.Age IS NULL THEN 'Unknown'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+' 
    END AS age_group,
    SUM(t.Sum_payment) AS total_spent,  -- сумма операций за весь период
    COUNT(t.Id_check) AS total_operations,  -- количество операций за весь период
    AVG(CASE WHEN MONTH(t.date_new) BETWEEN 1 AND 3 THEN t.Sum_payment ELSE NULL END) AS avg_q1,  -- средняя сумма операций за 1 квартал
    AVG(CASE WHEN MONTH(t.date_new) BETWEEN 4 AND 6 THEN t.Sum_payment ELSE NULL END) AS avg_q2,  -- средняя сумма операций за 2 квартал
    AVG(CASE WHEN MONTH(t.date_new) BETWEEN 7 AND 9 THEN t.Sum_payment ELSE NULL END) AS avg_q3,  -- средняя сумма операций за 3 квартал
    AVG(CASE WHEN MONTH(t.date_new) BETWEEN 10 AND 12 THEN t.Sum_payment ELSE NULL END) AS avg_q4,  -- средняя сумма операций за 4 квартал
    ROUND(SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100, 2) AS male_payment_percentage,  -- доля расходов мужчин
    ROUND(SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100, 2) AS female_payment_percentage,  -- доля расходов женщин
    ROUND(SUM(CASE WHEN c.Gender NOT IN ('M', 'F') THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100, 2) AS na_payment_percentage  -- доля расходов без данных по полу
FROM
    transactions_info t
JOIN
    customer_info c ON t.ID_client = c.Id_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    age_group;



