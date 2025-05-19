use adashi_staging;

-- CTE to calculate how long each user has been active and how many transactions they’ve made
WITH customer_txns AS (
  SELECT
    u.id AS owner_id,
    COUNT(s.id) AS total_txns,
    -- Calculate months active (at least 1 month to avoid divide by zero)
    GREATEST(
      CEIL(DATEDIFF(CURDATE(), MIN(s.created_on)) / 30),
      1
    ) AS months_active
  FROM
    users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
  GROUP BY
    u.id
),

-- CTE to calculate average monthly transactions and categorize frequency
customer_freq AS (
  SELECT
    owner_id,
    total_txns,
    months_active,
    -- Guard against divide-by-zero
    CASE
      WHEN months_active = 0 THEN 0
      ELSE total_txns / months_active
    END AS avg_txn_per_month,
    CASE
      WHEN (total_txns / months_active) >= 10 THEN 'High Frequency'
      WHEN (total_txns / months_active) BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category
  FROM
    customer_txns
)

-- Final summary by frequency category
SELECT
  frequency_category,
  COUNT(owner_id) AS customer_count,
  ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM
  customer_freq
GROUP BY
  frequency_category
ORDER BY
  CASE frequency_category
    WHEN 'High Frequency' THEN 1
    WHEN 'Medium Frequency' THEN 2
    ELSE 3
  END
  ;
