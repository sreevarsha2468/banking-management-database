CREATE VIEW customer_account_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    a.account_id,
    a.account_type,
    a.balance
FROM customers c
JOIN accounts a
ON c.customer_id = a.customer_id;
