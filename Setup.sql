-- ============================================================
-- Banking Management Database System
-- Schema, sample data, views, stored procedures, and triggers
-- Author: Yaddula Sreevarsha
-- ============================================================

DROP DATABASE IF EXISTS banking_management;
CREATE DATABASE banking_management;
USE banking_management;

-- ------------------------------------------------------------
-- 1. CORE TABLES
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone         VARCHAR(15),
    address       VARCHAR(200),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT NOT NULL,
    account_type   ENUM('SAVINGS', 'CURRENT') NOT NULL DEFAULT 'SAVINGS',
    balance        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_balance_non_negative CHECK (balance >= 0)
);

CREATE TABLE transactions (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    account_id       INT NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER_IN', 'TRANSFER_OUT') NOT NULL,
    amount           DECIMAL(12,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks          VARCHAR(200),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE CASCADE
);

-- Audit table populated automatically by a trigger (advanced feature)
CREATE TABLE balance_audit_log (
    log_id        INT AUTO_INCREMENT PRIMARY KEY,
    account_id    INT NOT NULL,
    old_balance   DECIMAL(12,2),
    new_balance   DECIMAL(12,2),
    changed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 2. INDEXES (performance optimization for reporting queries)
-- ------------------------------------------------------------

CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);

-- ------------------------------------------------------------
-- 3. SAMPLE DATA
-- ------------------------------------------------------------

INSERT INTO customers (full_name, email, phone, address) VALUES
('Ananya Rao', 'ananya.rao@email.com', '9876543210', 'Hyderabad, Telangana'),
('Kiran Kumar', 'kiran.kumar@email.com', '9876543211', 'Bengaluru, Karnataka'),
('Divya Sharma', 'divya.sharma@email.com', '9876543212', 'Chennai, Tamil Nadu'),
('Rahul Verma', 'rahul.verma@email.com', '9876543213', 'Hyderabad, Telangana');

INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1, 'SAVINGS', 50000.00),
(2, 'CURRENT', 120000.00),
(3, 'SAVINGS', 75000.00),
(4, 'SAVINGS', 30000.00);

INSERT INTO transactions (account_id, transaction_type, amount, remarks) VALUES
(1, 'DEPOSIT', 10000.00, 'Salary credit'),
(1, 'WITHDRAWAL', 2000.00, 'ATM withdrawal'),
(2, 'DEPOSIT', 25000.00, 'Client payment'),
(3, 'WITHDRAWAL', 5000.00, 'Bill payment'),
(4, 'DEPOSIT', 8000.00, 'Cash deposit');

-- ------------------------------------------------------------
-- 4. VIEWS (advanced reporting layer)
-- ------------------------------------------------------------

-- View: customer account summary (join + aggregate)
CREATE VIEW customer_account_summary AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(a.account_id)         AS total_accounts,
    SUM(a.balance)              AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.full_name, c.email;

-- View: high value customers (balance above threshold)
CREATE VIEW high_value_customers AS
SELECT customer_id, full_name, total_balance
FROM customer_account_summary
WHERE total_balance >= 75000;

-- View: transaction history with customer context (multi-table join)
CREATE VIEW transaction_history_detailed AS
SELECT
    t.transaction_id,
    c.full_name,
    a.account_id,
    a.account_type,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    t.remarks
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY t.transaction_date DESC;

-- ------------------------------------------------------------
-- 5. STORED PROCEDURE (advanced: safe fund transfer with transaction control)
-- ------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE transfer_funds(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE from_balance DECIMAL(12,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT balance INTO from_balance
    FROM accounts WHERE account_id = p_from_account FOR UPDATE;

    IF from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance for transfer';
    END IF;

    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to_account;

    INSERT INTO transactions (account_id, transaction_type, amount, remarks)
    VALUES (p_from_account, 'TRANSFER_OUT', p_amount, CONCAT('Transfer to account ', p_to_account));

    INSERT INTO transactions (account_id, transaction_type, amount, remarks)
    VALUES (p_to_account, 'TRANSFER_IN', p_amount, CONCAT('Transfer from account ', p_from_account));

    COMMIT;
END //

DELIMITER ;

-- ------------------------------------------------------------
-- 6. TRIGGER (advanced: auto-log every balance change)
-- ------------------------------------------------------------

DELIMITER //

CREATE TRIGGER trg_balance_audit
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF OLD.balance <> NEW.balance THEN
        INSERT INTO balance_audit_log (account_id, old_balance, new_balance)
        VALUES (NEW.account_id, OLD.balance, NEW.balance);
    END IF;
END //

DELIMITER ;
