# DataAnalytics_Assesment
This repository contains mySQL solutions to the Cowrywise Data Analyst technical assessment. It includes SQL queries to answer business-driven questions, with an emphasis on financial behavior, customer segmentation, and retention analysis.


---

## ✅ Assessment Questions & Explanations

### **Question 1: High-Value Customers with Multiple Products**
Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.


**Approach:**
- Joined `plans_plan`, `savings_savingsaccount`, and `users_customuser`.
- Used `CASE` with `COUNT(DISTINCT ...)` to ensure we capture both plan types.
- Created a CTE to filter only users with both types of funded plans.
- Summed total `confirmed_amount` per user, converted from kobo to naira.
- Sorted results in descending order of total deposits.

**Challenge:** No major issues in this part. Ensured aggregation logic matched business goal of identifying cross-sell potential.

---

### **Question 2: Transaction Frequency Analysis**
Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
Task: Calculate the average number of transactions per customer per month and categorize them:
"High Frequency" (≥10 transactions/month)
"Medium Frequency" (3-9 transactions/month)
"Low Frequency" (≤2 transactions/month)


**Approach:**
- Calculated `months_active` using `DATEDIFF` and divided transaction count by months.
- Created logic to classify into `High`, `Medium`, or `Low Frequency`.
- Used a CTE to cleanly separate transaction logic and classification.
- Used `GREATEST(..., 1)` to avoid division by zero.

**Challenge:** The initial attempt used a non-existent `created_at` column in `savings_savingsaccount`. I reviewed the table schema and replaced it with a valid timestamp column `created_on`.

---

### **Question 3: Account Inactivity Alert**
Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .


**Approach:**
- Created a CTE `last_inflow` to get the latest of:
  - deposit date (from savings)
  - investment charge date
  - plan creation date (as fallback)
- Filtered plans where `DATEDIFF(CURDATE(), last_inflow_date) > 365`
- Used `GREATEST(...)` to find the most recent activity for each plan.
- Joined back with `plans_plan` to label as `Savings`, `Investment`, or `Other`.

**Challenge:** 
No major issues in this part.
---

### **Question 4: Customer Lifetime Value (CLV) Estimation**
Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
Order by estimated CLV from highest to lowest

**Approach:**
- Joined `users_customuser` with `savings_savingsaccount`.
- Calculated:
  - Tenure in months (using `TIMESTAMPDIFF`)
  - Total transaction count
  - Average transaction value (in kobo)
- CLV formula:
  \[
  \text{CLV} = \left(\frac{\text{transactions}}{\text{tenure months}}\right) \times 12 \times \left(\frac{\text{avg transaction (naira)}} \times \text{revenue factor (0.001)}\right)
  \]
- Used `ROUND(..., 2)` for cleaner results.
- Handled zero-tenure and zero-transaction users with `CASE` logic.

**Challenge:** Ensured financial values were converted properly (kobo → naira) and clarified the business use of a small revenue factor multiplier for scaled estimation.

---

## 💡 Final Notes

- All queries were written using MySQL and tested locally.
- I prioritized readability, scalability (e.g., use of CTEs), and error handling.
- All solutions include defensive programming to handle missing or null data.

