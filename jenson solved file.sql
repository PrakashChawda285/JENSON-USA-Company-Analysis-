SELECT 
    s.store_id, s.store_name, SUM(oi.quantity) AS total_products
FROM
    stores s
        JOIN
    orders o USING (store_id)
        JOIN
    order_items oi USING (order_id)
GROUP BY s.store_id;


select p.product_id,p.product_name,o.order_date,sum(oi.quantity)
       over(partition by p.product_id order by o.order_date ) as cum_quantity 
from order_items oi
join orders o using (order_id)
join products p using (product_id);

with t as (select c.category_id,c.category_name,p.product_id,p.product_name,
       sum(oi.quantity*oi.list_price) as total_sales,
       rank() over(partition by c.category_id 
       order by sum(oi.quantity*oi.list_price)) as rnk
from order_items oi
join products p using (product_id)
join categories c using (category_id)
group by c.category_id,p.product_id)
select category_id,category_name,product_id,product_name,total_sales
from t 
where rnk = 1;


SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS name,
    SUM(oi.quantity * oi.list_price) AS total_spent
FROM
    customers c
        JOIN
    orders o USING (customer_id)
        JOIN
    order_items oi USING (order_id)
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

with t as (select c.category_id,c.category_name,p.product_id,p.product_name,p.list_price,
	rank() over(partition by c.category_id order by p.list_price desc) as rnk 
from products p
join categories c using (category_id))
select category_id,category_name,product_id,product_name,list_price
from t 
where rnk = 1;

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS cust_name,
    s.store_id,
    s.store_name,
    COUNT(o.order_id) AS total_orders
FROM
    orders o
        JOIN
    customers c USING (customer_id)
        JOIN
    stores s USING (store_id)
GROUP BY c.customer_id , s.store_id;

SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name
FROM
    staffs s
        LEFT JOIN
    orders o USING (staff_id)
WHERE
    o.order_id IS NULL;

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM
    order_items oi
        JOIN
    products p USING (product_id)
GROUP BY p.product_id
ORDER BY total_quantity_sold DESC
LIMIT 3;

with t as (select product_id,product_name,list_price,
       row_number() over (order by list_price) as sr_no,
       count(*) over() as count
from products)
select avg(list_price) as median_price
from t
where sr_no in ((count+1) div 2,(count+2) div 2);

SELECT 
    *
FROM
    products p
WHERE
    NOT EXISTS( SELECT 
            product_id
        FROM
            order_items oi
        WHERE
            oi.product_id = p.product_id);
                   
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staffs_name,
    COUNT(o.order_id) AS total_sales
FROM
    staffs s
        JOIN
    orders o USING (staff_id)
GROUP BY s.staff_id
HAVING total_sales > (SELECT 
        AVG(sales_count)
    FROM
        (SELECT 
            COUNT(order_id) AS sales_count
        FROM
            orders
        GROUP BY staff_id) avg_table);
                   
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) cust_name,
    COUNT(p.product_id) AS total_products
FROM
    customers c
        JOIN
    orders o USING (customer_id)
        JOIN
    order_items oi USING (order_id)
        JOIN
    products p USING (product_id)
GROUP BY c.customer_id
HAVING COUNT(DISTINCT p.category_id) = (SELECT 
        COUNT(*)
    FROM
        categories);

