-- Примеры запросов

--Простой запрос на выборку всех столбцов из таблицы customers
SELECT * FROM customers;

-- Запрос на выборку всех столбцов из таблицы products c 2 условиями
SELECT * FROM products
WHERE country IN ("RU", "USA") AND price BETWEEN 1000 AND 1500;

/* Запрос на выборку 3 столбцов из таблицы users c условием по возрасту, 
сортировкой по имени, фамилии и ограничением на вывод 5 строк */
SELECT last_name, first_name, birthday
FROM users
WHERE age >= 18
ORDER BY last_name, first_name
LIMIT 5;

-- Создание таблицы с автоинкрементным первичным ключом по id, типом данных ENUM и индексом по столбцу mark 
CREATE TABLE cars (
    id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    dealer_id ENUM("1", "2", "3") NOT NULL DEFAULT "1",
    mark VARCHAR(10) NOT NULL,
    model VARCHAR(20) NOT NULL,
    year YEAR NULL,
    INDEX marks_index(mark)
);

--Изменение имени столбца и добавление нового
ALTER TABLE users
CHANGE name first_name VARCHAR(20) NOT NULL DEFAULT " ",
ADD COLUMN last_name VARCHAR (20) NOT NULL DEFAULT " ";

--Изменение типа данных столбца и создание уникального составного индекса
ALTER TABLE passports
MODIFY series VARCHAR(4) NOT NULL,
MODIFY number VARCHAR(6) NOT NULL;
CREATE UNIQUE INDEX passport ON pasports(series, number);

-- Поиск по тексту с применением функции LIKE
SELECT domain  FROM domains
WHERE domain LIKE '%.ru'
ORDER BY date;

-- Полнотекстовый поиск с созданием индекса
CREATE FULLTEXT INDEX mango ON products(name);
-- 1 способ
SELECT id, name, price FROM products
WHERE (sizes LIKE '%36%' OR sizes LIKE '%38%') AND  
MATCH(name) AGAINST('+джинсы +Mango' IN BOOLEAN MODE) AND count > 0;

-- 2 способ
SELECT id, name, price FROM products
WHERE count > 3 AND 
(FIND_IN_SET('36', sizes) OR FIND_IN_SET('38', sizes)) AND
MATCH(name) AGAINST('+джинсы +Mango'IN BOOLEAN MODE)
ORDER BY price DESC;

-- Запрос на выборку со строковыми функциями CONCAT для объединения столбцов и CHAR_LENGTH для вычисления длины  
SELECT first_name, last_name, birthday, CONCAT(series, ' ', number) as passport FROM products
WHERE CHAR_LENGTH(name) BETWEEN 5 AND 7
ORDER BY last_name, first_name; 

-- Запрос на  обновление таблицы со строковой функцией SUBSTRING_INDEX() для вырезки части выражения  
UPDATE users SET first_name = SUBSTRING_INDEX(name, ' ', 1) AND
last_name = SUBSTRING_INDEX(name, ' ', -1);

-- Запрос на выборку с функциями даты YEAR, MONTH, DAY
SELECT *, YEAR(birthday) as year, MONTH(birthday) as month, DAY(birthday) as day 
FROM users
WHERE MONTH(birthday) = MONTH(NOW()) AND DAY(birthday) = DAY(NOW())
ORDER BY last_name, first_name;

-- Запрос на выборку с функцией даты DATE_FORMAT для приведения даты к нужному формату
SELECT first_name, last_name, DATE_FORMAT(birthday, '%d.%m.%Y') as user_birthday
FROM users
WHERE YEAR(birthday) = 1994
ORDER BY birthday;

-- Запрос на выборку с агрегирующими функциями SUM, COUNT и группировкой данных
SELECT YEAR(date) as year,
       MONTH(date) as month,
       SUM(amount) as income,
       COUNT(*) as orders
FROM orders 
WHERE status = 'success'
GROUP BY year, month
ORDER BY year, month;

SELECT user_id, 
       COUNT(*) as deals, 
       SUM(amount) as sum_amount, 
       MAX(amount) as max_amount
FROM deals
WHERE status = 'closed'
GROUP BY user_id
HAVING deals >= 3;

