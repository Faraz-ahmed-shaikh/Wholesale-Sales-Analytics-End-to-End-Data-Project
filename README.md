# 📦 Wholesale Sales Analytics – End-to-End Data Project (Python | SQL | Tableau)

## 📖 Overview
This project analyzes over **1 million transactions** from a UK-based wholesale retailer to understand revenue trends, customer behavior, product performance, return patterns, and geographic markets.

The goal was to transform raw transactional data into clear, actionable business insights using a complete analytics workflow:

**Python → PostgreSQL → Tableau → Business Insights**

---

## 📌 Business Problem

The company lacked clear visibility into:

- Seasonal revenue patterns  
- Customer retention and revenue concentration  
- Product performance and dead inventory  
- Return behavior and financial impact  
- Geographic performance differences  

This limited the company's ability to make informed decisions related to inventory planning, customer strategy, and operational efficiency.

---

## 📊 Key Metrics

| Metric | Value |
|--------|------|
| **Total Revenue** | ~£20.97M |
| **Units Sold** | 11.4M+ |
| **Registered Customers** | 5,939 |
| **Guest Orders** | 240K+ |
| **Average Order Value** | £523 |
| **Return Rate** | 9.3% |
| **Revenue Loss (Returns)** | 7.28% |
| **Time Period** | Dec 2009 – Dec 2011 |

---

## 🛠 Tools & Technologies

- **Python** — Pandas, NumPy, Matplotlib  
- **PostgreSQL** — Data modeling and SQL analysis  
- **Tableau** — Interactive dashboards  
- **Excel / CSV** — Data preparation and handling  

---

## 🔍 Project Workflow

### **1️⃣ Data Cleaning (Python)**

- Standardized column names and corrected data types  
- Handled missing values and inconsistencies  
- Flagged returns, cancellations, and non-product codes  
- Removed invalid records (corrupted pricing rows)  
- Created derived features such as:
  - `total_price`
  - `year`, `month`, `day`, `hour`

---

### **2️⃣ SQL Analysis (PostgreSQL)**

Performed structured analysis across key business areas:

- Revenue trends and seasonal patterns  
- Customer segmentation and repeat behavior  
- Product performance and dead SKU detection  
- Return trends and financial loss estimation  
- Geographic performance comparison  

---

### **3️⃣ Dashboard Development (Tableau)**

Developed **six business-focused dashboards**:

1. Executive KPI Overview  
2. Sales & Revenue Performance  
3. Geographic Market Insights  
4. Product Portfolio Performance  
5. Customer Behavior & Segmentation  
6. Returns & Operational Quality  

---

## 📈 Key Insights

### **Revenue**
- Strong seasonal peaks observed in **Q3–Q4**
- Peak buying hours: **10 AM – 3 PM**
- Business follows a **high-volume, low-margin** model

---

### **Customers**
- Top **20% of customers generate 77% of total revenue**
- Repeat purchase rate: **72%**
- High volume of guest orders limits customer tracking

---

### **Products**
- Low-cost decorative items dominate sales volume
- Multiple dead SKUs indicate inefficient inventory usage
- Fragile and electrical items drive higher return rates

---

### **Returns**
- Overall return rate: **9.3%**
- Revenue loss due to returns: **7.28%**
- Higher return rates observed in long-distance shipments

---

### **Geography**
- UK and nearby European markets dominate revenue
- Limited presence in distant international markets
- Higher return risk observed in long-transit regions

---

## 📌 Recommendations

- Optimize inventory before **Q4 peak demand**
- Reduce excess stock during **Q1 slowdown**
- Introduce loyalty programs for high-value customers
- Encourage guest users to register
- Improve packaging for fragile products
- Discontinue low-performing SKUs
- Expand strategically into stable European markets

---

## ⭐ Why This Project Matters

This project demonstrates the ability to:

- Work with **large real-world datasets (1M+ records)**
- Perform structured **data cleaning and transformation**
- Use **SQL to answer business-critical questions**
- Build **interactive dashboards** for stakeholders
- Translate raw data into **clear business strategies**

It reflects a **complete real-world data analytics workflow**, similar to what analysts perform in industry environments.

---

## 📎 Deliverables

- 📄 Final analysis report (PDF)  
- 📊 Tableau dashboards  
- 🗃 SQL queries and analysis scripts  
- 🧹 Cleaned dataset  
- 📑 Portfolio case study presentation  

---

## 📬 Contact

If you'd like to discuss this project or share feedback, feel free to connect with me on LinkedIn.
