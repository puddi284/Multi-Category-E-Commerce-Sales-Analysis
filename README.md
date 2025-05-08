<p align="center">
  <img src="thumbnail.png" alt="SQL E-Commerce Banner" width="100%">
</p>

# 🛒 Multi-Category E-Commerce SQL Analysis

This project analyzes transaction data from a large multi-category online retail store over a 3-month period using SQL. The goal is to understand user behavior, identify top-performing products, and assess brand/category performance using structured queries.

---

## 🔍 Project Overview

The SQL script performs the following key analyses:

- Merge and clean raw data from October, November, and December
- Convert string timestamps into proper `DATETIME` format
- Identify top-selling products, categories, and brands
- Segment users using RFM (Recency, Frequency, Monetary) analysis
- Evaluate session-level conversion rates
- Determine dominant brands within each product category
- Count unique buyers and compute average product prices
- Build query-ready base tables and views

---

## 🖼 Sample Results

### 📦 Top-Selling Products

<img src="image/top_products.png" alt="Top Products" width="600">

### 🧠 RFM Segmentation

<img src="image/rfm_table.png" alt="RFM Table" width="600">

### 🏷️ Brand by Category

<img src="image/brand_by_category.png" alt="Brand by Category" width="600">

### 🔁 Session Conversion Rate

<img src="image/session_end.png" alt="Session Conversion Rate" width="400">

---

## 📁 Files Included

- `code.sql`: Main SQL script for all queries and transformations  
- `report.md`: Full analytical report with visuals and summaries  
- `thumbnail.png`: Repository banner  
- `image/`: Folder containing all visualizations used in the report  
- `data/`: Raw CSV files for Oct–Dec 2019

---

## ▶️ How to Use

1. Import the CSVs inside `/data` into your SQL database as tables:
   - `Ecommerce_oct`
   - `Ecommerce_nov`
   - `Ecommerce_dec`

2. Run the queries in `code.sql` step by step

3. Visualize results using query results or provided images

---

## 🛠 SQL Techniques Used

- `WITH` CTEs for modular logic
- `ROW_NUMBER()` for session and monthly ranking
- `DATEDIFF`, `DATENAME`, `DATEPART` for time manipulation
- Aggregations: `SUM()`, `AVG()`, `COUNT(DISTINCT)`
- Conditional logic: `CASE WHEN ...`
- `STUFF(...) FOR XML PATH('')` for string aggregation in legacy SQL Server

---

## 📬 Contact

For questions or collaboration:
- 📧 Email: buudiem284@gmail.com  
- 📞 Phone/Zalo: (+84) 812698938
