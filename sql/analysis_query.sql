create table transactions (
	trans_id bigserial primary key,
	invoice varchar(20) not null,
	stockcode varchar(50) not null,
	description varchar(50),
	quantity int not null,
	invoice_date timestamp not null,
	price numeric(10,2) not null,
	customer_id int,
	country varchar(20),
	is_cancelled_invoice boolean not null,
	is_return boolean not null,
	is_guest_customer boolean not null,
	is_non_product boolean not null,
	is_non_sales boolean not null,
	is_invalid_price boolean not null,
	total_price numeric(15,2) not null,
	year int not null,
	month int not null,
	day int not null,
	hour int not null,
	country_group varchar(10) not null default 'Others'
);

create table customers (
	customer_id int primary key,
	country varchar(20),
	is_guest_customer boolean default False
);

-- Run this command in PSQL (SQL Shell)
-- \copy transactions (invoice,stockcode,description,quantity,invoice_date,price,customer_id,country,is_cancelled_invoice,is_return,is_guest_customer,is_non_product,is_non_sales,is_invalid_price,total_price,year,month,day,hour,country_group) 
-- FROM 'C:/path/cleaned_online_retail.csv' WITH (FORMAT csv, HEADER true);


insert into customers 
select distinct 
	customer_id, 
	mode() WITHIN GROUP (ORDER BY country) AS country,
	False as is_guest_customer
from transactions
where customer_id is not null
GROUP BY customer_id;

create table products (
	stockcode varchar(50) primary key,
	description varchar(50),
	is_non_product boolean not null
);

INSERT INTO products (stockcode, description, is_non_product)
SELECT stockcode,
       mode() WITHIN GROUP (ORDER BY description) AS description,
       bool_or(is_non_product) AS is_non_product
FROM transactions
GROUP BY stockcode; 

alter table transactions add constraint fk_customer foreign key (customer_id) references customers(customer_id);
alter table transactions add constraint fk_product foreign key (stockcode) references products(stockcode);

-- ⭐ Core Matrics 
-- Total number of customers
select count(customer_id) 
from customers; 

-- Guest customer count
select count(is_guest_customer)
from transactions
where is_guest_customer is True;

-- Return Rate (%)
select
	sum(case when is_return then 1 else 0 end) * 100
	/ count(*) as return_rate
from transactions;

-- Cancel Rate (%)
select 
	sum(case when is_cancelled_invoice then 1 else 0 end) * 100.0
	/ count(*) as canceled_rate
from transactions;

-- Total Units Sold
select sum(quantity) 
from transactions 
where is_non_sales = FALSE;

-- ⭐ REVENUE ANALYSIS
-- 1. Total Revenue (Net Revenue)
select sum(total_price) as net_revenue
from transactions
where is_non_sales = False;
-- The Net Revenue is 2,09,72,595 i.e After removing canceled orders

-- 2. Monthly Revenue Trend
select year,month, sum(total_price) as net_monthly_revenue
from transactions
where is_non_sales = False
group by year,month  
order by sum(total_price);

-- 3. Daily Revenue Trend (Short View)
SELECT 
    invoice_date::date AS day,
    SUM(total_price) AS daily_revenue
FROM transactions
WHERE is_non_sales = FALSE
GROUP BY invoice_date::date
ORDER BY day;

-- 4. Hourly Revenue Trend 
select hour, sum(total_price) as hourly_net_revenue
from transactions 
where is_non_sales = False
group by hour
order by sum(total_price);

-- 5. Average Order Value (AOV)
select 
	sum(total_price) / count(distinct invoice) as aov
from transactions
where is_non_sales = False;

-- ⭐ PRODUCT METRICS
-- 1. Top Selling Products (by Units)
select stockcode,description, sum(quantity) as units_sold
from transactions
where is_non_sales = False and is_non_product = False
group by stockcode,description
order by units_sold desc;

-- 2. Top Revenue-Generating Products
select stockcode,description, sum(total_price) as revenue 
from transactions
where is_non_sales = False and is_non_product = False
group by stockcode,description
order by revenue desc
limit 10;

