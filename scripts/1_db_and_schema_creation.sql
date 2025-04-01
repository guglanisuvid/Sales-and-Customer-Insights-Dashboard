use master

--creating database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'data_warehouse')
BEGIN
    CREATE DATABASE data_warehouse;
END;

use data_warehouse;

-- creating schema
go
create schema bronze;
go
create schema silver;
go
create schema gold;
go