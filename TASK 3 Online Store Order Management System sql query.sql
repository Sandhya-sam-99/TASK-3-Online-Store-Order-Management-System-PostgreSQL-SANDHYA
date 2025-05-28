-- Create tables
CREATE TABLE Customers (
    CUSTOMER_ID SERIAL PRIMARY KEY,
    NAME TEXT NOT NULL,
    EMAIL TEXT UNIQUE,
    PHONE TEXT,
    ADDRESS TEXT
);

CREATE TABLE Products (
    PRODUCT_ID SERIAL PRIMARY KEY,
    PRODUCT_NAME TEXT NOT NULL,
    CATEGORY TEXT NOT NULL,
    PRICE NUMERIC(10,2) NOT NULL,
    STOCK INTEGER NOT NULL
);

CREATE TABLE Orders (
    ORDER_ID SERIAL PRIMARY KEY,
    CUSTOMER_ID INTEGER REFERENCES Customers(CUSTOMER_ID),
    PRODUCT_ID INTEGER REFERENCES Products(PRODUCT_ID),
    QUANTITY INTEGER NOT NULL,
    ORDER_DATE DATE NOT NULL
);

---Inserting the data into tables---

INSERT INTO Customers (NAME, EMAIL, PHONE, ADDRESS) VALUES
('Emma Johnson', 'emma.j@example.com', '555-0101', '123 Main St, Boston, MA'),
('James Smith', 'james.s@example.com', '555-0102', '456 Oak Ave, New York, NY'),
('Olivia Brown', 'olivia.b@example.com', '555-0103', '789 Pine Rd, Chicago, IL'),
('Liam Davis', 'liam.d@example.com', '555-0104', '321 Elm St, San Francisco, CA'),
('Sophia Wilson', 'sophia.w@example.com', '555-0105', '654 Maple Dr, Austin, TX'),
('Noah Martinez', 'noah.m@example.com', '555-0106', '987 Cedar Ln, Seattle, WA'),
('Ava Anderson', 'ava.a@example.com', '555-0107', '135 Birch Blvd, Miami, FL'),
('William Taylor', 'william.t@example.com', '555-0108', '246 Walnut Ct, Denver, CO'),
('Isabella Thomas', 'isabella.t@example.com', '555-0109', '369 Spruce Way, Atlanta, GA'),
('Benjamin White', 'benjamin.w@example.com', '555-0110', '482 Oakwood Ave, Dallas, TX');

-- Insert date into products---

INSERT INTO Products (PRODUCT_NAME, CATEGORY, PRICE, STOCK) VALUES
('Wireless Earbuds', 'Electronics', 79.99, 50),
('Smartphone X', 'Electronics', 899.99, 25),
('Bluetooth Speaker', 'Electronics', 129.99, 30),
('Cotton T-Shirt', 'Clothing', 19.99, 100),
('Denim Jeans', 'Clothing', 49.99, 75),
('Running Shoes', 'Clothing', 89.99, 60),
('Coffee Maker', 'Home', 59.99, 40),
('Air Fryer', 'Home', 99.99, 35),
('Throw Pillow', 'Home', 24.99, 80),
('Fantasy Novel', 'Books', 14.99, 120),
('Cookbook', 'Books', 29.99, 90),
('Yoga Mat', 'Sports', 39.99, 65),
('Dumbbell Set', 'Sports', 79.99, 30),
('Vitamin C Supplements', 'Health', 12.99, 200),
('Protein Powder', 'Health', 34.99, 150);

-- Insert data into orders---

