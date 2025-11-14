SELECT
    state,
    argMax(category, amount) AS category_with_max_amount,
    max(amount) AS max_amount
FROM teta.transactions
GROUP BY state
ORDER BY state;
