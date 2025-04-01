if OBJECT_ID('gold.dim_products', 'V') is not null
	drop view gold.dim_products
go
create view gold.dim_products as
select
	row_number() over (order by p1.prd_start_dt, p1.prd_key) as product_key,
	p1.prd_id as product_id,
	p1.prd_key as product_number,
	p1.prd_nm as product_name,
	p1.cat_id as category_id,
	p2.cat as category,
	p2.subcat as subcategory,
	p2.maintainence as maintainence,
	p1.prd_cost as cost,
	p1.prd_line as product_line,
	p1.prd_start_dt as	start_date
from silver.crm_prd_info as p1
left join silver.erp_PX_CAT_G1V2 as p2
on p1.cat_id = p2.id
where p1.prd_end_dt is null;
go


if OBJECT_ID('gold.dim_products', 'V') is not null
	drop view gold.dim_customers
go
create view gold.dim_customers as
select 
	row_number() over(order by ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	cl.cntry as country,
	ci.cst_marital_status as marital_status,
	case
		when ci.cst_gndr != 'n/a' then ci.cst_gndr
		when ci.cst_gndr = 'n/a' and (ca.gen != 'n/a' or ca.gen is not null) then ca.gen
		else 'n/a'
		end as gender,
	ca.bdate as birthdate,
	cast(ci.cst_create_date as date) as create_date
from silver.crm_cust_info as ci
left join silver.erp_CUST_AZ12 as ca
on ci.cst_key = ca.cid
left join silver.erp_LOC_A101 as cl
on ci.cst_key = cl.cid;
go


if OBJECT_ID('gold.fact_sales', 'V') is not null
	drop view gold.fact_sales
go
create view gold.fact_sales as
select 
	sls_ord_num as order_number,
	pr.product_key as product_key,
	cs.customer_key as customer_key,
	sls_order_dt as order_date,
	sls_ship_dt as ship_date,
	sls_due_dt as due_date,
	sls_sales as sales_amount,
	sls_quantity as quantity,
	sls_price as price
from silver.crm_sales_details as sd
left join gold.dim_products as pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers as cs
on sd.sls_cust_id = cs.customer_id;