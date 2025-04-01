-- creating tables inside silver schema
create or alter procedure silver.load_silver as
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
	begin try
		set @batch_start_time = getdate();

		print('====================')
		print('loading silver schema')
		print('====================')

		print('--------------------')
		print('loading crm tables')
		print('--------------------')

		print('>> creating table silver.crm_cust_info')
		set @start_time = GETDATE();
		if OBJECT_ID('silver.crm_cust_info', 'U') is not null
			drop table silver.crm_cust_info;
		create table silver.crm_cust_info(
		cst_id INT,
		cst_key NVARCHAR(50),
		cst_firstname NVARCHAR(50),
		cst_lastname NVARCHAR(50),
		cst_marital_status NVARCHAR(50),
		cst_gndr NVARCHAR(50),
		cst_create_date DATETIME,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

		print('>> creating table silver.crm_prd_info')
		if OBJECT_ID('silver.crm_prd_info', 'U') is not null
			drop table silver.crm_prd_info;
		CREATE TABLE silver.crm_prd_info(
		prd_id INT,
		cat_id NVARCHAR(50),
		prd_key NVARCHAR(50),
		prd_nm NVARCHAR(50),
		prd_cost INT,
		prd_line NVARCHAR(50),
		prd_start_dt DATE,
		prd_end_dt DATE,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

		print('>> creating table silver.crm_sales_details')
		if OBJECT_ID('silver.crm_sales_details', 'U') is not null
			drop table silver.crm_sales_details;
		CREATE TABLE silver.crm_sales_details(
		sls_ord_num NVARCHAR(50),
		sls_prd_key NVARCHAR(50),
		sls_cust_id INT,
		sls_order_dt DATE,
		sls_ship_dt DATE,
		sls_due_dt DATE,
		sls_sales INT,
		sls_quantity INT,
		sls_price INT,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

		print('>> creating table silver.erp_CUST_AZ12')
		if OBJECT_ID('silver.erp_CUST_AZ12', 'U') is not null
			drop table silver.erp_CUST_AZ12;
		CREATE TABLE silver.erp_CUST_AZ12(
		cid NVARCHAR(50),
		bdate DATE,
		gen NVARCHAR(50),
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

		print('>> creating table silver.erp_LOC_A101')
		if OBJECT_ID('silver.erp_LOC_A101', 'U') is not null
			drop table silver.erp_LOC_A101;
		CREATE TABLE silver.erp_LOC_A101(
		cid NVARCHAR(50),
		cntry NVARCHAR(50),
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

		print('>> creating table silver.erp_PX_CAT_G1V2')
		if OBJECT_ID('silver.erp_PX_CAT_G1V2', 'U') is not null
			drop table silver.erp_PX_CAT_G1V2;
		CREATE TABLE silver.erp_PX_CAT_G1V2(
		id NVARCHAR(50),
		cat NVARCHAR(50),
		subcat NVARCHAR(50),
		maintainence NVARCHAR(50),
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

		set @end_time = GETDATE();
		print '>> inserting data to tables duration: ' + cast(datediff(second, @start_time, @end_time) as varchar(10))

		-- adding data to tables in silver schema
		set @start_time = GETDATE();

		print('truncating table silver.crm_cust_info')
		truncate table silver.crm_cust_info;
		print('inserting data to silver.crm_cust_info')
		insert into silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select t.cst_id,
			t.cst_key,
			TRIM(t.cst_firstname) as cst_firstname,
			TRIM(t.cst_lastname) as cst_lastname,
			case when upper(trim(t.cst_marital_status)) = 'S' then 'Single'
				when upper(trim(t.cst_marital_status)) = 'M' then 'Married'
				else 'n/a'
				end as cst_marital_status,
			case when upper(trim(t.cst_gndr)) = 'M' then 'Male'
				when upper(trim(t.cst_gndr)) = 'F' then 'Female'
				else 'n/a'
				end as cst_gndr,
			t.cst_create_date
		from (
			select *,
				row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null
		) t
		where flag_last = 1;


		print('truncating table silver.crm_prd_info')
		truncate table silver.crm_prd_info;
		print('inserting data to silver.crm_prd_info')
		insert into silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select prd_id,
			replace(substring(trim(prd_key), 1, 5), '-', '_') as cat_id,
			substring(trim(prd_key), 7, len(prd_key)) as prd_key,
			prd_nm,
			isnull(prd_cost, 0) as prd_cost,
			case upper(trim(prd_line))
				when 'M' then 'Mountains'
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				else 'n/a'
				end as prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) - 1 as date) as prd_end_dt
		from bronze.crm_prd_info;


		print('truncating table silver.crm_sales_details')
		truncate table silver.crm_sales_details;
		print('inserting data to silver.crm_sales_details')
		insert into silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case
				when sls_order_dt = 0 or len(sls_order_dt) != 8 
				then null
				else cast(cast(sls_order_dt as varchar) as date)
				end as sls_order_dt,
			case
				when sls_ship_dt = 0 or len(sls_ship_dt) != 8 
				then null
				else cast(cast(sls_ship_dt as varchar) as date)
				end as sls_ship_dt,
			case
				when sls_due_dt = 0 or len(sls_due_dt) != 8 
				then null
				else cast(cast(sls_due_dt as varchar) as date)
				end as sls_due_dt,
			case
				when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) 
				then sls_quantity * abs(sls_price)
				else sls_sales
				end as sls_sales,
			sls_quantity,
			case
				when sls_price is null or sls_price <= 0 
				then sls_sales / nullif(sls_quantity, 0)
				else sls_price
				end as sls_price
		from bronze.crm_sales_details;
		

		print('truncating table silver.erp_CUST_AZ12')
		truncate table silver.erp_CUST_AZ12;
		print('inserting data to silver.erp_CUST_AZ12')
		insert into silver.erp_CUST_AZ12 (
			cid,
			bdate,
			gen
		)
		select
			case when cid like 'NAS%' 
				then substring(cid, 4, len(cid))
				else cid
				end as cid,
			case
				when bdate > getdate() then null
				else bdate
				end as bdate,
			case
				when upper(trim(gen)) in ('M', 'MALE')  then 'Male'
				when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
				else 'n/a'
				end as gen
		from bronze.erp_CUST_AZ12;


		print('truncating table silver.erp_LOC_A101')
		truncate table silver.erp_LOC_A101;
		print('inserting data to silver.erp_LOC_A101')
		insert into silver.erp_LOC_A101 (
			cid,
			cntry
		)
		select replace(cntry, '-', '') as cid,
			case
				when upper(trim(cid)) in ('DE', 'GERMANY') then 'Germany'
				when upper(trim(cid)) in ('USA', 'UNITED STATES', 'US') then 'United States of America'
				when upper(trim(cid)) = 'AUSTRALIA' then 'Australia'
				when upper(trim(cid)) = 'UNITED KINGDOM' then 'United Kingdom'
				when upper(trim(cid)) = 'CANADA' then 'Canada'
				when upper(trim(cid)) = 'FRANCE' then 'France'
				else 'n/a'
				end as cntry
		from bronze.erp_LOC_A101;
		

		print('truncating table silver.erp_PX_CAT_G1V2')
		truncate table silver.erp_PX_CAT_G1V2;
		print('inserting data to silver.erp_PX_CAT_G1V2')
		insert into silver.erp_PX_CAT_G1V2 (
			id,
			cat,
			subcat,
			maintainence
		)
		select id,
			cat,
			subcat,
			maintainence
		from bronze.erp_PX_CAT_G1V2;

		set @end_time = GETDATE();
		print '>> inserting data to tables duration: ' + cast(datediff(second, @start_time, @end_time) as varchar(10))
		set @batch_end_time = getdate();
		print '>> total time taken: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as varchar(10))
		end try
		begin catch	
			print Error_Message()
		end catch
end

exec silver.load_silver;