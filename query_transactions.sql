SELECT
    us_state,
    argmax(cat_id, amount) AS top_amount_cat_id,
    MAX(amount) AS max_amount
FROM homework3.transactions
GROUP BY us_state
ORDER BY us_state;