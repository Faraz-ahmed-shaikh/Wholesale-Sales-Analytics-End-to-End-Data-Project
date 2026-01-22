# Wholesale-Sales-Analytics-End-to-End-Data-Project

## Overview
This project delivers a complete analytics workflow for a UK based wholesale retailer using the Online Retail II dataset. Over 1 million transactional records were cleaned, modeled, analyzed, and visualized to uncover trends in revenue, customer behavior, product performance, returns, and geographic markets.

The project covers the full pipeline:
Python → PostgreSQL → Tableau → Final Business Insights Report

## 📌 Business Problem : 

The company lacked centralized visibility into its operations, including:
Seasonal revenue behavior, Customer retention and revenue concentration, Product-level profitability and dead SKUs, Return patterns & financial loss and Geographic performance differences.

The objective was to transform raw data into meaningful insights and create dashboards that support better decisions in inventory, customer strategy, and operations.

## 📊 Key Metrics (Snapshot)
Metric	Value : 
Total Revenue	~£20.97M.
Units Sold	11.4M+.
Registered Customers	5,939.
Guest Orders	240K+.
Average Order Value	£523.
Return Rate	9.3%.
Revenue Lost to Returns	7.28%.
Time Period	Dec 2009 – Dec 2011.

## 🛠 Tools & Technologies

Python: Pandas, NumPy, Matplotlib
SQL: PostgreSQL (schema design, modeling, advanced analysis)
Tableau: 6 interactive dashboards
Excel/CSV: Raw data handling

## 🔍 Project Workflow

1. Data Cleaning (Python)
Standardized column names and data types.
Fixed customer IDs, product text, timestamps.
Flagged cancelled orders, returns, non-product codes.
Removed corrupted records (0.2%).
Enriched data with derived fields (total revenue, year/month/day/hour).

2. SQL Analysis (PostgreSQL)
Performed deep-dive analysis across five areas:
Revenue trends & seasonality.
Customer segmentation & repeat behavior.
SKU performance & inventory health.
Return patterns & financial impact.
Geographic performance.

4. Dashboarding (Tableau)
Six dashboards were created for different business functions:
Executive Overview.
Sales & Revenue Analysis.
Geographic Insights.
Product Performance.
Customer Segmentation.
Returns & Operational Quality.

## 📈 Key Insights Summary

Revenue : Strong seasonal peaks in Q3–Q4, Sales cluster between 10 AM – 3 PM, Low-margin, high-volume business model.

Customers : Top 20% generate 77% of revenue, Repeat purchase rate: 72% , Guest orders: 240K+, limiting personalization.

Products : Most units sold are low-cost décor items, Dead SKUs indicate inventory inefficiency, Fragile & electrical items drive high return rates.

Returns : Unit return rate is 9.3% , Revenue lost is 7.28% , High returns are from long-distance countries

Geography : UK + nearby Europe dominate revenue, Limited expansion outside Europe, Higher return rates in long-transit regions.

## 📌 Recommendations (Short)

Strengthen Q3–Q4 inventory; reduce Q1 stock,
Prioritize top high-value customers with loyalty programs,
Convert guest buyers via sign-up incentives,
Improve packaging & QC for fragile items,
Discontinue dead SKUs,
Expand softly into stable European markets before distant ones.

## 📎 Deliverables

Full analysis report (PDF) : 
6 Tableau dashboards,
SQL analysis scripts,
Cleaned dataset,
Portfolio case study (1–2 page summary).
