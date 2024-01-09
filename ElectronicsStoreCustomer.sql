--Phase one
SELECT pc_code, model, speed, ram 
FROM PC
WHERE ram >= 16
ORDER BY ram ASC, speed DESC;
--Phase two
SELECT ROUND(AVG(price),2) AS average_price 
FROM Printer
Where color = 'C' AND type = 'Inkjet';
--Phase three
select p.maker, SUM(l.price) as total_price
from Laptop l join Product p ON l.model=p.model
group by p.maker
order by total_price asc
--Phase four
select 
    maker,
    sum(case when type = 'PC' then 1 else 0 end) as pc_count,
    sum(case when type = 'Laptop' then 1 else 0 end) as laptop_count
from Product
group by maker
having pc_count > 0 and laptop_count > 0
--Phase five
SELECT  
    l.model,
    p.maker,
    l.price,
    l.price - MAX(PC.price) AS price_difference_max_pc,
    l.price - AVG(PC.price) AS price_difference_avg_laptop
FROM Laptop l JOIN Product p ON p.model = l.model, PC
WHERE l.price > (SELECT MAX(PC.price) FROM PC)
GROUP BY l.model, l.price;
--Phase six
WITH RankedPCs AS (
    SELECT
        pc_code,
        model,
        speed,
        ram,
        hd,
        cd,
        price,
        ROW_NUMBER() OVER (PARTITION BY ram ORDER BY price DESC) AS rank_by_price
    FROM
        PC
)

SELECT
    pc_code,
    model,
    speed,
    ram,
    hd,
    cd,
    price
FROM
    RankedPCs
WHERE
    rank_by_price = 2;
