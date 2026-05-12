-- Display all customers
SELECT * FROM customers;

-- Customer account details
SELECT c.customer_name,
       a.account_type,
       a.balance
FROM customers c
JOIN accounts a
ON c.customer_id = a.customer_id;

-- Total balance by branch
SELECT b.branch_name,
       SUM(a.balance) AS total_balance
FROM branches b
JOIN accounts a
ON b.branch_id = a.branch_id
GROUP BY b.branch_name;

-- Transactions above 5000
SELECT *
FROM transactions
WHERE amount > 5000;

-- Loan details
SELECT c.customer_name,
       l.loan_amount,
       l.loan_type
FROM customers c
JOIN loans l
ON c.customer_id = l.customer_id;
