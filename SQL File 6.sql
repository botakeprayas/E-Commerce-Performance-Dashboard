CREATE DATABASE TOY_STORE;

-- --------------------------- HANDLING NULL VALUES --------------------
 UPDATE website_sessions SET utm_source = 'Unknown' WHERE utm_source IS NULL; 


-- -------------------Revenue & Orders----------------------------------------

-- What is total revenue, total orders, and AOV?
CREATE VIEW  KPIs AS
SELECT ROUND(SUM(price_usd),2) as Total_Revenue ,COUNT(DISTINCT order_id) as `Total orders`,
ROUND((SUM(price_usd)/COUNT(DISTINCT order_id)),2) `Average order value` FROM order_items;  -- done 


-- Monthly revenue & order trend.
CREATE VIEW MONTHLY_REVENUE AS
SELECT 
    YEAR(created_at) AS Years,
    MONTH(created_at) AS `Month Number`,
    MONTHNAME(created_at) AS Months,
    ROUND(SUM(items_purchased * price_usd),2) AS `Total Revenue`,
    COUNT(DISTINCT order_id) AS `Total Orders`
FROM orders
GROUP BY Years, `Month Number`, Months
ORDER BY  `Month Number`; -- done 





-- Which products generate highest revenue?
CREATE VIEW PRODUCT_REVENUE AS
SELECT product_name,ROUND(SUM(items_purchased * price_usd),2) AS Total_Revenue FROM orders 
JOIN products ON products.product_id=orders.primary_product_id GROUP BY product_name ORDER BY Total_Revenue DESC ; -- ----- done


-- Which products have highest refund rate?
CREATE VIEW PRODUCT_REFUND_RATE AS
SELECT 
	product_name,
    COUNT(order_items.order_item_id) AS `Total Sold`,
    COUNT(order_item_refunds.order_item_id) AS `Total Refund`,
	ROUND(COUNT(order_item_refunds.order_item_id)*100.0 / COUNT(order_items.order_item_id), 2)  AS `Refund Rate` 
FROM order_items LEFT JOIN order_item_refunds ON order_items.order_item_id= order_item_refunds.order_item_id
JOIN products ON order_items.product_id = products.product_id GROUP BY product_name ORDER BY `Refund Rate`  DESC; -- ------- done


-- -------------------------------Refund & Loss Analysis----------------------------

-- Total refunded amount per month.
CREATE VIEW REFUND_BY_MONTH AS
SELECT 
    YEAR(order_item_refunds.created_at) AS year,
    MONTH(order_item_refunds.created_at) AS month_num,
    MONTHNAME(order_item_refunds.created_at) AS month_name,
    ROUND(SUM(order_item_refunds.refund_amount_usd), 2) AS total_refunded_amount
FROM order_item_refunds 
GROUP BY year, month_num, month_name
ORDER BY year, month_num ;
select * from refund_by_month;    -- --------------- done



-- Refund percentage by product.
CREATE VIEW REFUND_PERCENTAGE_BY_PRODUCT AS
SELECT product_name,ROUND((COUNT(order_item_refunds.order_item_refund_id) * 100.0/COUNT(order_items.order_item_id)),2) AS `Refund Percentage By Products` FROM order_items 
LEFT JOIN order_item_refunds ON order_item_refunds.order_item_id=order_items.order_item_id 
JOIN products ON order_items.product_id= products.product_id GROUP BY product_name ORDER BY `Refund Percentage By Products` DESC;


-- Revenue loss due to refunds.
CREATE VIEW LOSS_BY_REFUND AS
SELECT 
    COUNT(DISTINCT order_item_refund_id) AS `Total Refunded Orders`,
    ROUND(SUM(refund_amount_usd), 2) AS `Revenue Loss Due To Refunds`
FROM order_item_refunds;
select * from products;



-- Net revenue after refunds.

CREATE VIEW net_revenue AS  
SELECT
    products.product_name,
    ROUND(SUM(order_items.price_usd), 2) AS gross_revenue,
    ROUND(SUM(order_items.price_usd)- SUM(CASE WHEN order_item_refunds.order_item_id IS NOT NULL THEN order_items .price_usd ELSE 0 END),2) AS net_revenue
FROM order_items 
LEFT JOIN order_item_refunds 
    ON order_items.order_item_id = order_item_refunds.order_item_id
JOIN products 
    ON order_items.product_id = products.product_id
GROUP BY products.product_name;
select * from net_revenue;



--     --------------------------Funnel & Website Analytics------------------------

-- Sessions → Orders conversion rate.
CREATE VIEW CONVERSION_RATE AS
SELECT 
COUNT(orders.order_id) AS orders,COUNT(website_sessions.website_session_id) AS sessions,
ROUND((COUNT(orders.order_id)*100.0)/(COUNT(website_sessions.website_session_id)),2) AS `Conversion Rate`
FROM 
website_sessions LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id ;
select * from conversion_rate;

-- Conversion rate by traffic source.
CREATE VIEW CONVERSION_BY_TRAFFIC AS
SELECT 
utm_source AS Traffic_Source,
device_type,
COUNT( website_sessions.website_session_id) AS sessions,
COUNT( orders.order_id) AS orders,
ROUND((COUNT( orders.order_id)/COUNT( website_sessions.website_session_id)) * 100,2) AS Conversion_rate_by_traffic
FROM website_sessions LEFT JOIN orders 
ON website_sessions.website_session_id=orders.website_session_id
GROUP BY utm_source,device_type ORDER BY Conversion_rate_by_traffic DESC;

-- Page-wise drop-off analysis.
CREATE VIEW PAGE_DROP_OFF AS
WITH page_flow AS (
    SELECT
        website_session_id,
        website_pageview_id,
        pageview_url,
        ROW_NUMBER() OVER (PARTITION BY website_session_id ORDER BY website_pageview_id) AS page_rank
    FROM website_pageviews
)
SELECT
    page_rank,
    pageview_url,
    COUNT(DISTINCT website_session_id) AS sessions_reached
FROM page_flow
GROUP BY page_rank, pageview_url
ORDER BY page_rank, sessions_reached DESC;



-- Repeat vs New customer analysis
CREATE VIEW REPEAT_VS_NEW AS
SELECT 
CASE 
WHEN is_repeat_session=0 THEN 'New'
WHEN is_repeat_session = 1 THEN 'Repeat' 
END AS `Customer Type`,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
 ROUND(SUM(orders.price_usd),2) AS `Total Revenue`
FROM website_sessions 
LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
GROUP BY `Customer Type`;

-- Revenue per session-- 
CREATE VIEW REVENUE_BY_SESSION AS
SELECT
utm_source AS `Traffic Source`,
    ROUND(SUM(orders.price_usd),2) AS `Revenue Per Session`
FROM website_sessions
LEFT JOIN orders 
ON website_sessions.website_session_id = orders.website_session_id GROUP BY utm_source;





