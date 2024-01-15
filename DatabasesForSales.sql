--Phase one
CREATE TABLE IF NOT EXISTS manufacturers (
    manufacturer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    country VARCHAR(45) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    model VARCHAR(45) NOT NULL,
    price DECIMAL NOT NULL,
    horsepower INT NOT NULL,
    fuel_efficiency INT NOT NULL,
    manufacturer_id INT NOT NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

CREATE TABLE IF NOT EXISTS inventory (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    quantity INT NOT NULL,
    reorder_level INT NOT NULL DEFAULT 2,
    last_inventory_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
--Phase two
CREATE TRIGGER update_inventory
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    DECLARE sold_quantity INT;
    SELECT NEW.quantity INTO sold_quantity;
    UPDATE inventory
    SET quantity = quantity - sold_quantity,
        last_inventory_date = NEW.sale_date
    WHERE product_id = NEW.product_id;
END;
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, quantity, total_price) 
VALUES
    (DATE('2023-05-01'), 1, 1, 1, 2, 56000.00),
    (DATE('2023-05-02'), 2, 2, 1, 1, 22000.00),
    (DATE('2023-05-02'), 1, 3, 2, 1, 41250.00),
    (DATE('2023-05-03'), 2, 4, 2, 2, 60000.00),
    (DATE('2023-05-03'), 1, 1, 2, 3, 84000.00);
SELECT * FROM inventory;
--Phase three
CREATE INDEX customer_sales_product
ON sales (customer_id, product_id);

CREATE VIEW sales_summary AS
SELECT
    p.model,
    SUM(s.quantity) AS total_sold
FROM
    sales s
    JOIN products p ON s.product_id = p.product_id
GROUP BY
    p.model;

SELECT * FROM sales_summary;
--Phase four
WITH percent_revenue 
AS (SELECT
        sale_id,
        DATE_FORMAT(sale_date, '%M %Y') AS month_year,
        total_price / 
            (SELECT SUM(total_price) 
             FROM sales
             WHERE DATE_FORMAT(sale_date, '%M %Y') = month_year) AS percent
    FROM sales)
SELECT
    CONCAT(first_name, ' ', last_name) AS employee_name,
    position,
    month_year,
    CASE
        WHEN SUM(percent) < 0.05 THEN 0
        WHEN SUM(percent) < 0.1 THEN 2000
        WHEN SUM(percent) < 0.2 THEN 5000
        WHEN SUM(percent) < 0.3 THEN 10000
        WHEN SUM(percent) < 0.4 THEN 15000
        ELSE 25000
    END AS employee_bonus    
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id AND e.position = 'Sales Associate'
JOIN percent_revenue pr ON s.sale_id = pr.sale_id
GROUP BY employee_name, e.position, month_year;
--Phase five
SELECT
    p.model,
    p.price,
    COALESCE(SUM(s.total_price), 0) AS total_sale_per_model,
    COALESCE(i.quantity, 0) AS inventory_per_model,
    CASE
        WHEN COALESCE(i.quantity, 0) = 0 THEN NULL
        ELSE ROUND(COALESCE(SUM(s.total_price), 0) / COALESCE(i.quantity, 1), 4)
    END AS sales_inventory_ratio
FROM
    products p
    LEFT JOIN sales s ON p.product_id = s.product_id
    LEFT JOIN inventory i ON p.product_id = i.product_id
GROUP BY
    p.model, p.price, i.quantity
ORDER BY
    sales_inventory_ratio DESC;
