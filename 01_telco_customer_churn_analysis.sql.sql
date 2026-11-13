create table customer_churn
like telco_customer_churn;

select * from customer_churn;

insert customer_churn 
select * from telco_customer_churn;

select count(*) from customer_churn; -- good rsault

-- ------------------------------------------------------
				-- removing duplicats--
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   CustomerID, `Count`, Country, State, City,
                   `Zip Code`, `Lat Long`, Latitude, Longitude,
                   Gender, `Senior Citizen`, Partner, Dependents,
                   `Tenure Months`, `Phone Service`, `Multiple Lines`,
                   `Internet Service`, `Online Security`, `Online Backup`,
                   `Device Protection`, `Tech Support`, `Streaming TV`,
                   `Streaming Movies`, Contract, `Paperless Billing`,
                   `Payment Method`, `Monthly Charges`, `Total Charges`,
                   `Churn Label`, `Churn Value`, `Churn Score`, CLTV,
                   `Churn Reason`
           ) AS row_num
    FROM customer_churn
)
SELECT *
FROM duplicate_cte
where row_num > 1 ; -- there is no duplicates -- 

 -- -----------------------------------------------------------------------
 select `Lat Long`,Latitude,Longitude
 from customer_churn
 limit 10; --
 
 select *
 from customer_churn
where `Lat Long` is null
	or 
		Latitude is null
	or
		Longitude is null ; -- none
select count(Longitude)
 from customer_churn;
 
 -- 
alter table customer_churn
drop column `Lat Long`;

select * from customer_churn;

select 
count(*) as total_rows,
sum(`Churn Reason` is null) as null_valuse,
sum(trim(`Churn Reason`)='') as empty_value,
sum(trim(`Churn Reason`)<>'') as filled_values
from customer_churn;

select * from customer_churn
where trim(`Churn Reason`) = '';

update customer_churn
set `Churn Reason` = null where trim(`Churn Reason`) =''; -- it`s not working so 

select * from customer_churn
where `Churn Reason` is null;

update customer_churn
set `Churn Reason` = null 
where CustomerID in (select CustomerID 
from
(select CustomerID from customer_churn
where trim(`Churn Reason`) ='') 
as temp 
);

DESCRIBE customer_churn;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    SUM(CustomerID IS NULL) AS null_ids
FROM customer_churn;

SET SQL_SAFE_UPDATES = 0;

alter table customer_churn
modify CustomerID varchar(20) not null,
add primary key (CustomerID);  -- now i can run the update

select * from customer_churn;
-- EDA----------------------------------------------------------------------

select count(*) from customer_churn; -- '7043'

select count(*) from customer_churn
where `Churn Value` = 1 ; -- '1869'

select sum(`Churn Value`)/count(*) * 100 as churn_rate
from customer_churn;  -- '26.5370'

-- by gender 
select Gender,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by Gender; 	--

-- by Senior Citizen
select `Senior Citizen`,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by `Senior Citizen`; --

-- who have Partner
select Partner,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by Partner;

-- Dependents
select Dependents,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by Dependents;
 
-- the raelthion between the service and the churn
select `Phone Service`,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by `Phone Service`;

-- by Internet Service
select `Internet Service`,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by `Internet Service`;

-- Online Security
select `Online Security`,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by `Online Security`;

-- Tech Support
select `Tech Support`,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by `Tech Support`;

-- contract type 
select Contract,count(*)  as total_customers,
sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from customer_churn
group by Contract;

-- average monthly charges for churned and non-churned customers
select `Churn Label`,count(*)  as total_customers,
avg(`Monthly Charges`) as avg_monthly_charges
from customer_churn
group by `Churn Label`;

-- monthly charges
select `Churn Label`,count(*)  as total_customers,
avg(`Monthly Charges`) as avg_monthly_charges
from customer_churn
group by `Churn Label`;

-- tenure analysis
select  `Churn Label` ,count(*)  as total_customers,
avg(`Tenure Months`) as avg_tenure
from customer_churn
group by `Churn Label`;

-- --------Financial & Tenure Analysis-------------------------
with tenure_cte as (
select `Churn Value`,`Tenure Months`,
case
	when `Tenure Months` between 0 and 12 then 'New'
    when `Tenure Months` between 13 and 36 then 'Medium'
    else 'Long-term'
    end as tenure_group
 from customer_churn)
 
 select tenure_group,
 count(*) as total_customers,
 sum(`Churn Value`) as churned_customers,
sum(`Churn Value`) / count(*) * 100 as churn_rate
from tenure_cte
group by tenure_group;

-- -------------------------------------------------------
select `Churn Reason`,
count(*) as total_customers 
from customer_churn
where `Churn Value` = 1
and `Churn Reason` is not null
group by `Churn Reason`
order by total_customers  desc
limit 5;