-- Многотабличные запросы. Объединение с помощью UNION
SELECT * FROM logs_2016 
WHERE browser = 'Chrome'
UNION
SELECT * FROM logs_2017
WHERE browser = 'Chrome';

SELECT LEFT(number, 6) as number, RIGHT(number, 2) as region, mark, model
FROM cars
UNION
SELECT number, '39' as region, mark, model 
FROM region39
UNION
SELECT LOWER(number) as number, region, mark, model
FROM avto
UNION
SELECT LEFT(number, 6) as number, RIGHT(number, 2) as region, SUBSTRING_INDEX(car, ' ', 1) as mark,
SUBSTRING_INDEX(cars, ' ', -1) as model
FROM autos;

SELECT type, sum_amount FROM (
    SELECT SUM(amount) as sum_amount, 'bank' as type FROM bank_transactions
UNION
    SELECT SUM(amount) as sum_amount, 'cash' FROM cashbox_transactions
UNION
    SELECT SUM(amount) as sum_amount, 'paypal' FROM paypal_transactions
) transactions
ORDER BY sum_amount;

-- Запрос на выборку с внутренним объединением (JOIN) таблиц
SELECT c.name, cs.name as country, c.population 
FROM  cities as c JOIN countries as cs ON c.country = cs.id
WHERE FIND_IN_SET('Europe', cs.region) AND c.population >= 1000000
ORDER BY c.population DESC;

--Запрос на выборку с LEFT JOIN 
SELECT r.name, COUNT(e.id) as employees 
FROM roles as r LEFT JOIN employees as e ON r.id = e.role_id
WHERE e.active = True OR e.role_id IS NULL 
GROUP BY r.id
ORDER BY employees DESC, r.name;

-- Запрос с FULL OUTER JOIN
SELECT cs.name as country, c.name as city 
FROM countries as cs RIGHT JOIN cities as c ON cs.id = c.country
UNION
SELECT cs.name as country, c.name as city 
FROM countries as cs LEFT JOIN cities as c ON cs.id = c.country
ORDER BY country, city;

-- Запрос на выборку из 3 таблиц
SELECT m.first_name as first_name, 
       m.last_name as last_name, 
       SEC_TO_TIME(AVG(c.duration_sec),0) as avg_duration
FROM calls as c JOIN clients as cl ON c.client_id = c.id 
     JOIN companies as cmp ON cl.company_id = cmp.id
     JOIN managers as m ON c.managers_id = m.id
WHERE cmp.id = 2
GROUP BY first_name, last_name
ORDER BY avg_duration DESC;

-- Простые вложенные запросы
SELECT id, name 
FROM categories 
WHERE id IN (SELECT category FROM products WHERE count > 0)
ORDER BY name;

SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders WHERE status = 'completed' 
      AND amount = (SELECT MAX(amount) FROM orders WHERE status = 'completed'))
ORDER BY id;

SELECT * FROM employees 
WHERE salary > ANY(SELECT salary FROM employees WHERE role_id = 3)
      AND role_id <> 3;

SELECT name, album_id FROM songs
WHERE EXISTS(SELECT * FROM albums JOIN songs ON albums.id = songs.album_id 
             WHERE year = 2008)
ORDER BY name;

-- Подзапросы в конструкции FROM и INSERT
SELECT * FROM (SELECT * FROM cars ORDER BY price DESC LIMIT 5) as best_cars
ORDER BY price;

INSERT IGNORE INTO paypal_payments (SELECT id, user_id, date, amount FROM payments WHERE source = 'paypal');

--Хранимые процедуры
DELIMITER $$
CREATE PROCEDURE move_money (from_account_id INT, to_account_id INT, amount DECIMAL)
BEGIN
UPDATE accounts SET balance = balance + amount WHERE id = to_account_id;
UPDATE accounts SET balance = balance - amount WHERE id = from_account_id;
END $$
DELIMITER;

CALL move_money (4, 2, 5000) -- вызываем хранимую процедуру

DELIMITER $$
CREATE PROCEDURE active_products ()
BEGIN
SELECT id, name, count, price FROM products
WHERE active = True AND count > 0 
ORDER BY price;
END $$
DELIMITER;

