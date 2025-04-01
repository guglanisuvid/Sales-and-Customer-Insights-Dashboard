if OBJECT_ID('gold.report_customers', 'V') is not null
	drop view gold.report_customers
go
create view gold.report_customers as 
	select
		customer_key,
		customer_number,
		customer_name,
		age,
		case
			when age < 20
				then 'below 20'
			when age between 20 and 29
				then '20 - 29'
			when age between 20 and 29
				then '30 - 39'
			when age between 20 and 29
				then '40 - 49'
			else '50 and above'
			end as age_group,
		case
			when lifespan >= 12 and total_sales > 5000
				then 'VIP'
			when lifespan >= 12 and total_sales <= 5000
				then 'VIP'
			else 'New'
			end as customer_segment,
		last_order_date,
		datediff(month, last_order_date, getdate()) as recency,
		total_orders,
		total_sales,
		total_quantity,
		total_products,
		lifespan,
		case
			when total_orders = 0
				then 0
			else round((cast(total_sales as float) / total_orders), 2)
			end as average_order_value,
		case when lifespan = 0
				then total_sales
			else round((cast(total_sales as float) / lifespan), 2)
			end as average_monthly_spend
	from (
		select
			customer_key,
			customer_number,
			customer_name,
			birthdate,
			age,
			count(distinct order_number) as total_orders,
			sum(sales_amount) as total_sales,
			sum(quantity) as total_quantity,
			count(product_key) as total_products,
			max(order_date) as last_order_date,
			datediff(month, min(order_date), max(order_date)) as lifespan
		from (
			select
				s.order_number,
				s.product_key,
				s.order_date,
				s.sales_amount,
				s.quantity,
				s.price,
				s.customer_key,
				c.customer_number,
				concat(c.first_name, ' ', c.last_name) as customer_name,
				c.birthdate,
				datediff(year, c.birthdate, getdate()) as age
			from gold.fact_sales as s
			left join gold.dim_customers as c
			on s.customer_key = c.customer_key
		)t
		group by customer_key, customer_number, customer_name, birthdate, age
	)t;