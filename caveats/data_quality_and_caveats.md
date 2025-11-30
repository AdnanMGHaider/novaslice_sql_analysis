# NovaSlice Pizza  
## Data quality and caveats

This document records assumptions, limitations, and data quality notes for the NovaSlice Pizza SQL analysis.  
It helps reviewers interpret the queries and results correctly.

---

## 1. Dataset origin and nature

1. The dataset represents transactional order data for a fictional pizza chain.  
2. Values are intended for analytics practice and do not represent real customers or revenue.  
3. The data was provided as flat CSV files and then imported into a relational model in SQL Server.

---

## 2. Structural assumptions

1. One row in orders represents one order placed by a customer at a specific date and time.  
2. One row in order_details represents one pizza line within an order. Quantity in this table indicates how many units of that pizza were included in the line.  
3. Each order can contain multiple order_details rows.  
4. Pizza prices are stored as a point in time snapshot in the pizzas table. The analysis assumes prices are constant for the full period of the dataset.  
5. The relationship between tables is

   1. customers to orders is one to many  
   2. orders to order_details is one to many  
   3. pizzas to order_details is one to many  
   4. pizza_types to pizzas is one to many  

---

## 3. Business rule assumptions

1. All monetary values are treated as a single currency. The currency symbol is not present in the raw data, so revenue is reported as generic units rather than a specific currency.  
2. Taxes, delivery fees, and discounts are not modelled separately. Revenue calculations use quantity multiplied by base pizza price only.  
3. Order status is present in the orders table, but the core analysis treats all rows as completed orders unless marked otherwise in a specific query.  
4. Customer segmentation thresholds in query nineteen such as total_spent greater than five hundred are illustrative and can be adjusted for different business contexts.

---

## 4. Data quality considerations

1. During inspection no duplicate primary keys were found for custid, order_id, pizza_id, or order_details_id.  
2. Null checks on key columns such as order_date, custid, pizza_id, and quantity did not show issues for this copy of the dataset.  
3. No negative quantities were present in order_details for the version used in this project.  
4. Email, phone, and postal_code fields are not validated against external sources. They are used only for simple joins and not for personal contact analysis.  
5. Time values in order_time are stored as character data and are cast to time for hour based analysis.

---

## 5. Modelling and analysis limitations

1. There is no separate calendar or date dimension. Time series analysis uses order_date directly from the orders table.  
2. Revenue is computed only at the pizza line level. Side items, drinks, coupons, or service charges are not included because they do not exist in the source files.  
3. The dataset covers a fixed historical period. Forecasting comments in the queries use cumulative trends only and do not involve advanced forecasting techniques.  
4. Customer behaviour analysis assumes that each custid consistently refers to the same customer across the full period.  
5. Insights are intended for portfolio demonstration. Any strategic recommendations drawn from this dataset should be treated as illustrative rather than as guidance for a live business.

---

## 6. How to interpret the results

1. All counts and revenue figures are accurate for the loaded dataset given the assumptions above.  
2. When presenting results to stakeholders, highlight that this is a teaching and portfolio project, and that thresholds and segments can be tuned if the dataset is adapted to a real environment.
