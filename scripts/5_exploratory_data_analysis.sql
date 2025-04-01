-- #################### EXPLORING DATABASE ####################

-- exploring all objects in the database
select * 
from INFORMATION_SCHEMA.TABLES;

-- exploring all columns in a database
select * 
from INFORMATION_SCHEMA.COLUMNS;

-- exploring all columns in a table
select * 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'fact_sales';

-- ########################################


-- #################### EXPLORING DIMENSIONS ####################

-- finding all countries our customers come from
select distinct country 
from gold.dim_customers
order by country;

-- finding all product categories
select distinct category
from gold.dim_products
order by category;

-- finding all product sub-categories
select distinct subcategory
from gold.dim_products
order by subcategory;

-- ########################################


-- #################### EXPLORING DATES ####################

-- find the dates of the first and tha last order
select min(order_date) as first_order_date,
	max(order_date) as last_order_date
from gold.fact_sales;

-- number of months of sales available
select datediff(month, min(order_date), max(order_date)) as number_of_months
from gold.fact_sales;

-- finding the details of youngest and the oldest customer
select 
min (birthdate) as oldest_birthdate, 
datediff(year, min(birthdate), getdate()) as oldest_age, 
max(birthdate) as youngest_birthdate, 
datediff (year, max(birthdate), getdate()) as youngest_age 
from gold.dim_customers;

-- ########################################


-- #################### EXPLORING MEASURES ####################

-- total sales
select sum(sales_amount) as total_sales
from gold.fact_sales;

-- number of items sold
select sum(quantity) as total_quantity
from gold.fact_sales;

-- average selling price
select avg(price) as avg_price
from gold.fact_sales;

-- total number of orders
select count(distinct order_number) as number_of_orders
from gold.fact_sales;

-- total number of products
select count(*) as number_of_products
from gold.dim_products;

-- total number of customers
select count(*) as number_of_customers
from gold.dim_customers;

-- total number of customers that placed an order
select count(distinct customer_key) as number_of_customers
from gold.dim_customers;

-- report that shows all metrics
select 'total_sales' as measure_name, sum(sales_amount) as measure_value
from gold.fact_sales
union all
select 'total_quantity' as measure_name, sum(quantity) as measure_value
from gold.fact_sales
union all
select 'average_price' as measure_name, avg(price) as measure_value
from gold.fact_sales
union all
select 'number_of_orders' as measure_name, count(distinct order_number) as measure_value
from gold.fact_sales
union all
select 'number_of_products' as measure_name, count(*) as measure_value
from gold.dim_products
union all
select 'number_of_customers' as measure_name, count(*) as measure_value
from gold.dim_customers
union all
select 'number_of_customers_placed_order' as measure_name, count(distinct customer_key) as measure_value
from gold.dim_customers

-- ########################################


-- #################### EXPLORING MAGNITUDES ####################

-- total customers by countries
select country,
	count(customer_key) as number_of_customers
from gold.dim_customers
group by country
order by count(customer_key);

-- total customers by genders
select gender,
	count(customer_key) as number_of_customers
from gold.dim_customers
group by gender
order by count(customer_key);

-- total products by category
select category,
	count(product_number) as number_of_products
from gold.dim_products
group by category
order by count(product_number);

-- average cost in each category
select category,
	avg(cost) as average_cost
from gold.dim_products
group by category
order by avg(cost);

-- total revenue by category
select r2.category,
	sum(r1.sales_amount) as revenue
from gold.fact_sales as r1
left join gold.dim_products as r2
on r1.product_key = r2.product_key
group by r2.category
order by sum(r1.sales_amount);

-- total revenue by customer
select r2.customer_key,
	r2.first_name,
	r2.last_name,
	sum(r1.sales_amount) as revenue
from gold.fact_sales as r1
left join gold.dim_customers as r2
on r1.customer_key = r2.customer_key
group by r2.customer_key, r2.first_name, r2.last_name
order by sum(r1.sales_amount);

-- distribution of sold items across countries
select c2.country,
	sum(c1.quantity) as number_of_items
from gold.fact_sales as c1
left join gold.dim_customers as c2
on c1.customer_key = c2.customer_key
group by c2.country
order by sum(c1.quantity);

-- ########################################


-- #################### EXPLORING RANKINGS ####################

-- top 5 products in revenue
select top 5
	r1.product_key,
	r2.product_number,
	r2.product_name,
	r2.category,
	r2.subcategory,
	sum(sales_amount) as revenue
from gold.fact_sales as r1
left join gold.dim_products as r2
on r1.product_key = r2.product_key
group by r1.product_key, r2.product_number, r2.product_name, r2.category, r2.subcategory
order by sum(sales_amount) desc;

-- bottom 5 products in revenue
select top 5
	r1.product_key,
	r2.product_number,
	r2.product_name,
	r2.category,
	r2.subcategory,
	sum(sales_amount) as revenue
from gold.fact_sales as r1
left join gold.dim_products as r2
on r1.product_key = r2.product_key
group by r1.product_key, r2.product_number, r2.product_name, r2.category, r2.subcategory
order by sum(sales_amount) asc;

-- top 10 customers in revenue
select top 10
	c1.customer_key,
	c2.customer_number,
	c2.first_name,
	c2.last_name,
	c2.country,
	c2.gender,
	c2.birthdate,
	sum(c1.sales_amount) as revenue
from gold.fact_sales as c1
left join gold.dim_customers as c2
on c1.customer_key = c2.customer_key
group by c1.customer_key, c2.customer_number, c2.first_name, c2.last_name, c2.country, c2.gender,c2.birthdate
order by sum(c1.sales_amount) desc;

-- bottom 3 customers in revenue
select top 3
	c1.customer_key,
	c2.customer_number,
	c2.first_name,
	c2.last_name,
	c2.country,
	c2.gender,
	c2.birthdate,
	sum(c1.sales_amount) as revenue
from gold.fact_sales as c1
left join gold.dim_customers as c2
on c1.customer_key = c2.customer_key
group by c1.customer_key, c2.customer_number, c2.first_name, c2.last_name, c2.country, c2.gender,c2.birthdate
order by sum(c1.sales_amount) asc;

-- ########################################