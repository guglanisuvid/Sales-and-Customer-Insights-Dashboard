if OBJECT_ID('gold.report_products', 'V') is not null
	drop view gold.report_products
go
create view gold.report_products as 
	select
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		last_sale_date,
		datediff(month, last_sale_date, getdate()) as recency,
		case
			when total_sales > 50000
				then 'High Performer'
			when total_sales >= 10000
				then 'Mid Performer'
			else 'Low Performer'
			end as product_segment,
		total_orders,
		total_sales,
		total_quantity,
		total_customers,
		avg_selling_price,
		case
			when total_orders = 0
				then 0
			else round((cast(total_sales as float) / total_orders), 2)
			end as average_order_revenue,
		case when lifespan = 0
				then total_sales
			else round((cast(total_sales as float) / lifespan), 2)
			end as average_monthly_revenue
	from (
		select
			product_key,
			product_name,
			category,
			subcategory,
			cost,
			datediff(month, min(order_date), max(order_date)) as lifespan,
			max(order_date) as last_sale_date,
			count(distinct order_number) as total_orders,
			count(distinct customer_key) as total_customers,
			sum(sales_amount) as total_sales,
			sum(quantity) as total_quantity,
			round(avg(cast(sales_amount as float) / nullif(quantity, 0)), 1) as avg_selling_price
		from (
			select
				s.order_number,
				s.product_key,
				s.customer_key,
				s.order_date,
				s.sales_amount,
				s.quantity,
				s.price,
				p.product_id,
				p.product_number,
				p.product_name,
				p.category_id,
				p.category,
				p.subcategory,
				p.maintainence,
				p.cost,
				p.product_line,
				p.start_date
			from gold.fact_sales as s
			left join gold.dim_products as p
			on s.product_key = p.product_key
		)t
		group by product_key, product_name, category, subcategory, cost
	)t;