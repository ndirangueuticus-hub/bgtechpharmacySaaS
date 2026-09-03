/*
# PharmaFlow Demo Data Seed

Seeds the database with realistic demo data for a Kenyan pharmacy:
- 1 organization (MediCare Pharmacy Ltd)
- 2 branches (Nairobi CBD, Nyeri Town)
- 6 roles with permissions
- 12 product categories, 10 manufacturers, 8 suppliers
- 100+ products with batches, inventory, and opening movements
- Expired and near-expiry batches for FEFO testing
- Low-stock and out-of-stock products
- 8 expense categories + sample expenses
- 8 customers
- Organization settings + notifications
*/

-- ORGANIZATION
INSERT INTO organizations (id, name, legal_name, country, currency, timezone, tax_id, phone, email, address)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MediCare Pharmacy', 'MediCare Pharmacy Ltd', 'Kenya', 'KES', 'Africa/Nairobi', 'P051234567X', '+254 712 345 678', 'info@medicarepharmacy.co.ke', 'Moi Avenue, Nairobi, Kenya')
ON CONFLICT (id) DO NOTHING;

-- BRANCHES
INSERT INTO branches (id, organization_id, name, code, location, address, phone) VALUES
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Nairobi CBD', 'NBI-01', 'Nairobi', 'Moi Avenue, CBD, Nairobi', '+254 712 345 678'),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Nyeri Town', 'NYR-01', 'Nyeri', 'Kimathi Way, Nyeri', '+254 722 456 789')
ON CONFLICT (id) DO NOTHING;

-- ROLES
INSERT INTO roles (id, organization_id, name, description, is_system_role) VALUES
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Owner', 'Full system access', true),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c02', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Pharmacist', 'Dispensing and sales', true),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cashier', 'POS transactions', true),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c04', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Inventory Manager', 'Stock management', true),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c05', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Accountant', 'Financial management', true),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c06', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Auditor', 'Read-only audit access', true)
ON CONFLICT (id) DO NOTHING;

-- ROLE PERMISSIONS
INSERT INTO role_permissions (role_id, permission_id) SELECT 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', id FROM permissions ON CONFLICT DO NOTHING;
INSERT INTO role_permissions (role_id, permission_id) SELECT 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c02', id FROM permissions WHERE code IN ('sales.create','sales.view','inventory.view','products.view','customers.view','customers.manage','prescriptions.manage','prescriptions.view','notifications.view') ON CONFLICT DO NOTHING;
INSERT INTO role_permissions (role_id, permission_id) SELECT 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', id FROM permissions WHERE code IN ('sales.create','sales.view','products.view','customers.view','notifications.view') ON CONFLICT DO NOTHING;
INSERT INTO role_permissions (role_id, permission_id) SELECT 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c04', id FROM permissions WHERE code IN ('inventory.view','inventory.adjust','inventory.transfer','inventory.stockcount','products.view','products.create','products.edit','purchases.view','purchases.receive','suppliers.view','notifications.view') ON CONFLICT DO NOTHING;
INSERT INTO role_permissions (role_id, permission_id) SELECT 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c05', id FROM permissions WHERE code IN ('finance.view','finance.create_expense','finance.approve_expense','sales.view','reports.view','notifications.view') ON CONFLICT DO NOTHING;
INSERT INTO role_permissions (role_id, permission_id) SELECT 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c06', id FROM permissions WHERE code IN ('audit.view','reports.view','sales.view','inventory.view','products.view','finance.view','users.view','notifications.view') ON CONFLICT DO NOTHING;

-- CATEGORIES
INSERT INTO product_categories (organization_id, name, description) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Prescription Medicines', 'Medicines requiring a prescription'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'OTC Medicines', 'Over-the-counter medicines'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Antibiotics', 'Antibacterial medications'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Analgesics', 'Pain relief medications'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Vitamins', 'Vitamin and mineral supplements'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Supplements', 'Dietary and nutritional supplements'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Medical Devices', 'Medical equipment and devices'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cosmetics', 'Beauty and skincare products'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Personal Care', 'Personal hygiene products'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Baby Products', 'Baby care products'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Antiseptics', 'Antiseptic and disinfectant products'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cold & Flu', 'Cold and flu remedies')
ON CONFLICT DO NOTHING;

-- MANUFACTURERS
INSERT INTO manufacturers (organization_id, name, country, contact_phone, contact_email) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'GlaxoSmithKline', 'UK', '+44 20 8047 5000', 'info@gsk.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cipla Ltd', 'India', '+91 22 2482 6000', 'info@cipla.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Novartis', 'Switzerland', '+41 61 324 1111', 'info@novartis.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Pfizer', 'USA', '+1 212 733 2323', 'info@pfizer.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bayer', 'Germany', '+49 214 30 1', 'info@bayer.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sanofi', 'France', '+33 1 53 77 40 00', 'info@sanofi.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sun Pharma', 'India', '+91 22 4324 4324', 'info@sunpharma.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Reckitt Benckiser', 'UK', '+44 1753 217800', 'info@rb.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Johnson & Johnson', 'USA', '+1 732 524 0350', 'info@jnj.com'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cooper Pharma', 'Kenya', '+254 20 555 1234', 'info@cooperpharma.co.ke')
ON CONFLICT DO NOTHING;

