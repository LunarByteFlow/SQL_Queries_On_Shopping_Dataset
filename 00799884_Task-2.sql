-- Question 1: 
Create Database OnlineShoppingDB;
USE OnlineShoppingDB;
ALTER TABLE Orders
DROP CONSTRAINT FK_Orders_Customers;

ALTER TABLE Order_items
DROP CONSTRAINT FK_OrderItems_Orders;

ALTER TABLE Order_items
DROP CONSTRAINT FK_OrderItems_Products;

ALTER TABLE Payments
DROP CONSTRAINT FK_Payments_Orders;

-- Orders table: Link customer_id to Customer table
ALTER TABLE Orders  
ADD CONSTRAINT FK_Orders_Customers  
FOREIGN KEY (customer_id)  
REFERENCES Customers(customer_id);

-- Order_items table: Link order_id to Orders table
ALTER TABLE Order_items  
ADD CONSTRAINT FK_OrderItems_Orders  
FOREIGN KEY (order_id)  
REFERENCES Orders(order_id);

-- Order_items table: Link product_id to Product table
ALTER TABLE Order_items  
ADD CONSTRAINT FK_OrderItems_Products  
FOREIGN KEY (product_id)  
REFERENCES Products(product_id);

-- Payments table: Link order_id to Orders table
ALTER TABLE Payments  
ADD CONSTRAINT FK_Payments_Orders  
FOREIGN KEY (order_id)  
REFERENCES Orders(order_id);



-- Question 2: Write a query that returns the names and countries of customers 
-- who made orders with
-- a total amount between £500 and £1000.
SELECT 
    c.name AS Customer_Name, -- Customer's name
    c.country AS Country   -- Customer's country
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id  -- Join Customers with Orders based on matching customer_id
JOIN Order_items oi ON o.order_id = oi.order_id  -- Join Orders with Order_items based on matching order_id
GROUP BY c.customer_id, c.name, c.country  -- Group by customer_id to ensure each customer is treated individually
HAVING SUM(oi.Total_amount) BETWEEN 500 AND 1000; -- Filter to only include customers whose total order amount is between 500 and 1000


-- Question 3: Get the total amount paid by customers belonging to UK 
-- who bought at least more than three products in an order.
SELECT SUM(order_total) AS TotalAmountPaid  -- Sum of all order totals from filtered orders
FROM (  -- Subquery to calculate the total for each order based on specific conditions
    SELECT o.order_id, -- Order ID for identifying each individual order
	SUM(oi.price_each * oi.quantity) AS order_total  -- Calculate the total amount for the order
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id  -- Join Customers with Orders based on customer_id
    JOIN Order_items oi ON o.order_id = oi.order_id   -- Join Orders with Order_items based on order_id to access product details
    WHERE c.country = 'UK'  -- Filter orders made by customers from the 'UK'
    GROUP BY o.order_id  -- Group the results by order_id to calculate total for each order
    HAVING COUNT(oi.product_id) > 3  -- Only include orders that contain more than 3 different products
) AS filtered_orders;  -- Alias for the subquery to calculate the total across filtered orders


-- Question 4: Write a query that returns the highest and second highest amount_paid from UK or
-- Australia – this is calculated after applying VAT as 12.2% multiplied by the amount_paid.
-- Some of the results are not integer values and your client has asked you to round the
-- result to the nearest integer value.
WITH DistinctAmounts AS (
    SELECT DISTINCT ROUND(p.Amount_paid * 1.122, 0) AS TotalAmountPaidAfterVAT
    FROM Orders o
    JOIN Customers c ON c.customer_id = o.customer_id
    JOIN Payments p ON o.order_id = p.order_id
    WHERE c.country IN ('UK', 'Australia')
)
SELECT TOP 2 TotalAmountPaidAfterVAT
FROM DistinctAmounts
ORDER BY TotalAmountPaidAfterVAT DESC;


-- Question 5: Write a query that returns a list of the distinct product_name and the total quantity
-- purchased for each product called as total_quantity. Sort by total_quantity.
SELECT p.product_name, SUM(o.quantity) AS total_quantity
FROM Products p
JOIN Order_items o ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC;


select * from Payments
select * from Customers
select * from Orders

-- Question 6: Write a stored procedure for the query given as: Update the amount_paid of customers
-- who purchased either laptop or smartphone as products and amount_paid>=£17000 of
-- all orders to the discount of 5%.
CREATE PROCEDURE UpdateCustomerDiscounts
AS
BEGIN
    -- Update the amount_paid for customers who purchased either a laptop or smartphone
    -- with an amount_paid >= £17000, applying a 5% discount

    UPDATE p
    SET p.amount_paid = p.amount_paid * 0.95  -- Apply a 5% discount
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products prod ON oi.product_id = prod.product_id
    WHERE prod.product_name IN ('laptop', 'smartphone')  -- Filter for laptops or smartphones
      AND p.amount_paid >= 17000;  -- Only update orders with amount_paid >= £17000
END;

-- command for excecuting the Stored Procedure. 
EXEC UpdateCustomerDiscounts;


--  Question 7
SELECT p.order_id, p.amount_paid
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products prod ON oi.product_id = prod.product_id
WHERE prod.product_name IN ('laptop', 'smartphone')  
  AND p.amount_paid >= 17000;


  -- Nested Query Using EXISTS
  SELECT o.order_id, o.order_date
FROM orders o
WHERE EXISTS (  -- Check if the order contains at least one 'laptop' product
    SELECT 1
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE p.product_name = 'laptop'   -- Filter for orders that include 'laptop' as the product
    AND oi.order_id = o.order_id   -- Ensure the order_item belongs to the current order
)
AND o.customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE country = 'UK'
);

-- Using JOIN to Combine Data from Multiple Tables
-- Which products are being ordered the most in each country
SELECT 
    c.country, 
    p.product_name, 
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.country, p.product_name
ORDER BY c.country, total_orders DESC;


--  Using System Functions: GETDATE() and DATEDIFF()
-- This query calculates the number of days since each order was placed.
SELECT o.order_id, DATEDIFF(DAY, o.order_date, GETDATE()) AS days_since_order
FROM orders o;

-- Using GROUP BY, HAVING, and ORDER BY
-- This query calculates the total quantity of each product ordered and 
-- lists the products that have been ordered more than 100 times, 
-- ordered by the total quantity in descending order.
SELECT p.product_name, SUM(oi.quantity) AS total_quantity
FROM order_items oi  -- Join order_items with products to get the product names
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name  -- Only include products where the total quantity sold is greater than 10
HAVING SUM(oi.quantity) > 10  -- Order the result by total quantity sold in descending order (most sold products first)
ORDER BY total_quantity DESC;
  
-- Using JOIN and GROUP BY with Aggregation
-- This query returns the average amount_paid for each product type 
-- ordered by customers from USA and Canada.

SELECT p.category, AVG(pay.amount_paid) AS avg_amount_paid
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id -- Join payments with orders on matching order_id
JOIN order_items oi ON o.order_id = oi.order_id -- Join orders with order_items to access product details
JOIN products p ON oi.product_id = p.product_id -- Join order_items with products to get product category
WHERE o.customer_id IN (  -- Filter only those customers who are from USA or Canada
    SELECT customer_id
    FROM customers
    WHERE country IN ('USA', 'Canada')
)  -- Group the results by product category to calculate average amount paid per category
GROUP BY p.category;  


-- Creating a backup for our current database.
BACKUP DATABASE AirportTicketingSystem TO DISK = 'C:\DatabaseBackup_Assignment\OnlineShoppingDB.bak';
