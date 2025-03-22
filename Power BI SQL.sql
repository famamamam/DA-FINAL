-- Задание 2: Найти пользователей, купивших 2 любых корма для животных (кроме указанного) с 1 по 15 августа
SELECT DISTINCT o.user_id
FROM orders o
JOIN order_lines ol ON o.id = ol.order_id
JOIN products p ON ol.product_id = p.id
WHERE o.order_date BETWEEN '2024-08-01' AND '2024-08-15'
AND p.category = 'Корма для животных'
AND p.name NOT LIKE 'Корм Kitekat для кошек, с кроликом в соусе, 85 г'
GROUP BY o.user_id
HAVING COUNT(DISTINCT p.id) >= 2;

-- Задание 3: Найти топ-5 самых популярных товаров в СПб с 15 по 30 августа
SELECT p.name, COUNT(ol.product_id) AS order_count
FROM orders o
JOIN order_lines ol ON o.id = ol.order_id
JOIN products p ON ol.product_id = p.id
JOIN warehouses w ON o.warehouse_id = w.id
WHERE o.order_date BETWEEN '2024-08-15' AND '2024-08-30'
AND w.city = 'Санкт-Петербург'
GROUP BY p.name
ORDER BY order_count DESC
LIMIT 5;
