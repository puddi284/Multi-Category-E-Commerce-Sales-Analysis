<p align="center">
  <img src="thumbnail.png" alt="SQL E-Commerce Banner" width="100%">
</p>

# 🛒 Multi-Category E-Commerce Sales Analysis (SQL)

This project analyzes transaction data from a large multi-category online retail store over a 3-month period using SQL. The goal is to understand user behavior, identify top-performing products, and assess brand/category performance using structured queries.

## 🔍 Project Overview

The SQL script performs the following analyses:

- Combine and clean raw data across October, November, and December
- Convert event timestamps into proper `DATETIME` format
- Identify top products, categories, and brands by revenue and units sold
- Analyze customer behavior through RFM segmentation
- Evaluate conversion rate based on session event sequences
- Determine brand dominance in product categories
- Count unique buyers and calculate average price per brand
- Create base tables/views for simplified analysis

## 📁 Files Included

- `ecommerce_sales_analysis.sql`: Main SQL script containing all data transformation and analysis queries.

## ▶️ How to Use

1. Import your CSV data for October–December into SQL tables named:
   - `Ecommerce_oct`
   - `Ecommerce_nov`
   - `Ecommerce_dec`

2. Execute the SQL script (`ecommerce_sales_analysis.sql`) in order. The script:
   - Merges monthly data
   - Converts event timestamps
   - Performs analytical queries

3. Review results using your SQL editor or export key query results to Excel, BI tools (e.g., Power BI, Tableau), or visual dashboards.

## 🛠️ SQL Features Used

- `WITH` CTEs for modular logic
- `ROW_NUMBER()` for ranking within groups
- `DATEDIFF`, `DATEPART`, `DATENAME` for time-based analysis
- `COUNT(DISTINCT ...)`, `SUM()`, `AVG()` for aggregations
- Conditional logic with `CASE`
- `STUFF(...) FOR XML PATH('')` for string aggregation (legacy compatibility)

## 📬 Contact

For questions or collaboration:
- 📧Email: buudiem284@gmail.com
- 📞Phone/Zalo: (+84) 812698938
