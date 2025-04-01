use data_warehouse;
go

-- creating tables inside bronze schema
create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
	begin try
		set @batch_start_time = getdate();
		print('====================')
		print('loading bronze schema')
		print('====================')

		print('--------------------')
		print('loading crm tables')
		print('--------------------')

		print('>> creating table bronze.crm_cust_info')
		set @start_time = GETDATE();
		if OBJECT_ID('bronze.crm_cust_info', 'U') is not null
			drop table bronze.crm_cust_info;
		create table bronze.crm_cust_info(
		cst_id INT,
		cst_key NVARCHAR(50),
		cst_firstname NVARCHAR(50),
		cst_lastname NVARCHAR(50),
		cst_marital_status NVARCHAR(50),
		cst_gndr NVARCHAR(50),
		cst_create_date DATETIME
		);

		print('>> creating table bronze.crm_prd_info')
		if OBJECT_ID('bronze.crm_prd_info', 'U') is not null
			drop table bronze.crm_prd_info;
		CREATE TABLE bronze.crm_prd_info(
		prd_id INT,
		prd_key NVARCHAR(50),
		prd_nm NVARCHAR(50),
		prd_cost INT,
		prd_line NVARCHAR(50),
		prd_start_dt DATETIME,
		prd_end_dt DATETIME
		);

		print('>> creating table bronze.crm_sales_details')
		if OBJECT_ID('bronze.crm_sales_details', 'U') is not null
			drop table bronze.crm_sales_details;
		CREATE TABLE bronze.crm_sales_details(
		sls_ord_num NVARCHAR(50),
		sls_prd_key NVARCHAR(50),
		sls_cust_id INT,
		sls_order_dt INT,
		sls_ship_dt INT,
		sls_due_dt INT,
		sls_sales INT,
		sls_quantity INT,
		sls_price INT
		);

		print('>> creating table bronze.erp_CUST_AZ12')
		if OBJECT_ID('bronze.erp_CUST_AZ12', 'U') is not null
			drop table bronze.erp_CUST_AZ12;
		CREATE TABLE bronze.erp_CUST_AZ12(
		cid NVARCHAR(50),
		bdate DATE,
		gen NVARCHAR(50)
		);

		print('>> creating table bronze.erp_LOC_A101')
		if OBJECT_ID('bronze.erp_LOC_A101', 'U') is not null
			drop table bronze.erp_LOC_A101;
		CREATE TABLE bronze.erp_LOC_A101(
        cid NVARCHAR(50),
		cntry NVARCHAR(50)
		);

		print('>> creating table bronze.erp_PX_CAT_G1V2')
		if OBJECT_ID('bronze.erp_PX_CAT_G1V2', 'U') is not null
			drop table bronze.erp_PX_CAT_G1V2;
		CREATE TABLE bronze.erp_PX_CAT_G1V2(
		id NVARCHAR(50),
		cat NVARCHAR(50),
		subcat NVARCHAR(50),
		maintainence NVARCHAR(50)
		);
		set @end_time = GETDATE();
		print '>> inserting data to tables duration: ' + cast(datediff(second, @start_time, @end_time) as varchar(10))

		-- adding data to tables in bronze schema
		set @start_time = GETDATE();
		print('truncating table bronze.crm_cust_info')
		truncate table bronze.crm_cust_info;
		print('inserting data to bronze.crm_cust_info')
		bulk insert bronze.crm_cust_info
		from "D:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv"
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);

		print('truncating table bronze.crm_prd_info')
		truncate table bronze.crm_prd_info;
		print('inserting data to bronze.crm_prd_info')
		bulk insert bronze.crm_prd_info
		from "D:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv"
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);

		print('truncating table bronze.crm_sales_details')
		truncate table bronze.crm_sales_details;
		print('inserting data to bronze.crm_sales_details')
		bulk insert bronze.crm_sales_details
		from "D:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv"
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);

		print('truncating table bronze.erp_CUST_AZ12')
		truncate table bronze.erp_CUST_AZ12;
		print('inserting data to bronze.erp_CUST_AZ12')
		bulk insert bronze.erp_CUST_AZ12
		from "D:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv"
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);

		print('truncating table bronze.erp_LOC_A101')
		truncate table bronze.erp_LOC_A101;
		print('inserting data to bronze.erp_LOC_A101')
		bulk insert bronze.erp_LOC_A101
		from "D:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv"
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);

		print('truncating table bronze.erp_PX_CAT_G1V2')
		truncate table bronze.erp_PX_CAT_G1V2;
		print('inserting data to bronze.erp_PX_CAT_G1V2')
		bulk insert bronze.erp_PX_CAT_G1V2
		from "D:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv"
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print '>> inserting data to tables duration: ' + cast(datediff(second, @start_time, @end_time) as varchar(10))
		set @batch_end_time = getdate();
		print '>> total time taken: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as varchar(10))
		end try
		begin catch	
			print Error_Message()
		end catch
end

exec bronze.load_bronze;