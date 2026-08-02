-- Profit Leakage Analysis

-- bussiness problume statement
with cte as(
    select
year(order_date) as year,
count(order_id) as total_order,
lag(count(order_id),1) over (order by year(order_date)) as pre_year_order,
sum(sales) as sales,
lag(sum(sales),1) over (order by year(order_date)) as pre_year_sales,
sum(profit) as profit,
lag(sum(profit),1) over (order by year(order_date)) as pre_year_profit
from sales_rawdata
group by year(order_date)
)
select 
year, 
total_order,
cast((total_order * 100.0 / pre_year_order) - 100 as decimal(5,2)) as order_growth_rate,
sales,
cast((sales * 100.0 / pre_year_sales) - 100 as decimal(5,2)) as sales_growth_rate,
profit,
cast((profit * 100.0 / pre_year_profit - 100) as decimal(5,2)) as order_growth_rate
from cte ;

with cte as(
    select 
year(order_date) as year,
case when discount <= 0.05 then '0-5' 
    when discount <= 0.15 then '6-15' 
    when discount <= 0.25 then '16-25' else 'above 25' end as discount_type,
count(order_id) as order_rec,    
sum(profit) as profit    
from sales_rawdata
group by year(order_date),
    case when discount <= 0.05 then '0-5' 
    when discount <= 0.15 then '6-15' 
    when discount <= 0.25 then '16-25' else 'above 25' end 
    )
select
*
from cte
where year in (2023,2024)
order by year , discount_type
