--DASHBOARD PROFIT GROWTH TREND ANALYSIS

-- connect with database
USE sales_analysis_db;
--database table over vioew
SELECT name FROM sys.tables;

-- bussines problum statement
SELECT 
YEAR(order_date) AS year,
SUM(profit) AS total_profit,
LAG(SUM(profit),1) OVER (ORDER BY YEAR(order_date)) AS previous_year_profit,
CAST((SUM(profit) * 100.0 / LAG(SUM(profit),1) OVER (ORDER BY YEAR(order_date))) -100  AS DECIMAL(5,2)) AS YoY_profit_growth
FROM  sales_rawdata
GROUP BY YEAR(order_date)