DELIMITER $$
CREATE PROCEDURE create_user (first_name VARCHAR(20), last_name VARCHAR(20), password VARCHAR(20))
BEGIN
INSERT INTO users (first_name, last_name, password)
VALUES (first_name, last_name, SHA(password)); -- функция для хэширования
END $$
DELIMITER;

-- Хранимые функции
DELIMITER $$
CREATE FUNCTION get_client_balance (client_id INT) RETURNS DECIMAL
BEGIN
     DECLARE client_balance DECIMAL DEFAULT 0;
     SELECT SUM(balance) INTO client_balance FROM accounts 
     WHERE user_id = client_id;
     RETURN client_balance;
END $$
DELIMITER;

-- Вызываем функцию
SELECT * FROM accounts 
WHERE balance > get_client_balance(2);

DELIMITER $$
CREATE FUNCTION full_name(first_name VARCHAR(20), last_name VARCHAR(20)) 
RETURNS VARCHAR(41)
BEGIN
     RETURN CONCAT(TRIM(first_name), ' ', TRIM(last_name));
END $$
DELIMITER;

-- Триггер после обновления в таблицe accounts
DELIMITER $$
CREATE TRIGGER calc_client_balance AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN 
     UPDATE users SET balance =  get_client_balance(old.user_id)
     WHERE id = NEW.user_id;
END $$
DELIMITER;

-- Триггер после вставки в таблицу accounts
DELIMITER $$
CREATE TRIGGER calc_client_balance AFTER INSERT ON accounts
FOR EACH ROW
BEGIN 
     UPDATE users SET balance =  get_client_balance(NEW.user_id)
     WHERE id = NEW.user_id;
END $$
DELIMITER;


-- Создание представления users_roles
CREATE VIEW users_roles as
SELECT u.first_name, u.last_name, r.name 
FROM users as u JOIN roles as r ON u.role_id = r.id

-- Запрос на выборку из представления users_roles
SELECT * FROM users_roles;

/* Создание оконной функции для вычисления итоговой суммы,
итоговой суммы по месяцам и вычисления процентного соотношения суммы по месяцам от общей суммы */
SELECT *, SUM(amount) OVER() as total,
      SUM(amount) OVER(PARTITION BY MONTH(date)) as month_date,
      amount * 100 / SUM(amount) OVER() as percent
FROM orders
WHERE YEAR(date) = 2021;

/* Запрос на выборку с оконной функцией для вычисления общей суммы численности населения
относительно каждой страны */
SELECT *, SUM(population) OVER(PARTITION BY country) as country_population
FROM cities
ORDER BY country_population, population;

/* Запрос на выборку с неагрегирующей функцией ROW_NUMBER(), предназначенной для уникализации
строк в результирующей таблице */
SELECT ROW_NUMBER() OVER() as row_num,
       ROW_NUMBER() OVER(PARTITION BY MONTH(date)) as row_num_month,
       id, date, amount,
       SUM(amount) OVER() as total,
       SUM(amount) OVER(PARTITION BY MONTH(date)) as month_total
FROM orders;

-- Запрос на выборку с неагрегирующей функцией ROW_NUMBER() и сортировкой внутри нее
SELECT ROW_NUMBER() OVER(PARTITION BY date) as row_num,
       ROW_NUMBER() OVER(PARTITION BY YEAR(date) ORDER BY date) as row_year_num,
       id, date, amount
FROM orders
ORDER BY date;

/* Запрос на выборку из таблицы фильмов с неагрегирующей функцией ROW_NUMBER() в сегменте жанров,
c сортировкой внутри нее по рейтингу в убывающем порядке*/
SELECT genre, ROW_NUMBER() OVER(PARTITION BY genre ORDER BY rating DESC) as genre_place,
       rating, name
FROM films
ORDER BY genre, genre_place;

/*Запрос на выборку оккупаемости инвестиций с неагрегирующей функцией ROW_NUMBER()
 и агрегирующей функцией SUM() c cортировкой*/
SELECT year, ROW_NUMBER() OVER(PARTITION BY year ORDER BY year, month) as month,
       income, outcome, SUM(income - outcome) OVER(ORDER BY year, month) as ror 
FROM revenues
ORDER BY year, month;