-- 3. Products with the Highest Return Rate
SELECT 
    stockcode,
    description,
    SUM(CASE WHEN is_return = TRUE THEN ABS(quantity) END) AS units_returned,
    SUM(CASE WHEN is_return = FALSE THEN quantity END) AS units_sold,
    (SUM(CASE WHEN is_return = TRUE THEN ABS(quantity) END) * 100.0)
        / NULLIF(SUM(CASE WHEN is_return = FALSE THEN quantity END), 0)
        AS return_rate_percentage
FROM transactions
where description <> 'unkown product'
GROUP BY stockcode, description
HAVING SUM(quantity) < 0   -- ensures product has returns
ORDER BY return_rate_percentage DESC
LIMIT 10;

-- 4. Dead Products (0 or extremely low sales)
select stockcode, description, sum(quantity) as units_sold
from transactions 
where is_non_sales = False and is_non_product = False
group by stockcode, description
having sum(quantity) <= 5
order by units_sold
limit 5;

-- 5. Products to Discontinue
SELECT
    stockcode,
    description,
    SUM(CASE WHEN is_return = TRUE THEN ABS(quantity) END) AS units_returned,
    SUM(CASE WHEN is_return = FALSE THEN quantity END) AS units_sold,
    (SUM(CASE WHEN is_return = TRUE THEN ABS(quantity) END) * 100.0)
        / NULLIF(SUM(CASE WHEN is_return = FALSE THEN quantity END), 0)
        AS return_rate_pct
FROM transactions
GROUP BY stockcode, description
HAVING 
    SUM(quantity) < 50         -- low sales
    AND SUM(quantity) < 0      -- has returns
ORDER BY return_rate_pct DESC
LIMIT 20;

-- ⭐ CUSTOMER METRICS
-- 1. Active Customers per Month
select year,month, count(distinct customer_id) as unique_customers
from transactions
where customer_id is not null and is_non_sales = False
group by year,month
order by unique_customers desc;
-- 1) Active Customers per Month : When year and month was reviewed it was observed that the numbers of Active Customers per Month changes with out a pattern, but when it was reviewed on the bases of no. of customers  it showed that we have most active customers in month 9,10,11 it was also observed that 3rd month  also have good number of active customers might be bcz it is the end of financial year so business might do stock clearance.

-- 2. New Customers per Month
with customer_first_purchase as (
	select customer_id, min(invoice_date::date) as first_purchase_date
	from transactions
	where customer_id is not null and is_non_sales = False
	group by customer_id
), first_purchase_year as (
	select customer_id,
	extract(year from first_purchase_date) as first_year,
	extract(month from first_purchase_date) as first_month
	from customer_first_purchase
)
select first_year as year, first_month as month, count(customer_id) as new_customers
from first_purchase_year
group by year, month
order by new_customers desc;
-- 2) New Customers per Month : This time we wasn't able to find such insights as there where no patterns in this, but what i observed that mostly months which have new customers are from 2010

-- 3. Returning Customers per Month
with monthly_activity as (
	select customer_id, year, month, invoice_date,
	min(invoice_date) over(partition by customer_id) as first_purchase
	from transactions
	where customer_id is not null and is_non_sales = False
)
select year, month, count(distinct customer_id) as returning_customers
from monthly_activity
where invoice_date > first_purchase
group by year, month
order by returning_customers desc;
-- 3) Returning Customers per Month : Initially in dec 2009 the returning customers count was low, but it gradually went up till nov 2010 after that the count of returning customers faced little fall but then again it gradually rise,  It is again observed that the last months of the year has good no. of returning customers as compared to starting months

-- 4. Repeat Purchase Rate
select 
count(*) filter(where purchase_count>=2) * 100 /  count(*) as repeat_purchase_rate
from
(select customer_id, count(distinct invoice) as purchase_count
from transactions
where customer_id is not null and is_non_sales = False
group by customer_id);
-- 4) Repeat Purchase Rate : The Repeat rate is 72.38 which is good :)

-- 5. Top 10 Customers by Revenue
select customer_id, sum(total_price) as total_revenue
from transactions
where customer_id is not null and is_non_sales = False
group by customer_id
order by total_revenue desc
limit 10; 
-- 5) Top 10 Customers by Revenue : Again there is no insights as such, here are the customer ids of our Top 10 customers: 18102, 14646, 14156, 14911, 17450, 13694, 17511, 16446, 16684, 12415, So for this thing i dont have insights for the business, but yeah i have 1 advice, these are the customers which we dont want to loose, so we need to do some loyalty programs for them like offers etc, plus if they are happy they will recommend more business to buy from us :)

