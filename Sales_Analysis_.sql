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
FROM CTE;

WITH CTE AS (
    SELECT
YEAR(order_date) AS year,
MONTH(order_date) AS month,
SUM(profit) AS profit    
FROM sales_rawdata
WHERE YEAR(order_date) IN ('2024','2023','2022')
GROUP BY YEAR(order_date),MONTH(order_date) ),
monthly_growth AS (
    SELECT
month,
ISNULL([2022],0) AS '2022',
ISNULL([2023],0) AS '2023',
ISNULL([2024],0) AS '2024'
FROM CTE
PIVOT(
    SUM(profit)
    FOR [YEAR] IN ([2022],[2023],[2024])
) AS pvt )
SELECT
month,[2022],[2023],[2024],
CAST(
    CASE WHEN [2022] <0 AND [2023] >0 THEN 100
    WHEN [2022] >0 AND [2023] <0 THEN -100 ELSE 
    ([2023] * 100.0 / [2022]) -100 END AS DECIMAL(5,2)) AS '2023 growth rate%',
CAST(
    CASE WHEN [2023] <0 AND [2024] >0 THEN 100
    WHEN [2023] >0 AND [2024] <0 THEN -100 ELSE 
    ([2024] * 100.0 / [2023]) -100 END AS DECIMAL(5,2)) AS '2024 growth rate%'    
FROM monthly_growth








