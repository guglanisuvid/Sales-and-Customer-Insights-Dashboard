# Sales and Customer Insights Dashboard

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse, generating actionable insights to creating a dashboard for data driven business decisions.

---

## Data Architecture and Flow of Data

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](/data_architecture_and_flow.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data required for reporting and analytics.

---

## Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Cleaning**: Preprocessing and cleansing raw data to ensure accuracy, consistency, and completeness, including handling missing values, outliers, and duplicates before analysis.
4. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
5. **Analytics & Reporting**: Creating Tableau and SQL-based reports and dashboards for actionable insights.

---

## Sales Dashboard | Requirements

### Dashboard Purpose

The purpose of sales dashboard is to present an overview of the sales metrics and trends in order to analyze year-over-year sales performance and understand sales trends.

### Key Requirements

#### KPI Overview

Display a summary of total sales, profits and quantity for the current year and the previous year.

#### Sales Trends

- Present the data for each KPI on a monthly basis for both the current year and the previous year.
- Identify months with highest and lowest sales and make them easy to recognize.

#### Product Subcategory Comparison

- Compare sales performance by different product subcategories for the current year and the previous year.
- Include a comparison of sales with profit.

#### Weekly Trends for Sales & Profit

- Present weekly sales and profit data for the current year.
- Display the average weekly values.
- Highlight weeks that are above and below the average to draw attention to sales & profit performance.

## Customer Dashboard | Requirements

### Dashboard Purpose

The customer dashboard aims to provide an overview of customer data, trends and behaviors. It will help marketing teams and management to understand customer segments and improve customer satisfaction.

### Key Requirements

#### KPI Overview

Display a summary of total number of customers , total sales per customer and total number of orders for the current year and the previous year.

#### Customer Trends

- Present the data for each KPI on a monthly basis for both the current year and the previous year.
- Identify months with highest and lowest sales and make them easy to recognize.

#### Customer Distribution by Number of Orders

Represent the distribution of customers based on the number of orders they have placed to provide insights into customer behavior, loyalty and engagement.

#### Top 10 Customers By Profit

- Present the top 10 customers who have generated the highest profits for the company.
- Show additional information like rank, number of orders, current sales, current profit and the last order date.

## Design & Interactivity Requirements

#### Dashboard Dynamic

- The Dashboard should allow users to check historical data by offering them the flexibility to select any desired year.
- Provide users with the ability to navigate between the dashboards easily.
- Make the charts and graphs interactive, enabling users to filter data using the charts.

---

## 📂 Repository Structure

```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project
│   ├── source_crm/                     # Raw CRM datasets used for the project
├   ├── source_erp/                     # Raw ERP datasets used for the project
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── exports/                            # Datasets exported after running the scripts
│   ├── bronze/                         # Datasets exported from bronze layer
│   ├── silver/                         # Datasets exported from silver layer
│   ├── gold/                           # Datasets exported from gold layer
│
├── data_architecture_and_flow.png      # Image file for data architecture and flow of data
│
├── Sales and Customer
│   Insights Dashboard.twbx             # Tableau file of the created dashboard
│
├── README.md                           # Project overview and instructions
```

---