-- 6. Pareto Analysis (10%)
with customers_rev_list as (
	select customer_id, sum(total_price) as cust_revenue
	from transactions
	where customer_id is not null and is_non_sales = False
	group by customer_id
), ranked as (
	select customer_id, cust_revenue,
	ntile(10) over(order by cust_revenue desc) as decile
	from customers_rev_list
), total_rev as (
	select sum(cust_revenue) as total_revenue from customers_rev_list
)
select (sum(cust_revenue)*100/ (select total_revenue from total_rev)) as top_10_pct_revenue,
from ranked
where decile = 1 ;

-- 6. Pareto Analysis (20%)
with customers_rev_list as (
	select customer_id, sum(total_price) as cust_revenue
	from transactions
	where customer_id is not null and is_non_sales = False
	group by customer_id
), ranked as (
	select customer_id, cust_revenue,
	ntile(100) over(order by cust_revenue desc) as decile
	from customers_rev_list
), total_rev as (
	select sum(cust_revenue) as total_revenue from customers_rev_list
)
select (sum(cust_revenue)*100/ (select total_revenue from total_rev)) as top_10_pct_revenue
from ranked
where decile = 1 ;

-- 6. Pareto Analysis (1%)
WITH cust_rev AS (
    SELECT 
        customer_id,
        SUM(total_price) AS revenue
    FROM transactions
    WHERE customer_id IS NOT NULL 
      AND is_non_sales = FALSE
    GROUP BY customer_id
),
ranked AS (
    SELECT 
        customer_id,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn,
        COUNT(*) OVER () AS total_customers
    FROM cust_rev
),
top_1 AS (
    SELECT 
        revenue
    FROM ranked
    WHERE rn <= CEIL(0.01 * total_customers)
),
total AS (
    SELECT SUM(revenue) AS total_revenue FROM cust_rev
)
SELECT 
    (SUM(revenue) * 100.0) / (SELECT total_revenue FROM total) AS top_1_pct_revenue
FROM top_1;
-- Our Top 1% customers contributes 32% of revenue - which means that it is concentrated and losing this can cause 32% loss in revenue 
-- Our Top 10% customers contributes 64% of revenue 
-- Our Top 20% customers contributes 77% of revenue
-- With the help of Pareto Analysis it is observed that business revenue is heavily dependent on Top 20% customers as they shares 77% of the revenue rest 80% only contributes to 23% revenue.

-- 7. Guest vs Registered Customer Behavior
select is_guest_customer, count(*) as orders ,sum(total_price) as total_revenue, avg(total_price) as average_price 
from transactions
where is_non_sales = False
group by is_guest_customer;
-- 7) Guest vs Registered Customer Behavior : It is observed that Registered customers brings more order and revenue in the business, also there average order value is more than guest customers, business should stop guest shopping, as annonymus customers are hard to track and target in campaigns 

-- ⭐ RETURN ANALYSIS
-- 1. OVERALL RETURN RATE (units-based)
select units_returned, units_sold, ((units_returned * 100.0) / units_sold) as return_rate from (
select 
	sum(case when is_return = True then abs(quantity) else 0 end) as units_returned,
	sum(case when is_non_sales = False and quantity > 0 then quantity else 0 end) as units_sold
from transactions
);
-- 1) OVERALL RETURN RATE (units-based) : Return Rate is only 9.31% which is less, so the business has less return products

-- 2. MONTHLY RETURN RATE
select year, month, units_returned, units_sold, ((units_returned * 100) / units_sold) as return_rate
from
(
	select year, month, 
	sum(case when is_return = True then abs(quantity) else 0 end) as units_returned,
	sum(case when is_non_sales = False and quantity > 0 then quantity else 0 end) as units_sold
	from transactions 
	group by year, month
)
order by return_rate desc;
-- 2) MONTHLY RETURN RATE : Return spikes occur in mid-year and late-year, basically post holiday return spike which is a operational pressure zones.

