--DASHBOARD PROFIT GROWTH TREND ANALYSIS

-- connect with database
USE sales_analysis_db;
--database table over vioew
SELECT name FROM sys.tables;

-- bussines problum statement
WITH CTE AS (
    SELECT 
YEAR(order_date) AS year,
SUM(profit) AS total_profit,
LAG(SUM(profit),1) OVER (ORDER BY YEAR(order_date)) AS previous_year_profit,
CAST((SUM(profit) * 100.0 / LAG(SUM(profit),1) OVER (ORDER BY YEAR(order_date))) -100  AS DECIMAL(5,2)) AS YoY_profit_growth
FROM  sales_rawdata
GROUP BY YEAR(order_date))
SELECT
MAX(CASE WHEN year = '2024' THEN previous_year_profit END) AS current_year,
MAX(CASE WHEN year = '2023' THEN previous_year_profit END) AS previous_year,
MAX(CASE WHEN year = '2024' THEN yoy_profit_growth END) AS current_year_gwt,
MAX(CASE WHEN year = '2023' THEN yoy_profit_growth END) AS previous_year_gwt,
MAX(CASE WHEN year = '2024' THEN yoy_profit_growth END) - MAX(CASE WHEN year = '2023' THEN yoy_profit_growth END) AS growth_rate_diff
FROM CTE







