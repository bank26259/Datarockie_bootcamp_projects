-- Restaurant Owners
-- 5 Tables
-- 1x Fact, 4x Dimension
-- search google, how to add foreign key
-- write SQL 3-5 queries analyze data
-- 1x subquery/ with

-- create 1 Dim customer
CREATE TABLE customer (
    customer_id INT unique primary key,
    firstname TEXT,
    lastname TEXT,
    sex TEXT,
    age INT
);

INSERT INTO customer VALUES
  (1, 'Jennifer', 'Lopez', 'F', 20),
  (2, 'Carly', 'Simon', 'F', 21),
  (3, 'Steely', 'Dan', 'M', 25),
  (4, 'Johnny', 'Mathis', 'M', 18),
  (5, 'Barry', 'Manilow', 'M', 22),
  (6, 'George', 'Michael', 'M', 15),
  (7, 'Tina', 'Turner', 'F', 19),
  (8, 'Paul', 'McCartney', 'F', 30),
  (9, 'Jay', 'Chick', 'F', 28),
  (10, 'Pensri', 'Suay', 'F', 20);

-- create 2 Dim menu
CREATE TABLE menu (
  menu_id INT unique primary key,
  menu_list TEXT,
  price INT,
  food_ty_id INT,
  FOREIGN KEY (food_ty_id) REFERENCES japanese_food_type(food_ty_id)
);

INSERT INTO menu VALUES
  (1, 'Salmon sushi', 50, 1),
  (2, 'Tuna sushi', 80, 1),
  (3, 'Octopus sushi', 50, 1),
  (4, 'Prawn sushi', 50, 1),
  (5, 'Scallops sushi', 100, 1),
  (6, 'Pork ramen', 350, 2),
  (7, 'Vegetarian ramen', 250, 2),
  (8, 'Seafood ramen', 400, 2),
  (9, 'Crumbled chicken curry', 280, 3),
  (10, 'Chicken curry', 350, 3),
  (11, 'Beef curry', 450, 3),
  (12, 'Chicken curry', 350, 3),
  (13, 'Water', 20, 4),
  (14, 'Green tea', 30, 4),
  (15, 'Beer', 120, 4);

-- create 3 Dim japanese_food_type
CREATE TABLE japanese_food_type (
  food_ty_id INT unique primary key,
  food_type TEXT
);

INSERT INTO japanese_food_type VALUES
  (1, 'sushi'),
  (2, 'ramen'),
  (3, 'curry'),
  (4, 'beverage');

-- create 4 Dim japanese_order_type
CREATE TABLE japanese_order_type (
  order_ty_id INT unique primary key,
  order_type TEXT
);

INSERT INTO japanese_order_type VALUES
  (1, 'for here'),
  (2, 'take away');
  
-- create 1 Fact table
CREATE TABLE japanese_order (
    order_id INT unique primary key,
    order_date DATE,
    customer_id INT,
    menu_id INT,
    order_ty_id INT,
    FOREIGN KEY (order_ty_id) REFERENCES japanese_order_type(order_ty_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (menu_id) REFERENCES menu(menu_id)
);

INSERT INTO japanese_order VALUES 
  (1, '2023-01-01', 1, 10, 1),
  (2, '2023-01-01', 1, 15, 1),
  (3, '2023-01-02', 3, 13, 1),
  (4, '2023-01-02', 5, 3, 2),
  (5, '2023-01-02', 4, 2, 2),
  (6, '2023-01-03', 4, 1, 1),
  (7, '2023-01-04', 10, 4, 1),
  (8, '2023-01-04', 2, 6, 1),
  (9, '2023-01-04', 6, 14, 1),
  (10, '2023-01-04', 6, 7, 2),
  (11, '2023-01-04', 7, 8, 1),
  (12, '2023-01-05', 8, 9, 1),
  (13, '2023-01-05', 1, 2, 1),
  (14, '2023-01-05', 2, 5, 1),
  (15, '2023-01-06', 9, 4, 2),
  (16, '2023-01-07', 9, 4, 2),
  (17, '2023-01-07', 10, 11, 1),
  (18, '2023-01-08', 7, 2, 1),
  (19, '2023-01-08', 3, 2, 1),
  (20, '2023-01-09', 5, 3, 2);

-- sqlite command
.mode markdown
.header on 
  
-- query 1 : What ordered?
SELECT 
  jo.order_id,
  m.menu_list,
  m.price
FROM japanese_order AS jo
JOIN menu AS m ON jo.menu_id = m.menu_id;

-- query 2 : What is the top 5 best selling menu?
SELECT 
  m.menu_list,
  COUNT(*) AS Amount
FROM japanese_order AS jo
JOIN menu AS m ON jo.menu_id = m.menu_id
GROUP BY m.menu_list
ORDER BY Amount DESC
LIMIT 5;

-- query 3 (subquery) : How many customers order take away?
SELECT 
  COUNT(*) AS n_take_away
FROM (
  SELECT *
  FROM japanese_order AS jo
  JOIN japanese_order_type AS jot ON jo.order_ty_id = jot.order_ty_id
  WHERE LOWER(jot.order_type) = 'take away'
) AS sub;

-- query 4 (with subquery) : Which female customers who have aged more than 25 years old choose to buy only sushi?
WITH food_type_sushi AS (
  SELECT
    m.menu_id,
    m.menu_list,
    m.price,
    jft.food_type
  FROM menu AS m
  JOIN japanese_food_type AS jft ON m.food_ty_id = jft.food_ty_id
  WHERE LOWER(jft.food_type) = 'sushi'
), customer_female AS (
  SELECT
    jo.menu_id,
    c.firstname || ' ' || c.lastname AS fullname,
    c.sex,
    c.age 
  FROM japanese_order AS jo
  JOIN customer AS c ON jo.customer_id = c.customer_id
  WHERE c.sex = 'F' AND c.age > 25
  GROUP BY fullname
)

SELECT 
  cf.fullname,
  cf.sex,
  cf.age,
  fts.menu_list,
  fts.price,
  fts.food_type
FROM customer_female AS cf
JOIN food_type_sushi AS fts ON cf.menu_id = fts.menu_id;
