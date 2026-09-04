--SELECT * FROM orders;


--highest revenue generating products.
select product_id, sum(sale_price) as Revenue
from orders
group by product_id
order by Revenue desc;


--highest revenue generating products by region.
with cte as (
select region, product_id, sum(sale_price) as Revenue from orders
group by region, product_id)
select * from (
select *, ROW_NUMBER() over(partition by region order by Revenue desc) as Rank
from cte) as a
where Rank<=5;



--Monthly growth between 2022-2023
with cte as (
select year(order_date) as Year, month(order_date) as Month, sum(sale_price) as Revenue 
from orders
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)
select Month
,sum(case when Year=2022 then Revenue else 0 end) as sales_2022
,sum(case when Year=2023 then Revenue else 0 end) as sales_2023
from cte
group by Month
order by Month



--highest monthly sales per category.
with cte as (
select category, FORMAT(CAST(order_date as DATETIME),'yyyy-MM') as year_month, sum(sale_price) as Revenue from orders
group by category, FORMAT(CAST(order_date as DATETIME),'yyyy-MM')
--order by category, FORMAT(CAST(order_date as DATETIME),'yyyy-MM');
)
select * from (
select *, 
row_number() over(partition by category order by Revenue desc) as rank
from cte 
) a
where rank=1;






--highest sales growthin percent by subcategory. r2023-r2022
with cte as (
select sub_category, year(order_date) as Year, sum(sale_price) as Revenue from orders
group by sub_category, year(order_date) 
),
cte2 as (
select sub_category,
sum(case when Year=2022 then Revenue else 0 end) as Revenue_2022,
sum(case when Year=2023 then Revenue else 0 end) as Revenue_2023
from cte
group by sub_category
)
select *,
(Revenue_2023-Revenue_2022)*100/Revenue_2022 as Growth
from cte2
order by Growth desc


