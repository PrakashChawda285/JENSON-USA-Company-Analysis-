SELECT 
    s.store_id, s.store_name, SUM(oi.quantity) AS total_products
FROM
    stores s
        JOIN
    orders o ON o.store_id = s.store_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
GROUP BY s.store_id , s.store_name;

select p.product_id,p.product_name,o.order_date,
       sum(oi.quantity) over(partition by p.product_id
       order by o.order_date) as cum_quantity
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id;

select product_id,product_name,category_id,category_name,total_sale
from
(select p.product_id,p.product_name,p.category_id,c.category_name,
      sum(oi.quantity*oi.list_price) as total_sale,
      rank() over (partition by p.category_id order by
      sum(oi.quantity*oi.list_price) desc ) rnk
from order_items oi
join products p on p.product_id = oi.product_id
join categories c on c.category_id = p.category_id
group by p.product_id,c.category_id) t
where rnk = 1;

SELECT 
    c.customer_id,
    CONCAT(first_name, ' ', last_name) name,
    SUM(oi.quantity * oi.list_price) AS total_spent
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

SELECT 
    p.product_id,
    p.product_name,
    c.category_id,
    c.category_name,
    p.list_price
FROM
    products p
        JOIN
    categories c ON p.category_id = c.category_id
WHERE
    p.list_price = (SELECT 
            MAX(list_price)
        FROM
            products
        WHERE
            category_id = p.category_id);
                       
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) full_name,
    s.store_id,
    s.store_name,
    COUNT(o.order_id) AS total_orders
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
        JOIN
    stores s ON o.store_id = s.store_id
GROUP BY c.customer_id , s.store_id;

SELECT 
    s.staff_id, CONCAT(first_name, ' ', last_name) name
FROM
    staffs s
        LEFT JOIN
    orders o ON s.staff_id = o.staff_id
WHERE
    o.order_id IS NULL;

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_quantity DESC
LIMIT 3;

select round(avg(list_price)) as median_price
from(select list_price,row_number() over(order by list_price) as sr_no,
        count(*) over()as count 
from products)t
where sr_no in (floor((count+1)/2), ceil((count+1)/2));

SELECT 
    p.product_id, p.product_name
FROM
    products p
WHERE
    NOT EXISTS( SELECT 
            p.product_id
        FROM
            order_items oi
        WHERE
            oi.product_id = p.product_id);
                   
SELECT 
    CONCAT(first_name, ' ', last_name) AS name,
    COUNT(o.order_id) AS total_sales
FROM
    staffs s
        JOIN
    orders o ON s.staff_id = o.staff_id
GROUP BY s.staff_id
HAVING (total_sales) > (SELECT 
        AVG(sales_count)
    FROM
        (SELECT 
            COUNT(order_id) AS sales_count
        FROM
            orders
        GROUP BY staff_id) avg_table);
                     
SELECT 
    c.customer_id, CONCAT(first_name, ' ', last_name) name
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
        JOIN
    products p ON p.product_id = oi.product_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT p.category_id) = (SELECT 
        COUNT(*)
    FROM
        categories);