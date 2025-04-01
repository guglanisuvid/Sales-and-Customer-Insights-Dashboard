-- #################### CHANGE OVER TIME #################### 

-- sales performance over time
select
	year(order_date) as year,
	month(order_date) as month,
	sum(sales_amount) as total_revenue,
	count(distinct customer_key) as number_of_customers,
	sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date), month(order_date)
order by year(order_date), month(order_date);

-- ########################################


-- #################### CUMULATIVE ANALYSIS #################### 

-- running total sales and moving average price by year
select
	order_date,
	total_sales,
	sum(total_sales) over (order by order_date) as running_total,
	avg(average_price) over (order by order_date) as moving_average_price
from (
	select
		datetrunc(month, order_date) as order_date,
		sum(sales_amount) as total_sales,
		avg(price) as average_price
	from gold.fact_sales
	where order_date is not null
	group by datetrunc(month, order_date)
)t;

-- ########################################


-- #################### PERFORMANCE ANALYSIS ####################

-- yearly performance of products by comparing their sales to both the average sales performance of the product and the previos year's sales 
select 
	year(s.order_date) as year,
	p.product_name as product_name,
	sum(s.sales_amount) as yearly_sales,
	avg(sum(s.sales_amount)) over (partition by p.product_name) as average_sales,
	(sum(s.sales_amount) - avg(sum(s.sales_amount)) over (partition by p.product_name)) as average_difference,
	case
		when (sum(s.sales_amount) - avg(sum(s.sales_amount)) over (partition by p.product_name)) > 0 then 'Above Average'
		when (sum(s.sales_amount) - avg(sum(s.sales_amount)) over (partition by p.product_name)) < 0 then 'Below Average'
		else 'Average'
		end as average_change,
	lag(sum(s.sales_amount)) over (partition by p.product_name order by year(s.order_date), p.product_name) as previous_year_sales,
	(sum(s.sales_amount) - lag(sum(s.sales_amount)) over (partition by p.product_name order by year(s.order_date), p.product_name)) as previous_year_sales_difference,
	case
		when (sum(s.sales_amount) - lag(sum(s.sales_amount)) over (partition by p.product_name order by year(s.order_date), p.product_name)) > 0 then 'Increasing'
		when (sum(s.sales_amount) - lag(sum(s.sales_amount)) over (partition by p.product_name order by year(s.order_date), p.product_name)) < 0 then 'Decreasing'
		else 'No Change'
		end as previous_year_sales_change
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
where s.order_date is not null
group by year(s.order_date), p.product_name;

-- ########################################


-- #################### PART-TO-WHOLE ANALYSIS ####################

-- categories that contribute most to the overall sales
select
	*,
	sum(total_sales) over () as overall_sales,
	concat(round(((cast(total_sales as float) / sum(total_sales) over ()) * 100), 2), '%') as percent_of_sales
from (
select
	p.category,
	sum(s.sales_amount) as total_sales
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
group by p.category
)t
order by total_sales desc;

-- ########################################


-- #################### DATA SEGMENTATION ####################

-- segmenting products into cost ranges
select
	cost_range,
	count(product_key) as number_of_products
from (
	select
		product_key,
		product_name,
		cost,
		case
			when cost < 100 then 'Below 100'
			when cost between 100 and 500 then '100 - 500'
			when cost between 500 and 1000 then '500 - 1000'
			else 'Above 1000'
			end as cost_range
	from gold.dim_products
)t
group by cost_range
order by count(product_key) desc;

-- grouping customers based on their spending behaviour and calculating the number of customers in each group 
select
	customer_group,
	count(customer_key) as number_of_customers
from (
	select
		s.customer_key,
		c.first_name,
		c.last_name,
		datediff(month, min(s.order_date), max(s.order_date)) as lisfespan,
		sum(s.sales_amount) as total_spendings,
		case
			when sum(s.sales_amount) > 5000 and datediff(month, min(s.order_date), max(s.order_date)) >= 12
				then 'VIP'
			when sum(s.sales_amount) <= 5000 and datediff(month, min(s.order_date), max(s.order_date)) >= 12
				then 'Regular'
			else 'New'
			end as customer_group
	from gold.fact_sales as s
	left join gold.dim_customers as c
	on s.customer_key = c.customer_key
	group by s.customer_key, c.first_name, c.last_name
)t
group by customer_group
order by count(customer_key) desc;

-- ########################################