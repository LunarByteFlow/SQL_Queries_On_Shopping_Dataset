# 🛒 Online Shopping Database – SQL Implementation

## 🗒️ Overview

This project implements a relational database schema for an **Online Shopping System** using **Microsoft SQL Server**. It covers core e-commerce functionalities such as customer orders, payments, order items, product tracking, and analytics queries.

---

## 💡 Features

- 👥 **Customer Orders**  
  Track who purchased what and when, including country-level insights.

- 💰 **Payments & Discounts**  
  Apply conditional discounts and compute VAT-adjusted totals.

- 📦 **Order Items & Product Inventory**  
  Analyze quantities, top-selling products, and order frequency.

- 🌍 **Country-Level Analytics**  
  Analyze customer behavior by region (UK, Australia, USA, etc.).

- 🔁 **Dynamic Joins & Nested Queries**  
  Combine and filter across multiple tables to answer business questions.

- 📊 **Aggregation & Reporting**  
  Track most ordered products, top product categories, and order trends.

- ⚙️ **Stored Procedures**  
  Automate logic like applying bulk discounts on specific product orders.

- 💾 **Backup Support**  
  Use native SQL Server commands to create `.bak` file backups.

---

## 🧱 Database Entities

- `Customers`  
- `Orders`  
- `Order_items`  
- `Products`  
- `Payments`

---

## ⚙️ Setup Instructions

### 1. Create and Use the Database
```sql
CREATE DATABASE OnlineShoppingDB;
USE OnlineShoppingDB;
