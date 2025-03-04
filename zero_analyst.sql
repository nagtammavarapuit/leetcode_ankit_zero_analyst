use zero_analyst;

# 01 Write the SQL query to find the second highest salary   
SELECT * FROM employees01 
with cte as 
(select 
	*,
	dense_rank() over(partition by department order by salary desc) as drnk
from employees01
)
select employee_id,name,department,salary from cte where drnk=1;


# 02 write an SQL query to calculate the total  numbers of returned orders for each month 
select * from orders02; select * from returns02;
select 
	month(orderdate),
	count(*)
from returns02 r
join orders02 o
on r.orderid=o.orderid
group by 1;


# 03 Write SQL query to find the top-selling products in each category   
SELECT * FROm products03;

select product_name,category from 
(select 
	*,
	dense_rank() over(partition by category order by quantity_sold desc) as drnk
from products03) as tab
where drnk=1;

# 04 Find the top 2 products in the top 2 categories based on spend amount? 
SELECT * FROM orders04;

with cte_cat as 
(select category,cat_spend 
from 
(select 
	category,
	sum(spend) as cat_spend,
	dense_rank() over(order by sum(spend) desc) as cat_drnk
from orders04
group by 
	category
			) as tab1 where cat_drnk <=2)
select category,product,pro_spend
from 
(select 
	o.category,
	o.product,
	sum(o.spend) as pro_spend,
	dense_rank() over(partition by o.category order by sum(o.spend) desc) as pro_drnk
from orders04 o 
join cte_cat c
on o.category=c.category
group by 
	o.category,o.product) as t2
where pro_drnk <=2
	
# 06 -- who has not done purchase in last month (orders)  
SELECT * FROM customers06;SELECT * FROM orders06;
select * from customers06 
where customer_id not in (select customer_id from orders06 
						  where year(current_date())=year(order_date) 
						  and month(order_date) = month(current_date())-1)

# 07   How would you identify duplicate entries in a SQL in given table employees columns are  emp_id, name, department, salary
# 08   Write a SQL query to find all products that have not been sold in the last six months. 
	  -- Return the product_id, product_name, category,  and price of these products. 
products08-->product_id,product_name,category,price
sales08-->sale_id,product_id,sale_date,quantity						  
SELECT * FROM products08;SELECT * FROM sales08;
select 
	p.*,
	s.sale_date
from products08 p 
join sales08 s
on p.product_id=s.product_id
where sale_date is null or 
sale_date <(current_date - interval 6 month);

SELECT p.product_id, p.product_name, p.category, p.price
FROM products08 p
LEFT JOIN sales08 s
ON p.product_id = s.product_id
AND s.sale_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
WHERE s.sale_id IS NULL;


products08-->product_id,product_name,category,price
sales08-->sale_id,product_id,sale_date,quantity
# 09  write a SQL query to find customers who  bought Airpods after purchasing an iPhone. 
SELECT * FROM customers09; SELECT * FROM purchases09;
select c.* 
from customers09 c
join purchases09 p1
on p1.customerid=c.customerid
join purchases09 p2
on p2.customerid=c.customerid 
where p1.ProductName='iPhone'
and p2.ProductName='Airpods'
and p1.PurchaseDate<p2.PurchaseDate;


# 10 Write a SQL query to classify employees into three categories based on their salary:
select * from employees10;
select 
	*,
	case 
			when salary >=75000 then 'A1'
			when salary between 50000 and 75000 then 'A2'
			else 'A3'
	end as grading
from employees10;	

select current_date,date_sub(current_date,interval 6 month);
select da
  
						  
# 11 Identify returning customers based on their order history. Categorize customers as Returning if they have placed more than one return, 
    --  and as New otherwise. 
SELECT * FROM orders11;SELECT * FROM returns11;
select customer_id,
	case when count(customer_id)> 1 then 'returning'
	else 'new'
	end as customer_type
from returns11 r inner join orders11 o 
on r.order_id=o.order_id 
group by 1;
# 12 Write a solution to show the unique ID of each user,  If a user does not have a unique ID replace just show null.Return employee name and their unique_id.

# 13 write a SQL query to retrieve all employees  details along with their managers names based on the manager ID 
SELECT * FROM employees13;
select  *,m.name as manager_name
	from employees13 e join employees13 m
	on e.manager_id=m.emp_id;
# 14 Find the top 2 customers who have spent the most money across all their orders. 
SELECT * FROM customers14;SELECT * FROM orders14;


# 15 Write an SQL query to retrieve the product details for items whose revenue decreased compared to the previous month. 
SELECT * FROM orders15;

with current_month_revenue as 
(
select 
	product_id,
	sum(quantity) as current_total_quantity,
	sum(quantity * price) as current_month_revenue
from orders15
where year(order_date)=year(current_date) 
and   month(order_date)=month(current_date)
group by product_id
),
previos_month_revenue
as 
(
select 
	product_id,
	sum(quantity) as previous_total_quantity,
	sum(quantity * price) as previous_month_revenue
from orders15
where year(order_date)=year(current_date) 
and   month(order_date)=month(current_date)-1
group by product_id
)
select 
	c.product_id,
	current_total_quantity,
	current_month_revenue,
	previous_total_quantity,
	previous_month_revenue
from 	
	current_month_revenue c
join
	previos_month_revenue p
	on c.product_id=p.product_id
where 	current_month_revenue > previous_month_revenue
	
# 16 Write a SQL query to find the names of managers who have at least five direct reports.Return the result table in any order. 
SELECT * FROM employees16;

select 
	e.managerid,m.name,count(e.id)
from employees16 e
join employees16 m
on e.managerid=m.id
group by e.managerid,m.name
having count(e.id) >=5

# 17 Write an SQL query to find customers who have made purchases in all product categories.  
SELECT * FROM customers17;SELECT * FROM purchases17;
select distinct product_category from purchases17;
select c.customer_id,c.customer_name
from customers17 c
join purchases17 p
on c.customer_id=p.customer_id
group by c.customer_id,c.customer_name
having count(distinct product_category)=(select count(distinct product_category) from purchases17);
	
# 18 Write a SQL query to find out each hotal best performing months based on revenue   
SELECT * FROM hotel_bookings18;
select 
	hotel_name,
	concat(year(booking_date),'-',month(booking_date)),
	sum(total_price)
from hotel_bookings18
group by 
	hotel_name,
	concat(year(booking_date),'-',month(booking_date))
order by sum(total_price) desc;	

# 19 Find the details of employees whose salary is greater than the average salary across the entire company.  

SELECT * FROM employees19;

select 
	employee_id,
	employee_name,
	department,
	salary 
from employees19
	where salary > (select avg(salary) from employees19);
# 20 Write a query to find products that are sold by both Supplier A and Supplier B, excluding products sold by only one supplier. 

select * from products20
select
	product_id,
	product_name,
	count(supplier_name)
from products20
where supplier_name in ('Supplier A','Supplier B')
group by 
	product_id,product_name
having count(distinct supplier_name)=2;	














