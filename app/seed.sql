INSERT INTO Leases(tenant_name, unit_no, start_date, end_date, monthly_rent)
VALUES ('Alice Johnson','101', date('now','-200 day'), NULL, 1800.00),
       ('Brandon Lee','102', date('now','-120 day'), NULL, 1650.00);
INSERT INTO Charges(lease_id, due_date, amount, type) VALUES
  (1, date(strftime('%Y-%m-01','now')), 1800.00, 'rent'),
  (1, date(strftime('%Y-%m-01','now','-1 month')), 1800.00, 'rent'),
  (1, date('now','-10 day'), 75.00, 'late_fee'),
  (2, date(strftime('%Y-%m-01','now')), 1650.00, 'rent'),
  (2, date(strftime('%Y-%m-01','now','-1 month')), 1650.00, 'rent');
INSERT INTO Payments(lease_id, paid_date, amount, method) VALUES
  (1, date('now','-5 day'), 900.00, 'card'),
  (2, date('now','-2 day'), 1650.00, 'ach'),
  (2, date(strftime('%Y-%m-05','now','-1 month')), 1650.00, 'ach');


