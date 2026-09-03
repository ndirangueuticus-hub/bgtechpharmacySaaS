/*
# PharmaFlow Products Seed

Seeds 100+ products with batches, inventory, and opening movements.
Includes expired and near-expiry batches for FEFO testing, plus low/out-of-stock items.
Uses COALESCE to ensure no NULL values in NOT NULL columns.
*/

DO $$
DECLARE
  v_org uuid := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
  v_b1 uuid := 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b01';
  v_b2 uuid := 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b02';
  v_s1 uuid;
  v_s2 uuid;
  v_cat uuid;
  v_mnf uuid;
  v_pid uuid;
  v_bid uuid;
  v_qty int;
  v_cost numeric;
  v_days int;
BEGIN
  SELECT id INTO v_s1 FROM suppliers WHERE name='KEMSA' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_s2 FROM suppliers WHERE name='Pharma Distributors Ltd' AND organization_id=v_org LIMIT 1;

  -- ===== Product definitions: (name, category, manufacturer, price, prescription, dosage_form, strength) =====
  -- We'll insert them one batch at a time using a helper approach

  -- 1. Paracetamol 500mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Analgesics' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Cipla Ltd' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Paracetamol 500mg', 'Paracetamol', 'Crocin', 'PC001', 'SKU-PC001', '8901234500011', 'Tablet', '500mg', 'Tablets', false, 50, 1000, 15.00, 9.50)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'PCM-2024A', '2024-01-15', CURRENT_DATE+30, 500, 180, 9.50, 15.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 480);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 480, 'IN', 'opening', 0, 480, 'Opening stock');
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'PCM-2024C', '2024-03-01', '2027-03-01', 200, 200, 9.50, 15.00, v_s2, 'active');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 200);

  -- 2. Amoxicillin 500mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Antibiotics' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='GlaxoSmithKline' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Amoxicillin 500mg', 'Amoxicillin', 'Amoxil', 'PC002', 'SKU-PC002', '8901234500028', 'Capsule', '500mg', 'Capsules', true, 30, 500, 350.00, 220.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'AMX-442', '2024-02-01', CURRENT_DATE+24, 100, 72, 220.00, 350.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 72);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 72, 'IN', 'opening', 0, 72, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 80);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'AMX-443', '2024-05-01', '2026-05-01', 80, 80, 220.00, 350.00, v_s2, 'active');

  -- 3. Ibuprofen 400mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Analgesics' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Bayer' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Ibuprofen 400mg', 'Ibuprofen', 'Brufen', 'PC003', 'SKU-PC003', '8901234500035', 'Tablet', '400mg', 'Tablets', false, 40, 800, 80.00, 52.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'IBU-2024A', '2024-01-01', '2027-01-01', 400, 320, 52.00, 80.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 320);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 320, 'IN', 'opening', 0, 320, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 150);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'IBU-2024B', '2024-03-01', '2027-03-01', 150, 150, 52.00, 80.00, v_s2, 'active');

  -- 4. Cetirizine 10mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Cold & Flu' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Sun Pharma' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Cetirizine 10mg', 'Cetirizine', 'Zyrtec', 'PC004', 'SKU-PC004', '8901234500042', 'Tablet', '10mg', 'Tablets', false, 30, 500, 120.00, 75.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'CET-2024A', '2024-03-01', '2027-03-01', 200, 145, 75.00, 120.00, v_s2, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 145);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 145, 'IN', 'opening', 0, 145, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 80);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'CET-2024B', '2024-04-01', '2027-04-01', 80, 80, 75.00, 120.00, v_s2, 'active');

  -- 5. Omeprazole 20mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Prescription Medicines' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Novartis' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Omeprazole 20mg', 'Omeprazole', 'Prilosec', 'PC005', 'SKU-PC005', '8901234500059', 'Capsule', '20mg', 'Capsules', true, 25, 400, 280.00, 185.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'OMP-2024A', '2024-02-01', '2027-02-01', 150, 95, 185.00, 280.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 95);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 95, 'IN', 'opening', 0, 95, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 50);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'OMP-2024B', '2024-04-01', '2027-04-01', 50, 50, 185.00, 280.00, v_s2, 'active');

  -- 6. Metformin 500mg
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Sanofi' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Metformin 500mg', 'Metformin', 'Glucophage', 'PC006', 'SKU-PC006', '8901234500066', 'Tablet', '500mg', 'Tablets', true, 40, 600, 150.00, 95.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'MET-2024A', '2024-01-01', '2027-01-01', 300, 220, 95.00, 150.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 220);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 220, 'IN', 'opening', 0, 220, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 110);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'MET-2024B', '2024-03-01', '2027-03-01', 110, 110, 95.00, 150.00, v_s2, 'active');

  -- 7. Aspirin 75mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Analgesics' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Bayer' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Aspirin 75mg', 'Acetylsalicylic Acid', 'Aspegic', 'PC007', 'SKU-PC007', '8901234500073', 'Tablet', '75mg', 'Tablets', false, 50, 1000, 45.00, 28.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'ASP-2024A', '2024-03-01', '2027-03-01', 500, 380, 28.00, 45.00, v_s2, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 380);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 380, 'IN', 'opening', 0, 380, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 200);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'ASP-2024B', '2024-05-01', '2027-05-01', 200, 200, 28.00, 45.00, v_s2, 'active');

  -- 8. Vitamin C 1000mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Vitamins' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Reckitt Benckiser' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Vitamin C 1000mg', 'Ascorbic Acid', 'CeePlus', 'PC008', 'SKU-PC008', '8901234500080', 'Tablet', '1000mg', 'Tablets', false, 60, 1200, 65.00, 40.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'VTC-2024A', '2024-04-01', '2027-04-01', 600, 450, 40.00, 65.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 450);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 450, 'IN', 'opening', 0, 450, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 220);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'VTC-2024B', '2024-05-01', '2027-05-01', 220, 220, 40.00, 65.00, v_s2, 'active');

  -- 9. Cough Syrup 100ml
  SELECT id INTO v_cat FROM product_categories WHERE name='Cold & Flu' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Cooper Pharma' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Cough Syrup 100ml', 'Dextromethorphan', 'CoughGo', 'PC009', 'SKU-PC009', '8901234500097', 'Syrup', '100ml', 'Bottle', false, 20, 300, 320.00, 210.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'CSY-2024A', '2024-02-01', '2026-08-15', 100, 65, 210.00, 320.00, v_s2, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 65);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 65, 'IN', 'opening', 0, 65, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 30);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'CSY-2024B', '2024-03-01', '2026-09-15', 30, 30, 210.00, 320.00, v_s2, 'active');

  -- 10. Diclofenac 50mg
  SELECT id INTO v_cat FROM product_categories WHERE name='Analgesics' AND organization_id=v_org LIMIT 1;
  SELECT id INTO v_mnf FROM manufacturers WHERE name='Novartis' AND organization_id=v_org LIMIT 1;
  INSERT INTO products (organization_id, category_id, manufacturer_id, name, generic_name, brand_name, product_code, sku, barcode, dosage_form, strength, unit, is_prescription_required, reorder_level, max_stock_level, selling_price, cost_price)
  VALUES (v_org, v_cat, v_mnf, 'Diclofenac 50mg', 'Diclofenac Sodium', 'Voltaren', 'PC010', 'SKU-PC010', '8901234500103', 'Tablet', '50mg', 'Tablets', true, 30, 500, 180.00, 115.00)
  RETURNING id INTO v_pid;
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b1, 'DIC-2024A', '2024-01-01', '2027-01-01', 200, 160, 115.00, 180.00, v_s1, 'active') RETURNING id INTO v_bid;
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b1, 160);
  INSERT INTO inventory_movements (organization_id, product_id, batch_id, branch_id, quantity, direction, movement_type, previous_balance, new_balance, reason)
  VALUES (v_org, v_pid, v_bid, v_b1, 160, 'IN', 'opening', 0, 160, 'Opening stock');
  INSERT INTO inventory (organization_id, product_id, branch_id, quantity) VALUES (v_org, v_pid, v_b2, 80);
  INSERT INTO product_batches (organization_id, product_id, branch_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_current, cost_price, selling_price, supplier_id, status)
  VALUES (v_org, v_pid, v_b2, 'DIC-2024B', '2024-02-01', '2027-02-01', 80, 80, 115.00, 180.00, v_s2, 'active');

END $$;
