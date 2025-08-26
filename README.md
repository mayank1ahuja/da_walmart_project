![Project Head](https://github.com/mayank1ahuja/da_walmart_project/blob/aeab5d930236083532ba9ae8064193d22bc9de12/header.png)
<h2 align="center">🛍️✨Retail Analytics with SQL & Python — A Walmart Case Study in Data-Driven Insight✨🛍️ </h2>


## 📑 Project Overview

This repository presents an end-to-end SQL + Python data analysis pipeline applied to Walmart sales data. The workflow begins with data cleaning and exploration in Python, transitions into SQL-driven business problem solving, and culminates in a set of actionable insights about retail performance.

The goal is twofold:
1. To demonstrate practical fluency in both Python and SQL for analytics.
2. To provide a portfolio artifact that communicates correctness, reasoning, and professional polish.

What distinguishes this project is not only the sequence of operations but also the deliberate explanation of intent at each stage. Every step, right from removing duplicates to constructing window functions is motivated by a clear analytical need. This transforms the repository from a collection of scripts into a structured demonstration of competence.

![Project Pipeline](https://github.com/mayank1ahuja/da_walmart_project/blob/7c2b93c1078fe0e0257aa2a8fb476da40a73ea09/project%20pipeline.png)


## 📚 Project Steps

### 1. Environment Setup   
The analysis is conducted within a Jupyter Notebook environment, supported by Python 3.8+ and PostgreSQL as the relational database. Key libraries include:
- *pandas* for tabular data manipulation,
- *sqlalchemy* for managing database connections, and
- *psycopg2* as the PostgreSQL adapter.

This stack ensures that exploratory work can proceed flexibly in Python, while more complex aggregations and business problems are expressed through SQL in a performant database context.

### 2. Kaggle API Setup
To keep data access reproducible the project relies on the Kaggle API. Generate an API token from your [Kaggle](https://www.kaggle.com/) account settings and place the resulting kaggle.json in your local .kaggle/ directory. With credentials configured, datasets can be fetched directly into the project with a single command:
```bash
kaggle datasets download -d <dataset-path>
```

### 3. Downloading the Walmart Dataset
The analysis centers on Walmart sales data hosted on Kaggle:
- *Dataset*: https://www.kaggle.com/najir0123/walmart-10k-sales-datasets

![Dataset](https://github.com/mayank1ahuja/da_walmart_project/blob/7c2b93c1078fe0e0257aa2a8fb476da40a73ea09/walmart%20dataset.png)

The dataset was retrieved directly from Kaggle and placed into a dedicated data/ directory within the repository. Housing raw inputs under data/ gives the workflow a single, stable anchor point and preserves a clean, discoverable project structure.

### 4. Importing Dependencies 
The notebook begins by importing the necessary Python libraries:
```python
import pandas as pd
import psycopg2 
from sqlalchemy import create_engine
```
This step establishes the analytical environment. Pandas provides a versatile DataFrame abstraction for data cleaning, while SQLAlchemy and psycopg2 form the bridge between Python and PostgreSQL, allowing seamless movement of data across the two domains.

### 5. Loading and Inspecting the Dataset
The dataset is loaded from a CSV file:
```python
df = pd.read_csv('Walmart.csv')
df.shape
```
At this stage, the primary objective is verification i.e. confirming that the dataset has been ingested correctly and establishing its raw dimensions. This step provides an initial sense of scale, which informs expectations about cleaning operations to follow.

A preliminary look at the first rows (**df.head()**) reinforces this verification by revealing the raw form of columns, values, and delimiters. Together, these early checks ensure that the dataset is both accessible and interpretable before deeper transformations begin.
```python
df.head()
```
![df.head](https://github.com/mayank1ahuja/da_walmart_project/blob/0d20916b91209e1c5bc2ca0ddb66b16a04b5f6c9/df.head().png)

### 6. Descriptive Profiling
The command **df.describe()** generates descriptive statistics of numerical features. This stage is less about immediate decision-making and more about building intuition: which values dominate, where the extremes lie, and whether anomalies exist that warrant intervention.
```python
df.describe()
```
![df.describe](https://github.com/mayank1ahuja/da_walmart_project/blob/0d20916b91209e1c5bc2ca0ddb66b16a04b5f6c9/df.describe().png)
Profiling at this stage establishes a baseline understanding of the dataset’s statistical distribution, allowing subsequent cleaning and SQL queries to be interpreted with greater confidence.

### 7. Duplicate Handling
Duplicate transactions are a silent threat to the validity of aggregations. Using **df.duplicated().sum()**, the notebook quantifies the problem; duplicates are then removed in place with **df.drop_duplicates(inplace=True)**.
```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```
The rationale here is straightforward: every row should correspond to a unique transaction. By eliminating redundancy, we prevent distortions in downstream calculations such as “total quantity sold” or “average rating.”

### 8. Managing Missing Values
Missingness is inspected through **df.isnull().sum()**, followed by the removal of incomplete rows (**df.dropna(inplace=True)**).
```python
df.isnull().sum()
df.dropna(inplace=True)
```
The approach here is deliberately strict: only complete records are retained. While imputation techniques could be considered, in the context of this project — where transactional precision is paramount — retaining only verified records is the more defensible choice.

### 9. Data Type Consistency 

**df.dtypes** and **df.info()** together confirm that each column aligns with its intended datatype. Where inconsistencies arise, transformations are applied — for instance, removing the **$** symbol from **unit_price** and casting the column to **float**.

These operations are less about immediate analysis and more about ensuring structural integrity. Correct data types are the foundation upon which reliable queries and calculations rest.

### 10. Final Validation and Export
A final listing of column names (**df.columns**) confirms schema readiness. At this point, the DataFrame represents a clean, coherent dataset.

The notebook then persists the data into PostgreSQL:
```python
df.to_sql("walmart", engine, if_exists="replace", index=False)
```
This step formalizes the dataset, allowing SQL queries to be executed against a standardized table. It marks the transition from data preparation to business problem solving.


## 🧮 Data Analysis & Business Problems 
With the dataset loaded into PostgreSQL, the analysis pivots to structured problem solving. Each SQL query addresses a specific business scenario, demonstrating the ability to articulate questions in business terms and translate them into precise SQL logic.

1. Payment Methods and Quantity Sold 
- This query enumerates payment methods, transaction counts, and quantities sold. It reveals how customers choose to pay and what volume flows through each channel.
```sql
SELECT 
	 payment_method,
	 COUNT(*) AS no_payments,
	 SUM(quantity) AS number_of_quantity_sold
FROM walmart
GROUP BY payment_method;
```

2. Highest-Rated Categories per Branch 
- Here, window functions are employed to rank categories within each branch by average rating, surfacing the top-rated category in each location.
```sql
SELECT * FROM 
(	
SELECT 
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;
```

3. Busiest Day per Branch 
- By counting transactions per day of the week and ranking them within each branch, this query identifies the busiest operational day branch-wise.
```sql
SELECT * FROM
(
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
		COUNT(*) AS no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;

```
4. Quantity Sold by Payment Method 
- This complements question 1 by calculating total quantities sold across payment methods, reinforcing insights into purchasing channels.
```sql
SELECT 
	 payment_method,
	 COUNT(*) AS number_of_payments,
	 SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

```
5. Category Ratings per City 
- Average, minimum, and maximum ratings are calculated for each category across cities. This provides granular insight into geographic differences in customer perception.
```sql
SELECT 
	city,
	category,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating
FROM walmart
GROUP BY 1, 2;
```
6. Profitability by Category �
- By computing revenue and profit (unit_price × quantity × profit_margin), this query highlights the most lucrative product categories.
```sql

SELECT 
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY 3 DESC;
```
7. Preferred Payment Method per Branch �
- A CTE combined with ranking identifies the most frequently used payment method in each branch.
```sql
WITH cte AS
(
SELECT 
	branch,
	payment_method,
	COUNT(*) AS total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1;
```
8. Sales Distribution by Time of Day 
- Transactions are categorized into Morning, Afternoon, and Evening shifts to reveal temporal patterns in purchasing behavior.
```sql
SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END shift,
	COUNT(*) AS number_of_invoices
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
```


## ✨ Results and Insights 

The combined analysis offers a multi-dimensional perspective on Walmart sales:
- **Payment Preferences**: Distinct variation across branches, informing branch-level strategy.
- **Peak Operating Days**: Clear busiest days per branch, critical for staffing and logistics.
- **Customer Satisfaction**: High-performing categories identified by ratings.
- **Profitability**: Categories that drive not just volume but margin.
- **Temporal Dynamics**: Evidence of shopping patterns segmented by time of day.
 
Together, these insights illustrate how transactional data can be transformed into actionable business intelligence.


## 🛠️ Requirements
- Python 3.8+
- PostgreSQL
- Python libraries: pandas, sqlalchemy, psycopg2

Install dependencies:
```bash
pip install pandas numpy sqlalchemy psycopg2
```


## 🗂️ Project Structure

```plaintext
|-- data/                  # Dataset 
|-- project.ipynb          # Jupyter Notebook for Python cleaning & exploration
|-- sql_project_p5.sql     # SQL queries for analysis
|-- README.md              # Documentation
```


## 📊 Results and Insights

- **Branch dynamics**: Certain branches show clear peak days; others have steady patterns. 
- **Category performance**: Some categories consistently dominate profit margins; others trail despite volume.
- **Payment behavior**: Branches differ in preferred payment methods — actionable for regional strategy.
- **Customer trends**: Ratings, transaction times, and quantities reveal behavioral nuances.


## 🚀 Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Additional data sources to enhance analysis depth.
- Automation of the data pipeline for real-time data ingestion and analysis.


## 📄 Acknowledgments

- **Data Source**: Kaggle’s Walmart Sales Dataset.
- **Inspiration**: Walmart’s business case studies on sales and supply chain optimization.
  
![Walmart Logo](https://github.com/mayank1ahuja/da_walmart_project/blob/7c2b93c1078fe0e0257aa2a8fb476da40a73ea09/walmart%20logo.jpg)