-- 3. TOP RETURNING CUSTOMERS (units returned)
select customer_id, sum(abs(quantity)) as returned_units
from transactions
where is_return = True and customer_id is not null
group by customer_id
order by returned_units desc
limit 10;
-- 3) TOP RETURNING CUSTOMERS (units returned) : we got info of 10 customers returning goods, highest is 88k units to 6.3K, the problems of this customers should be listened and solved

-- 4. RETURN RATE BY CUSTOMER (%)
with base as (
	select customer_id, 
	sum(case when is_return = True then abs(quantity) else 0 end) as units_returned,
	sum(case when is_non_sales = False and quantity > 0 then quantity else 0 end) as units_bought
	from transactions
	where customer_id is not null
	group by customer_id
)
select customer_id, (units_returned*100)/nullif(units_bought,0) as return_rate
from base
where units_bought > 0
order by return_rate desc
limit 20;
-- 4) RETURN RATE BY CUSTOMER (%) : Dannggg the highest return rate is 300 to 100 among the top 20 returning customers, which means these customers are abusing returns an special treatment has to be given to them

-- 5. RETURN RATE BY PRODUCT
with base as (
	select stockcode, description,
	sum(case when is_return = True then abs(quantity) else 0 end) as units_returned,
	sum(case when is_return = False then quantity else 0 end) as units_sold
	from transactions
	group by stockcode, description
)
select stockcode, description, (units_returned*100)/nullif(units_sold,0) as return_rate
from base
where units_sold > 0
order by return_rate desc
limit 20; 
-- 5) RETURN RATE BY PRODUCT : Here we got the return rates of products the top 2 products are Samples and discounts (idk what tf they are doing here :/ ) along with that we have amazon fee too at 4th place, and when we talk about products there are mostly Fragile & Electrical Items like "Feather heart lights" and "Ceramic cake teapot" as they are delicate items so they might get damaged during transit plus the electric item quality might not be good so business should be extra conscious with delicate items plus they should check the quality of products they are giving, along with this there are holiday items too, plus all the products cancelled where bulk orders, as the highest return rate is 3365 to the lowest is 100, which is huge

-- 6. RETURN REVENUE LOSS
SELECT
    (SELECT SUM(ABS(total_price)) from transactions WHERE is_return = TRUE AND is_non_product = FALSE)*100.0/
    SUM(total_price) AS total_revenue
FROM transactions
WHERE is_non_sales = FALSE AND is_non_product = FALSE;
-- 6) RETURN REVENUE LOSS : The RETURN REVENUE LOSS is 7.28%

-- ⭐ COUNTRY METRICS
-- 1. Revenue by Country (Top 10 only)
select country, sum(total_price) as revenue 
from transactions
group by country
order by revenue desc
limit 10;
-- 1) Revenue by Country (Top 10 only) : Our Top 10 Revenue Generating Countries are Mostly(9) European countries U.K is the highest as it is the operating/home county of this business, along with that Australia is on the list too.

-- 2. Return Rate by Country
select country, (units_returned*100.0)/units_sold as return_rate
from
(select country, 
sum(case when is_return = True then abs(quantity) else 0 end) as units_returned,
sum(case when is_return = False then quantity else 0 end) as units_sold
from transactions
group by country)
order by return_rate desc
limit 10;
-- 2) Return Rate by Country : The country with highest return rate is Nigeria an African country, along with that we have France,USA,Korea,Czech Republic,Spain,United Kingdom (Obviously as it is the main hub & home of this business),UAE,Saudi Arabia,Bahrain. There are no geographical connections among all this country that we have seen in revenue ones, but the main reason for returns might include Damage via transit, low demand for our holiday or gift items in these counties or our products quality doesn't match with there customers standards 

-- 3. Customer Count by Country
select country, count(distinct customer_id) customer_count
from transactions
where customer_id is not null
group by country
order by customer_count desc
limit 10;
-- 3) Customer Count by Country : Again further continuing with the context of revenue by country, All the countries with Highest customer count is UK as it is the home country of business along with that other European counties close to UK, this and revenue indicates that this business has a strong customer network & business relation in its home country and neighbouring countries 