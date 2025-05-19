use adashi_staging;

-- First, identify customers with at least one funded savings and one funded investment plan
WITH customer_plan_counts AS (
  SELECT
    p.owner_id,
    -- Count distinct funded savings plans
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) AS savings_count,
    -- Count distinct funded investment plans
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) AS investment_count
  FROM
    plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
  WHERE
    s.confirmed_amount > 0 -- Funded plans only
  GROUP BY
    p.owner_id
  HAVING
    -- Must have at least 1 of each type
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) >= 1
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) >= 1
),

-- Then, calculate total confirmed deposits per customer
customer_deposits AS (
  SELECT
    owner_id,
    ROUND(SUM(confirmed_amount) / 100.0, 2) AS total_deposits -- Convert from kobo and format
  FROM
    savings_savingsaccount
  GROUP BY
    owner_id
)

-- Final output with user names and counts
SELECT
  c.owner_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,
  c.savings_count,
  c.investment_count,
  COALESCE(d.total_deposits, 0) AS total_deposits
FROM
  customer_plan_counts c
  JOIN users_customuser u ON u.id = c.owner_id
  LEFT JOIN customer_deposits d ON d.owner_id = c.owner_id
ORDER BY
  total_deposits DESC
  ;

