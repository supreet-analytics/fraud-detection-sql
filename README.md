# 💳 Fraud Detection in Bank Transactions (SQL Project)

This project focuses on detecting suspicious activities and patterns in bank transactions using structured SQL queries. The dataset simulates real-world banking data including transaction amounts, customer behavior, login attempts, devices, and merchant details.

## 📁 Dataset Fields
- `TransactionID`, `AccountID`, `TransactionAmount`,`NextTransactionDate`, `PreviousTransactionDate`, `TransactionType`
- `Location`, `DeviceID`, `IPAddress`, `MerchantID`, `Channel`
- `CustomerAge`, `CustomerOccupation`,`TransactionDuration`, `LoginAttempts`
-  `AccountBalance`

## 🔍 Key Questions Answered
- Most active customers and merchants
- Off-hours transactions (midnight to early morning)
- Customers with frequent failed login attempts
- Large time gaps between transactions (possible dormancy)
- Rapid repeat transactions to same merchant (possible fraud)
- IPs or Devices being reused frequently
- Locations where high transations are mostly done
- Elderly customers making high-value transactions
- Transactions with high fraud risk (using CASE logic)

## 🧠 Skills Demonstrated

- SQL joins (INNER JOIN, LEFT JOIN) to connect multiple tables or self-joins
- Common Table Expressions (CTEs) for better readability and step-wise logic building
- Temporary tables for intermediate data storage and manipulation
- Aggregations: COUNT, SUM, AVG, MIN, MAX
- Date and time manipulation using DATEDIFF, TIMESTAMPDIFF, and TIME functions
- Conditional logic with CASE WHEN for fraud flagging
- Filtering, sorting, and grouping (GROUP BY, ORDER BY, HAVING)

## 📌 Tools Used
- MySQL / SQL Workbench / DB Browser
- GitHub for version control
- Excel/CSV viewer (for manual dataset inspection)

## 📈 Output
The result includes risk flags, high-spending customers, peak hours, fraud-prone patterns — helping to proactively detect anomalies or fraud attempts.

---

> 💬 Feel free to clone this repo and try it with your own data. Contributions welcome!