-- SUPPLIERS
INSERT INTO suppliers (organization_id, name, contact_person, phone, email, address, tax_id, payment_terms, credit_limit, outstanding_balance, status) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'KEMSA', 'James Mwangi', '+254 733 111 222', 'orders@kemsa.co.ke', 'Industrial Area, Nairobi', 'P05KEMSA001', 'Net 30', 500000, 125000, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Mission for Essential Drugs', 'Grace Wanjiru', '+254 711 333 444', 'info@meds.or.ke', 'Westlands, Nairobi', 'P05MEDS002', 'Net 15', 200000, 45000, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Pharma Distributors Ltd', 'Peter Kamau', '+254 722 555 666', 'sales@pharmadist.co.ke', 'Mombasa Road, Nairobi', 'P05PDL003', 'Net 30', 300000, 78000, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Goodlife Pharmacy Supply', 'Mary Atieno', '+254 733 777 888', 'info@goodlife.co.ke', 'Kilimani, Nairobi', 'P05GLP004', 'Cash on Delivery', 100000, 0, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Surge Medical Supplies', 'David Otieno', '+254 711 999 000', 'orders@surge.co.ke', 'Enterprise Road, Nairobi', 'P05SMS005', 'Net 45', 250000, 92000, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Maisha Pharmaceuticals', 'Sarah Njoki', '+254 722 111 333', 'info@maishapharma.co.ke', 'Riverside Drive, Nairobi', 'P05MP006', 'Net 30', 150000, 32000, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'HealthFirst Distributors', 'Daniel Kiprop', '+254 733 444 555', 'sales@healthfirst.co.ke', 'Thika Road, Nairobi', 'P05HFD007', 'Net 15', 180000, 15000, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Nairobi Pharmaceutical House', 'Faith Wambui', '+254 711 666 777', 'info@nph.co.ke', 'Ngara, Nairobi', 'P05NPH008', 'Cash', 50000, 0, 'active')
ON CONFLICT DO NOTHING;

-- EXPENSE CATEGORIES
INSERT INTO expense_categories (organization_id, name, description) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Rent', 'Shop/office rent'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Salaries', 'Staff salaries and wages'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Utilities', 'Electricity, water, gas'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Transport', 'Transport and logistics'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Internet', 'Internet and communication'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Maintenance', 'Equipment and premises maintenance'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Licenses', 'Business licenses and permits'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Marketing', 'Advertising and promotions'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Other', 'Miscellaneous expenses')
ON CONFLICT DO NOTHING;

-- SETTINGS
INSERT INTO settings (organization_id, key, value, category) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'expiry_warning_days', '30', 'inventory'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'expiry_critical_days', '7', 'inventory'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'default_reorder_level', '20', 'inventory'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'allow_negative_inventory', 'false', 'inventory'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'allow_expired_sale', 'false', 'inventory'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'expense_approval_threshold', '10000', 'finance'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'receipt_footer', 'Thank you for shopping at MediCare Pharmacy. Get well soon!', 'sales'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'receipt_header', 'MediCare Pharmacy Ltd | Moi Avenue, Nairobi | +254 712 345 678', 'sales'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'default_tax_rate', '0', 'sales'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'payment_methods', 'cash,mobile_money,card,bank,credit', 'sales')
ON CONFLICT (organization_id, key) DO NOTHING;

-- CUSTOMERS
INSERT INTO customers (organization_id, customer_number, name, phone, email, address, outstanding_balance, status) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-001', 'John Kamau', '+254 722 123 456', 'john.kamau@gmail.com', 'Westlands, Nairobi', 0, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-002', 'Mary Wanjiru', '+254 733 234 567', 'mary.wanjiru@gmail.com', 'Karen, Nairobi', 2500, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-003', 'Peter Mwangi', '+254 711 345 678', 'peter.mwangi@yahoo.com', 'Embakasi, Nairobi', 0, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-004', 'Grace Atieno', '+254 722 456 789', 'grace.atieno@gmail.com', 'Kasarani, Nairobi', 1800, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-005', 'Daniel Kiprop', '+254 733 567 890', 'daniel.kiprop@gmail.com', 'Ruaka, Nairobi', 0, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-006', 'Faith Wambui', '+254 711 678 901', 'faith.wambui@gmail.com', 'Nyeri Town', 0, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-007', 'Samuel Otieno', '+254 722 789 012', 'samuel.otieno@yahoo.com', 'Nyeri Town', 3200, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CUST-008', 'Esther Njoki', '+254 733 890 123', 'esther.njoki@gmail.com', 'Nairobi CBD', 0, 'active')
ON CONFLICT DO NOTHING;

-- NOTIFICATIONS
INSERT INTO notifications (organization_id, title, message, type, severity) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Low Stock Alert', 'Cough Syrup 100ml is below reorder level (8 units remaining)', 'low_stock', 'warning'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Expiry Warning', '12 units of Aspirin 75mg Batch ASP-2023EXP expire in 5 days', 'expiry', 'critical'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Expired Stock', '15 units of Paracetamol 500mg Batch PCM-2023OLD have expired', 'expired', 'critical'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Supplier Payment Due', 'KEMSA outstanding balance: KES 125,000', 'supplier_payment', 'warning'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Out of Stock', 'Nebulizer Kit is out of stock at Nairobi CBD branch', 'out_of_stock', 'critical')
ON CONFLICT DO NOTHING;
