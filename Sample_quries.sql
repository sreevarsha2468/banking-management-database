-- ============================================================
-- Sample Reporting Queries — Banking Management Database System
-- Run these after setup.sql to see the system in action
-- ============================================================

USE banking_management;

-- 1. View all customers with their total balance across accounts
SELECT * FROM customer_account_summary;

-- 2. View only high-value customers (balance >= 75,000)
SELECT * FROM high_value_customers;

-- 3. Full transaction history with customer + account context
SELECT * FROM transaction_history_detailed;

-- 4. Aggregate: total bank-wide balance by account type
SELECT account_type, COUNT(*) AS num_accounts, SUM(balance) AS total_balance
FROM accounts
GROUP BY account_type;

-- 5. Use the stored procedure to transfer funds between two accounts
CALL transfer_funds(2, 4, 15000.00);

-- 6. Confirm balances updated correctly after transfer
SELECT account_id, customer_id, balance FROM accounts;

-- 7. Confirm the trigger logged the balance change automatically
SELECT * FROM balance_audit_log;

-- 8. Confirm the transfer created matching TRANSFER_OUT / TRANSFER_IN records
SELECT * FROM transactions WHERE transaction_type IN ('TRANSFER_OUT', 'TRANSFER_IN');
