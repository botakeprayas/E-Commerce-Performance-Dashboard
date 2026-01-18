# E-Commerce-Performance-Dashboard
“This project is an end-to-end Business Intelligence & Analytics solution built using MySQL and Power BI on a real-world e-commerce dataset. The goal is to analyze revenue growth, refunds, product performance, and website funnel efficiency to generate actionable business insights.
The project demonstrates how raw transactional and web analytics data can be transformed into decision-ready dashboards using SQL for data modeling and Power BI for visualization..”

## BUSINESS PROBLEM STATEMENT
“The company wants to analyze sales performance, customer purchasing behavior, refund impact, and website funnel efficiency to increase revenue, reduce refunds, and improve conversion rate.”

## Business Wants to Know

Track overall revenue and growth trends

Understand refund impact on profitability

Identify high-performing and high-risk products

Analyze website conversion funnel (Sessions → Orders)

Evaluate traffic quality across marketing channels

## DATASET USED
[dataset](https://github.com/botakeprayas/E-Commerce-Performance-Dashboard/blob/main/archive.zip)

##  Tools & Technologies Used

MySQL – Data cleaning, transformation, analytics queries

Power BI – Data modeling, DAX measures, dashboards

SQL Views – Reusable analytics logic

CSV Files – Source data format

## Data Model & Relationships

orders → order_items (order_id)

order_items → order_item_refunds (order_item_id)

order_items → products (product_id)

website_sessions → orders (website_session_id)

website_sessions → website_pageviews (website_session_id)

## SQL Analysis Performed

The project includes advanced SQL analysis, such as:

Total Revenue, Orders, and Average Order Value (AOV)

Revenue loss due to refunds

Net revenue after refunds

Refund percentage by product

Monthly revenue and refund trends

Sessions → Orders conversion rate

Conversion rate by traffic source

Revenue per session

Reusable SQL views were created for metrics like net revenue and product performance.








