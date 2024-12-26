SELECT * 
FROM new_schema.coffee_sales;

create table coffee_sales1
like coffee_sales;

select *
from coffee_sales1;

insert coffee_sales1
select *
from coffee_sales;

select *
from coffee_sales1;

-- 1. Finding out the total sales of each drink offered to determine highest and lowest selling items

select distinct coffee_name, money
from coffee_sales1
order by 1;

with total_sales as (
select coffee_name, money, count(coffee_name) as total_sales
from coffee_sales1
group by coffee_name, money
),
total_revenue as (
select coffee_name, sum(money * total_sales) as total_revenue
from total_sales
group by coffee_name
)
select sum(total_revenue), min(total_revenue), max(total_revenue)
from total_revenue; 

-- The total sales revenue for was $83646.1, with the highest-selling coffee being 'Latte' at $22002.66 and the lowest-selling coffee being 'Espresso' at $2035.


-- 2. Finding out which seasons have the highest sale volumes
-- Because the dataset begins at March 2024, I will start from March.

select *
from coffee_sales1;

select sum(money) as spring_sales
from coffee_sales1
where date between '2024-03-01' and '2024-06-09'; -- Spring revenue was $25577.

select sum(money) as summer_sales
from coffee_sales1
where date between '2024-06-10' and '2024-09-18'; -- Summer revenue was $25164.

select sum(money) as autumn_sales
from coffee_sales1
where date between '2024-09-19' and '2024-12-23'; -- Autumn revenue was $32904.

-- Autumn sale revenue is shown to be the highest.

-- 3. Finding out the number of unique customers this year using the distinct card values 
-- While there is no customer ID, we are given credit/debit card values. Because there were a few cash-paying customers, I'll separate the two mediums of payments. We cannot be sure that the same customer did not use both card and cash to pay for multiple orders, but because the vast majority of customers used card payments, it should provide a general overview of unique customers.

select count(distinct card)
from coffee_sales1;

select count(cash_type)
from coffee_sales1
where cash_type = "cash";
 -- The total number of distinct card payments are 1038, while the number of cash payments were 89, coming to a combined total of 1127 payments. The total number of orders was 2623, and while we cannot be sure returning customers did not use different cards or use both card/cash, we can at the very least reason a sizable number of returning customers. 
 
 
-- 4. Finding out customer retention rate between seasons

-- Retention rate between spring and summer
with spring_customers as (
select distinct card
from coffee_sales1
where date between '2024-03-01' and '2024-06-09'
and card is not null),

summer_customers as (
select distinct card
from coffee_sales1
where date between '2024-06-10' and '2024-09-18' 
and card is not null),

retained_customers as (
select distinct spc.card
from spring_customers spc
inner join summer_customers sc
on spc.card = sc.card
)
select (count(distinct retained_customers.card) /
count(distinct spring_customers.card)) * 100 as retention_rate
from spring_customers
left join retained_customers
on spring_customers.card = retained_customers.card;
-- Retention rate between spring and summer was 14.9%.

-- Retention rate between summer and winter
with summer_customers as (
select distinct card
from coffee_sales1
where date between '2024-06-11' and '2024-09-18'
and card is not null),

winter_customers as (
select distinct card
from coffee_sales1
where date between '2024-09-19' and '2024-12-23' 
and card is not null),

retained_customers as (
select distinct sc.card
from summer_customers sc
inner join winter_customers wc
on sc.card = wc.card
)
select (count(distinct retained_customers.card) /
count(distinct summer_customers.card)) * 100 as retention_rate
from summer_customers
left join retained_customers
on summer_customers.card = retained_customers.card;
-- Retention rate between summer and winter is 15.3%.
