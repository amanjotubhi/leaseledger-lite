INSERT INTO Leases(tenant_name, unit_no, start_date, end_date, monthly_rent) VALUES
('Alice Johnson','101', ADD_MONTHS(TRUNC(SYSDATE), -6), NULL, 1800);
INSERT INTO Leases(tenant_name, unit_no, start_date, end_date, monthly_rent) VALUES
('Brandon Lee','102', ADD_MONTHS(TRUNC(SYSDATE), -4), NULL, 1650);
INSERT INTO Charges(lease_id, due_date, amount, type) VALUES (1, TRUNC(SYSDATE,'MM'), 1800, 'rent');
INSERT INTO Charges(lease_id, due_date, amount, type) VALUES (1, ADD_MONTHS(TRUNC(SYSDATE,'MM'), -1), 1800, 'rent');
INSERT INTO Charges(lease_id, due_date, amount, type) VALUES (1, SYSDATE - 10, 75, 'late_fee');
INSERT INTO Charges(lease_id, due_date, amount, type) VALUES (2, TRUNC(SYSDATE,'MM'), 1650, 'rent');
INSERT INTO Charges(lease_id, due_date, amount, type) VALUES (2, ADD_MONTHS(TRUNC(SYSDATE,'MM'), -1), 1650, 'rent');
INSERT INTO Payments(lease_id, paid_date, amount, method) VALUES (1, SYSDATE - 5, 900, 'card');
INSERT INTO Payments(lease_id, paid_date, amount, method) VALUES (2, SYSDATE - 2, 1650, 'ach');
INSERT INTO Payments(lease_id, paid_date, amount, method) VALUES (2, ADD_MONTHS(TRUNC(SYSDATE,'MM'), -1) + 5, 1650, 'ach');
COMMIT;


