
-- -- CREATE SALES DATA
-- -- 
-- create table sales_rawdata
-- (
--     Row_ID nvarchar(max),
--     Order_ID nvarchar(max),
--     Order_Date nvarchar(max),
--     Ship_Date nvarchar(max),
--     Ship_Mode nvarchar(max),
--     Customer_ID	nvarchar(max),
--     Customer_Name nvarchar(max),
--     Segment	nvarchar(max),
--     Country_Region nvarchar(max),
--     City nvarchar(max),
--     State_Province nvarchar(max),
--     Region nvarchar(max),
--     Product_ID nvarchar(max),
--     Category nvarchar(max),	
--     Sub_Category nvarchar(max),
--     Product_Name nvarchar(max),	
--     Sales nvarchar(max),
--     Quantity nvarchar(max),
--     Discount nvarchar(max),	
--     Profit nvarchar(max)
-- ) ;
-- --IMPORT DATA FROM LOCAL FILE PATH AS CSV 
-- -- 
-- bulk insert sales_rawdata
-- from 'F:\Dashboard\Sales_OverView\Sales_Overview_Data.csv'
-- with(
--         firstrow = 2,
--         format = 'csv' 
-- );
-- -- 
-- --CHANGE COLUMN DATA DYPE
-- -- 
-- alter table sales_rawdata
-- alter column sales decimal(10,0);
-- alter table sales_rawdata
-- alter column profit decimal(10,0);
-- alter table sales_rawdata
-- alter column quantity int;
-- alter table sales_rawdata
-- alter column discount decimal(10,2);
-- -- 
-- --CREATE CUSTOMER DEMINSION TABLE
-- -- 
-- select 
-- customer_id,
-- customer_name,
-- segment,
-- country_region into customer_dem
-- from sales_rawdata;
-- -- 
-- --REMOVE DUPLICATE CUSTOMER_ID FROM CUSTOMER_DEMINTION TABLE
-- -- 
-- begin transaction ;
-- with cte as(
--     select
-- customer_id,
-- row_number() over (partition by customer_id order by customer_id) as rnk
-- from customer_dem 
-- )
-- delete from cte
-- where rnk > 1;
-- -- 
-- --ADD PRIMARY KEY ON CUSTOMER_ID

-- alter table customer_dem
-- add constraint pk_customer_id
-- primary key (customer_id);
-- -- 
-- ----ADD FOREIGEN KEY ON SALES RAWDATA TABLE (CUSTOMER_ID)

-- alter table sales_rawdata 
-- add constraint  fk_customer_id 
-- foreign key (customer_id) 
-- references customer_dem (customer_id) on delete cascade on update cascade 
-- -- 
-- --CREATE PRODUCT_TABLE 
-- -- 
-- begin transaction;
-- with cte as(
-- select 
-- product_name,
-- row_number() over (partition by product_name order by product_name) as rnk
-- from product_dem )
-- delete from cte
-- where rnk > 1  ;

-- alter table sales_rawdata 
-- add product_id_ int ;
-- -- 
-- UPDATE PRODUCT ID KEY INTO FACT TABLE 
-- -- 
-- begin transaction ;
-- update x 
-- set 
--     x.product_id_ = y.product_id_ from sales_rawdata x
--     inner join product_dem y 
--     on x.product_name = y.product_name;
-- -- 
-- ADD FOREIGN KEY IN SALES_RAWDATA (PRODUCT_ID)
-- alter table sales_rawdata 
-- add constraint fk_product_id
-- foreign key (product_id)
-- references product_dem (product_id) on delete cascade on update cascade;

-- select 
-- state_province, count(distinct city) as city , count(distinct region) region
-- from sales_rawdata
-- group by state_province
-- -- 
-- --CREATE REGION TABLE
-- select 
-- distinct region into region_dem
-- from sales_rawdata ;
-- -- 
-- alter table region_dem
-- add region_id int primary key identity(1,1);
-- -- 
-- alter table sales_rawdata 
-- add region_id int 
-- constraint fk_region_id 
-- foreign key (region_id)
-- references region_dem (region_id) on delete cascade on update cascade;
-- -- 
-- update x 
-- set 
-- x.region_id = y.region_id from sales_rawdata x
-- inner join region_dem y 
-- on x.region = y.region
-- -- 
-- create state table 
-- select 
-- distinct state_province into state_dem
-- from sales_rawdata ;
-- -- 
-- alter table state_dem 
-- add state_id int primary key identity(1,1);
-- -- 
-- alter table sales_rawdata 
-- add state_id int constraint fk_state_location
-- foreign key (state_id)
-- references state_dem (state_id) on delete cascade on update cascade;
-- -- 
-- update x 
-- set  
-- x.state_id = y.state_id from sales_rawdata x
-- inner join state_dem y
-- on x.State_Province = y.state_province ;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------

-- -- (1) bussines over view

-- SELECT
-- SUM(sales) AS total_sales,
-- SUM(quantity) AS total_qty,
-- SUM(profit) AS total_profit,
-- COUNT(order_id) AS total_order_received
-- FROM sales_rawdata
-- WHERE YEAR(Order_Date) IN (SELECT MAX(YEAR(Order_Date)) FROM sales_rawdata)

-- (2) bussines growth rate 

WITH CTE AS (
SELECT
YEAR(Order_Date) AS year,
SUM(sales) AS total_sales,
(SUM(sales) * 100.0 / LAG(SUM(sales),1) OVER (ORDER BY YEAR(Order_Date) ASC)) - 100 AS growth_rate_of_sales,
SUM(Profit) AS total_prfit,
(SUM(Profit) * 100.0 / LAG(SUM(profit),1) OVER (ORDER BY YEAR(Order_Date))) -100 AS growth_rate_of_profit
FROM sales_rawdata
GROUP BY YEAR(Order_Date) )
SELECT
year,
total_sales,
CAST(growth_rate_of_sales- LAG(growth_rate_of_sales,1) OVER (ORDER BY year) AS DECIMAL(5,2)) growth_slowdown,
total_prfit, 
growth_rate_of_profit - LAG(growth_rate_of_profit,1) OVER (ORDER BY year) AS growth_slowdown
FROM CTE
WHERE [year] >= (SELECT MAX(year)-2 FROM CTE)

-

SELECT 
YEAR(Order_Date) AS year,
MONTH(Order_Date) AS month,
SUM(sales) AS total_amount,
LAG(SUM(sales),12) OVER (ORDER BY YEAR(Order_Date),MONTH(Order_Date) ) AS growth_sales,
(SUM(sales) * 100.0 / LAG(SUM(sales),12) OVER (ORDER BY YEAR(Order_Date),MONTH(Order_Date)) -100) AS growh_slowdown,
SUM(profit) AS total_profit
FROM sales_rawdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date);

SELECT
YEAR(Order_Date) AS year,
SUM(sales) AS total_sales,
SUM(Profit) AS totalprofit,
SUM(Profit) * 100 / SUM(sales) AS profit_margin
FROM sales_rawdata
GROUP BY YEAR(Order_Date)
ORDER BY YEAR(Order_Date);

SELECT MAX(Order_Date) FROM sales_rawdata
SELECT * FROM state_dem
SELECT * FROM product_dem;