INSERT INTO Orders (CUSTOMER_ID, PRODUCT_ID, QUANTITY, ORDER_DATE) VALUES
(1, 3, 1, '2023-01-15'),
(2, 5, 2, '2023-01-20'),
(3, 7, 1, '2023-02-05'),
(4, 2, 1, '2023-02-10'),
(5, 10, 3, '2023-02-15'),
(1, 12, 1, '2023-03-01'),
(6, 8, 1, '2023-03-10'),
(7, 4, 5, '2023-03-15'),
(2, 1, 2, '2023-04-05'),
(8, 6, 1, '2023-04-10'),
(9, 9, 4, '2023-04-15'),
(10, 11, 2, '2023-05-01'),
(3, 13, 1, '2023-05-10'),
(4, 14, 3, '2023-05-15'),
(5, 15, 2, '2023-06-01'),
(1, 5, 1, '2023-06-10'),
(6, 7, 2, '2023-06-15'),
(7, 3, 1, '2023-07-01'),
(2, 2, 1, '2023-07-05'),
(8, 10, 2, '2023-07-10'),
(9, 12, 1, '2023-08-01'),
(10, 1, 3, '2023-08-05'),
(3, 4, 2, '2023-08-10'),
(4, 6, 1, '2023-09-01'),
(5, 8, 1, '2023-09-05'),
(1, 9, 2, '2023-09-10'),
(6, 11, 1, '2023-10-01'),
(7, 13, 1, '2023-10-05'),
(2, 14, 4, '2023-10-10'),
(8, 15, 2, '2023-10-15');

---Retrieve all orders placed by a specific customer (Emma Johnson)---
SELECT o.ORDER_ID, p.PRODUCT_NAME, o.QUANTITY, o.ORDER_DATE, (p.PRICE * o.QUANTITY) AS total_price
FROM Orders o
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
JOIN Customers c ON o.CUSTOMER_ID = c.CUSTOMER_ID
WHERE c.NAME = 'Emma Johnson'
ORDER BY o.ORDER_DATE DESC;

---Find products that are out of stock---
SELECT PRODUCT_ID, PRODUCT_NAME, CATEGORY, PRICE
FROM Products
WHERE STOCK = 0;

---Calculate the total revenue generated per product---
SELECT p.PRODUCT_ID, p.PRODUCT_NAME, p.CATEGORY, 
       COALESCE(SUM(o.QUANTITY * p.PRICE), 0) AS total_revenue
FROM Products p
LEFT JOIN Orders o ON p.PRODUCT_ID = o.PRODUCT_ID
GROUP BY p.PRODUCT_ID
ORDER BY total_revenue DESC;

---Retrieve the top 5 customers by total purchase amount--
SELECT c.CUSTOMER_ID, c.NAME, 
       SUM(o.QUANTITY * p.PRICE) AS total_purchase_amount
FROM Customers c
JOIN Orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
GROUP BY c.CUSTOMER_ID
ORDER BY total_purchase_amount DESC
LIMIT 5;

---Find customers who placed orders in at least two different product categories---
SELECT c.CUSTOMER_ID, c.NAME, COUNT(DISTINCT p.CATEGORY) AS distinct_categories
FROM Customers c
JOIN Orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
GROUP BY c.CUSTOMER_ID
HAVING COUNT(DISTINCT p.CATEGORY) >= 2;

---Analytics Queries--
---Find the month with the highest total sales---
SELECT DATE_TRUNC('month', ORDER_DATE) AS month,
       SUM(QUANTITY * p.PRICE) AS total_sales
FROM Orders o
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
WHERE EXTRACT(YEAR FROM ORDER_DATE) = 2023
GROUP BY month
ORDER BY total_sales DESC
LIMIT 1;

---Identify products with no orders in the last 6 months---
SELECT p.PRODUCT_ID, p.PRODUCT_NAME, p.CATEGORY
FROM Products p
WHERE p.PRODUCT_ID NOT IN (
    SELECT DISTINCT o.PRODUCT_ID
    FROM Orders o
    WHERE o.ORDER_DATE >= DATE '2023-10-31' - INTERVAL '6 months'
);

---Retrieve customers who have never placed an order---
SELECT c.CUSTOMER_ID, c.NAME, c.EMAIL
FROM Customers c
LEFT JOIN Orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
WHERE o.ORDER_ID IS NULL;

---Calculate the average order value across all orders---
SELECT ROUND(AVG(o.QUANTITY * p.PRICE), 2) AS average_order_value
FROM Orders o
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID;

