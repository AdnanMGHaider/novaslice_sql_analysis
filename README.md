# NovaSlice Pizza SQL Analysis Project

## 1. Project Overview

NovaSlice Pizza is a fictional pizza chain operating across major Indian cities.  
This project delivers a complete SQL based analysis of one full cycle of transactional order data.  
The goal is to recreate the type of analytics work performed inside a real food delivery or quick service restaurant environment.

The project covers the complete workflow  
from data loading and schema creation  
to business question framing, stakeholder oriented queries,  
and a full breakdown of revenue, product mix, customer behaviour,  
and operational trends.

This analysis demonstrates core skills expected from an entry level data analyst  
including relational modelling, window functions, aggregation techniques,  
time based analysis, customer segmentation, and structured project presentation.

## 2. Business Context

NovaSlice Pizza operates a network of delivery focused outlets across multiple Indian cities.  
Management wants to better understand order behaviour, revenue drivers, customer patterns,  
and category level performance in order to support decisions related to menu strategy,  
staffing, marketing, pricing, and supply chain planning.

This analysis simulates a real internal analytics request where different stakeholders  
Operations, Finance, Marketing, Product, Customer Insights, and the Board  
ask specific questions about business performance.

All twenty SQL queries in this project are aligned with real business needs  
such as understanding order volume trends, identifying top selling pizzas,  
measuring customer loyalty, quantifying revenue contribution,  
and determining peak ordering periods.


## 3. Dataset Structure

The project uses five CSV files that represent the core transactional data for NovaSlice Pizza.  
These files were imported into SQL Server and modelled into a clean relational structure.

### Tables

**customers**  
Customer level information including name, contact details, city, and postal code.

**orders**  
One record per order placed by a customer. Contains order date, time, status, and customer reference.

**order_details**  
Line level detail for each order. Contains one row per pizza sold along with quantity.

**pizzas**  
Menu level information for each pizza including size and price.

**pizza_types**  
Descriptive attributes such as pizza category and ingredients.

The schema for these tables is defined in `schemas/schema.sql`.


## 4. Entity Relationship Diagram

The NovaSlice database follows a clean relational structure with five core tables.  
The ERD captures how customer information, orders, pizzas, and order line items interact.

### Relationship Summary

• One customer can place many orders  
• One order can contain many order line items  
• One pizza can appear in many order line items  
• One pizza type can define many pizzas

### Relationship Details

**customers → orders**  
One to many  
Each customer may have multiple orders, but each order belongs to a single customer.  
Key: customers.custid → orders.custid

**orders → order_details**  
One to many  
Each order can contain multiple pizza line items.  
Key: orders.order_id → order_details.order_id

**pizzas → order_details**  
One to many  
Each pizza can appear across many orders.  
Key: pizzas.pizza_id → order_details.pizza_id

**pizza_types → pizzas**  
One to many  
A pizza type defines category and ingredients for multiple pizzas.  
Key: pizza_types.pizza_type_id → pizzas.pizza_type_id

### ERD File

The full ERD diagram is stored in:

`erd/erd.png`


## 5. Business Questions Answered
[placeholder]

## 6. SQL Approach
[placeholder]

## 7. Key Insights
[placeholder]

## 8. Screenshots of Outputs
[placeholder]

## 9. How to Run This Project
[placeholder]

## 10. Caveats and Data Quality Notes
[placeholder]

## 11. Project Files
[placeholder]

## 12. About the Analyst
[placeholder]
