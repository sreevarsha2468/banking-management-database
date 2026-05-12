INSERT INTO customers VALUES
(1, 'Rahul', '9876543210', 'rahul@gmail.com', 'Hyderabad'),
(2, 'Anjali', '9876543211', 'anjali@gmail.com', 'Chennai');

INSERT INTO branches VALUES
(101, 'Main Branch', 'Hyderabad', 'SBIN0001'),
(102, 'City Branch', 'Chennai', 'SBIN0002');

INSERT INTO accounts VALUES
(1001, 1, 101, 'Savings', 50000, '2026-01-10'),
(1002, 2, 102, 'Current', 75000, '2026-02-15');

INSERT INTO transactions VALUES
(1, 1001, 'Deposit', 10000, '2026-03-01'),
(2, 1002, 'Withdrawal', 5000, '2026-03-02');

INSERT INTO loans VALUES
(201, 1, 200000, 'Home Loan', 8.5);
