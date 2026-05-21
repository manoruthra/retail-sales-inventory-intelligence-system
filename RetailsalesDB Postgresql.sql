select * from brands

select * from categories

select * from customers

select * from orders

select * from order_items

select * from products

select * from staffs

select * from stocks

select * from stores

-- Add Primary Keys
ALTER TABLE brands ADD PRIMARY KEY (brand_id);

ALTER TABLE categories ADD PRIMARY KEY (category_id);

ALTER TABLE customers ADD PRIMARY KEY (customer_id);

ALTER TABLE orders ADD PRIMARY KEY (order_id);

ALTER TABLE products ADD PRIMARY KEY (product_id);

ALTER TABLE stores ADD PRIMARY KEY (store_id);

ALTER TABLE staffs ADD PRIMARY KEY (staff_id);

-- Add Foregin key constraint
ALTER TABLE orders ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE orders ADD CONSTRAINT fk_store
FOREIGN KEY (store_id)
REFERENCES stores(store_id);

ALTER TABLE orders ADD CONSTRAINT fk_staff
FOREIGN KEY (staff_id)
REFERENCES staffs(staff_id);

ALTER TABLE order_items ADD CONSTRAINT fk_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE products ADD CONSTRAINT fk_brand
FOREIGN KEY (brand_id)
REFERENCES brands(brand_id);

ALTER TABLE products ADD CONSTRAINT fk_category
FOREIGN KEY (category_id)
REFERENCES categories(category_id);

ALTER TABLE stocks ADD CONSTRAINT fk_stock_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE stocks ADD CONSTRAINT fk_stock_store
FOREIGN KEY (store_id)
REFERENCES stores(store_id);

-- perform integrity check
-- orders without customers
SELECT *
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- storewise Analysis

SELECT s.store_name,SUM(oi.total_sales) as total_sales
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN stores s
ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_sales DESC;

--Region-wise Sales Analysis
SELECT s.state, SUM(oi.total_sales) AS total_revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN stores s
ON o.store_id = s.store_id
GROUP BY s.state
ORDER BY total_revenue DESC;

--Product-wise Sales Trends

SELECT p.product_name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;

--Inventory Trends
SELECT s.store_name, p.product_name,st.quantity
FROM stocks st
JOIN stores s
ON st.store_id = s.store_id
JOIN products p
ON st.product_id = p.product_id
ORDER BY st.quantity ASC;

--Staff Performance Report
SELECT sf.first_name,sf.last_name,SUM(oi.total_sales) AS total_sales
FROM staffs sf
JOIN orders o
ON sf.staff_id = o.staff_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY sf.staff_id, sf.first_name, sf.last_name
ORDER BY total_sales DESC;

--Customer Orders & Frequency

SELECT c.first_name, c.last_name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC;

--Revenue & Discount Analysis

SELECT
    SUM(quantity * list_price) AS gross_sales,
    SUM(quantity * list_price * discount) AS total_discount,
    SUM(quantity * list_price * (1 - discount)) AS net_revenue
FROM order_items;

--Delayed Shipment Analysis
SELECT order_id,
       required_date,
       shipped_date,
       CASE
           WHEN shipped_date > required_date THEN 'Delayed'
           ELSE 'On Time'
       END AS delivery_status
FROM orders
WHERE shipped_date IS NOT NULL;

--Create SQL Views
--Sales and Summary view
CREATE VIEW sales_summary AS
SELECT s.store_name,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN stores s
ON o.store_id = s.store_id
GROUP BY s.store_name;

select * from sales_summary;

--Customers orders view
CREATE VIEW customer_order_summary AS
SELECT c.customer_id,
       c.first_name,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name;

select * from customer_order_summary;


