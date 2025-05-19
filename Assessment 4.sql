use adashi_staging;

WITH txn_stats AS (
  SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    COALESCE(AVG(s.confirmed_amount), 0) AS avg_txn_amount_kobo
  FROM
    users_customuser u
    LEFT JOIN savings_savingsaccount s 
      ON s.owner_id = u.id
  GROUP BY
    u.id, u.first_name, u.last_name, u.date_joined
)
SELECT
  customer_id,
  name,
  tenure_months,
  total_transactions,
  ROUND(
    CASE 
      WHEN tenure_months = 0 OR total_transactions = 0 THEN 0
      ELSE 
        (total_transactions / tenure_months) * 12 * ((avg_txn_amount_kobo / 100.0) * 0.001)
    END,
    2
  ) AS estimated_clv
FROM
  txn_stats
ORDER BY
  estimated_clv DESC
  ;
