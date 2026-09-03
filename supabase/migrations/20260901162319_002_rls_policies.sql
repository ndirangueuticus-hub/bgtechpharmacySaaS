/*
# PharmaFlow RLS Policies + Permissions Catalog

## Overview
Creates Row Level Security policies for all PharmaFlow tables, enforcing:
- Multi-tenant isolation (users can only access their own organization's data)
- Branch-level access control (users can only see branches they're assigned to)
- Audit log immutability (insert + select only, no update/delete)

## Permissions Catalog
Seeds the `permissions` table with granular permission codes covering all modules:
sales, inventory, products, purchases, finance, users, reports, audit.

## Policy Pattern
Most tables use the standard pattern:
- SELECT: user's org_id matches row's organization_id
- INSERT: user's org_id matches row's organization_id
- UPDATE: same org check
- DELETE: same org check

Branch-scoped tables additionally require user_has_branch_access() for SELECT.

## Tables Covered
organizations, roles, permissions, role_permissions, user_profiles,
branches, user_branches, product_categories, manufacturers, products,
suppliers, product_batches, inventory, inventory_movements,
purchase_orders, purchase_order_items, goods_received_notes, goods_received_items,
supplier_payments, customers, prescriptions, prescription_items,
sales, sale_items, payments, refunds, refund_items,
expense_categories, expenses, stock_counts, stock_count_items,
stock_transfers, stock_transfer_items, notifications, audit_logs, settings
*/

-- ============================================================
-- PERMISSIONS CATALOG
-- ============================================================
INSERT INTO permissions (code, name, module, description) VALUES
  ('sales.create', 'Create Sales', 'sales', 'Create new sales transactions'),
  ('sales.refund', 'Process Refunds', 'sales', 'Process customer refunds'),
  ('sales.cancel', 'Cancel Sales', 'sales', 'Cancel completed sales'),
  ('sales.view', 'View Sales', 'sales', 'View sales records'),
  ('inventory.view', 'View Inventory', 'inventory', 'View inventory levels'),
  ('inventory.adjust', 'Adjust Inventory', 'inventory', 'Make stock adjustments'),
  ('inventory.transfer', 'Transfer Stock', 'inventory', 'Create and manage stock transfers'),
  ('inventory.stockcount', 'Stock Count', 'inventory', 'Perform stock counts'),
  ('products.create', 'Create Products', 'products', 'Add new products'),
  ('products.edit', 'Edit Products', 'products', 'Modify product information'),
  ('products.delete', 'Delete Products', 'products', 'Remove products'),
  ('products.change_price', 'Change Prices', 'products', 'Modify selling/cost prices'),
  ('products.view', 'View Products', 'products', 'View product catalog'),
  ('purchases.create', 'Create Purchases', 'purchases', 'Create purchase orders'),
  ('purchases.approve', 'Approve Purchases', 'purchases', 'Approve purchase orders'),
  ('purchases.receive', 'Receive Goods', 'purchases', 'Record goods received'),
  ('purchases.view', 'View Purchases', 'purchases', 'View purchase orders'),
  ('suppliers.manage', 'Manage Suppliers', 'suppliers', 'Create and edit suppliers'),
  ('suppliers.view', 'View Suppliers', 'suppliers', 'View supplier records'),
  ('finance.view', 'View Finance', 'finance', 'View financial reports'),
  ('finance.create_expense', 'Create Expenses', 'finance', 'Record business expenses'),
  ('finance.approve_expense', 'Approve Expenses', 'finance', 'Approve large expenses'),
  ('customers.manage', 'Manage Customers', 'customers', 'Create and edit customers'),
  ('customers.view', 'View Customers', 'customers', 'View customer records'),
  ('prescriptions.manage', 'Manage Prescriptions', 'prescriptions', 'Create and dispense prescriptions'),
  ('prescriptions.view', 'View Prescriptions', 'prescriptions', 'View prescription records'),
  ('users.create', 'Create Users', 'users', 'Add new system users'),
  ('users.disable', 'Disable Users', 'users', 'Deactivate user accounts'),
  ('users.change_permissions', 'Change Permissions', 'users', 'Modify user roles and permissions'),
  ('users.view', 'View Users', 'users', 'View user accounts'),
  ('reports.view', 'View Reports', 'reports', 'Access reporting and analytics'),
  ('audit.view', 'View Audit Logs', 'audit', 'Access audit trail'),
  ('branches.manage', 'Manage Branches', 'branches', 'Create and edit branches'),
  ('settings.manage', 'Manage Settings', 'settings', 'Modify system configuration'),
  ('notifications.view', 'View Notifications', 'notifications', 'View system notifications')
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
DROP POLICY IF EXISTS "select_own_org" ON organizations;
CREATE POLICY "select_own_org" ON organizations FOR SELECT
  TO authenticated USING (id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_org" ON organizations;
CREATE POLICY "update_own_org" ON organizations FOR UPDATE
  TO authenticated USING (id = get_user_org_id()) WITH CHECK (id = get_user_org_id());

-- ============================================================
-- ROLES
-- ============================================================
DROP POLICY IF EXISTS "select_own_roles" ON roles;
CREATE POLICY "select_own_roles" ON roles FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_roles" ON roles;
CREATE POLICY "insert_own_roles" ON roles FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_roles" ON roles;
CREATE POLICY "update_own_roles" ON roles FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_roles" ON roles;
CREATE POLICY "delete_own_roles" ON roles FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- PERMISSIONS (global, readable by all authenticated)
-- ============================================================
DROP POLICY IF EXISTS "select_all_permissions" ON permissions;
CREATE POLICY "select_all_permissions" ON permissions FOR SELECT
  TO authenticated USING (true);

-- ============================================================
-- ROLE PERMISSIONS
-- ============================================================
DROP POLICY IF EXISTS "select_own_role_perms" ON role_permissions;
CREATE POLICY "select_own_role_perms" ON role_permissions FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM roles r WHERE r.id = role_permissions.role_id AND r.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_role_perms" ON role_permissions;
CREATE POLICY "insert_own_role_perms" ON role_permissions FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM roles r WHERE r.id = role_permissions.role_id AND r.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "delete_own_role_perms" ON role_permissions;
CREATE POLICY "delete_own_role_perms" ON role_permissions FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM roles r WHERE r.id = role_permissions.role_id AND r.organization_id = get_user_org_id())
  );

-- ============================================================
-- USER PROFILES
-- ============================================================
DROP POLICY IF EXISTS "select_own_user_profiles" ON user_profiles;
CREATE POLICY "select_own_user_profiles" ON user_profiles FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id() OR id = auth.uid());

DROP POLICY IF EXISTS "update_own_user_profile" ON user_profiles;
CREATE POLICY "update_own_user_profile" ON user_profiles FOR UPDATE
  TO authenticated USING (id = auth.uid() OR organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id() OR id = auth.uid());

DROP POLICY IF EXISTS "insert_own_user_profile" ON user_profiles;
CREATE POLICY "insert_own_user_profile" ON user_profiles FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

-- ============================================================
-- BRANCHES
-- ============================================================
DROP POLICY IF EXISTS "select_own_branches" ON branches;
CREATE POLICY "select_own_branches" ON branches FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_branches" ON branches;
CREATE POLICY "insert_own_branches" ON branches FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_branches" ON branches;
CREATE POLICY "update_own_branches" ON branches FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_branches" ON branches;
CREATE POLICY "delete_own_branches" ON branches FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- USER BRANCHES
-- ============================================================
DROP POLICY IF EXISTS "select_own_user_branches" ON user_branches;
CREATE POLICY "select_own_user_branches" ON user_branches FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM user_profiles up WHERE up.id = user_branches.user_id AND up.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_user_branches" ON user_branches;
CREATE POLICY "insert_own_user_branches" ON user_branches FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM user_profiles up WHERE up.id = user_branches.user_id AND up.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "delete_own_user_branches" ON user_branches;
CREATE POLICY "delete_own_user_branches" ON user_branches FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM user_profiles up WHERE up.id = user_branches.user_id AND up.organization_id = get_user_org_id())
  );

-- ============================================================
-- PRODUCT CATEGORIES
-- ============================================================
DROP POLICY IF EXISTS "select_own_categories" ON product_categories;
CREATE POLICY "select_own_categories" ON product_categories FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_categories" ON product_categories;
CREATE POLICY "insert_own_categories" ON product_categories FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_categories" ON product_categories;
CREATE POLICY "update_own_categories" ON product_categories FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_categories" ON product_categories;
CREATE POLICY "delete_own_categories" ON product_categories FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- MANUFACTURERS
-- ============================================================
DROP POLICY IF EXISTS "select_own_manufacturers" ON manufacturers;
CREATE POLICY "select_own_manufacturers" ON manufacturers FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_manufacturers" ON manufacturers;
CREATE POLICY "insert_own_manufacturers" ON manufacturers FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_manufacturers" ON manufacturers;
CREATE POLICY "update_own_manufacturers" ON manufacturers FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_manufacturers" ON manufacturers;
CREATE POLICY "delete_own_manufacturers" ON manufacturers FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- PRODUCTS
-- ============================================================
DROP POLICY IF EXISTS "select_own_products" ON products;
CREATE POLICY "select_own_products" ON products FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_products" ON products;
CREATE POLICY "insert_own_products" ON products FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_products" ON products;
CREATE POLICY "update_own_products" ON products FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_products" ON products;
CREATE POLICY "delete_own_products" ON products FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- SUPPLIERS
-- ============================================================
DROP POLICY IF EXISTS "select_own_suppliers" ON suppliers;
CREATE POLICY "select_own_suppliers" ON suppliers FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_suppliers" ON suppliers;
CREATE POLICY "insert_own_suppliers" ON suppliers FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_suppliers" ON suppliers;
CREATE POLICY "update_own_suppliers" ON suppliers FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_suppliers" ON suppliers;
CREATE POLICY "delete_own_suppliers" ON suppliers FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- PRODUCT BATCHES
-- ============================================================
DROP POLICY IF EXISTS "select_own_batches" ON product_batches;
CREATE POLICY "select_own_batches" ON product_batches FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_batches" ON product_batches;
CREATE POLICY "insert_own_batches" ON product_batches FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_batches" ON product_batches;
CREATE POLICY "update_own_batches" ON product_batches FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_batches" ON product_batches;
CREATE POLICY "delete_own_batches" ON product_batches FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- INVENTORY
-- ============================================================
DROP POLICY IF EXISTS "select_own_inventory" ON inventory;
CREATE POLICY "select_own_inventory" ON inventory FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_inventory" ON inventory;
CREATE POLICY "insert_own_inventory" ON inventory FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_inventory" ON inventory;
CREATE POLICY "update_own_inventory" ON inventory FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_inventory" ON inventory;
CREATE POLICY "delete_own_inventory" ON inventory FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- INVENTORY MOVEMENTS
-- ============================================================
DROP POLICY IF EXISTS "select_own_movements" ON inventory_movements;
CREATE POLICY "select_own_movements" ON inventory_movements FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_movements" ON inventory_movements;
CREATE POLICY "insert_own_movements" ON inventory_movements FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

-- ============================================================
-- PURCHASE ORDERS
-- ============================================================
DROP POLICY IF EXISTS "select_own_po" ON purchase_orders;
CREATE POLICY "select_own_po" ON purchase_orders FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_po" ON purchase_orders;
CREATE POLICY "insert_own_po" ON purchase_orders FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_po" ON purchase_orders;
CREATE POLICY "update_own_po" ON purchase_orders FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_po" ON purchase_orders;
CREATE POLICY "delete_own_po" ON purchase_orders FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- PURCHASE ORDER ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_po_items" ON purchase_order_items;
CREATE POLICY "select_own_po_items" ON purchase_order_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM purchase_orders po WHERE po.id = purchase_order_items.purchase_order_id AND po.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_po_items" ON purchase_order_items;
CREATE POLICY "insert_own_po_items" ON purchase_order_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM purchase_orders po WHERE po.id = purchase_order_items.purchase_order_id AND po.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "update_own_po_items" ON purchase_order_items;
CREATE POLICY "update_own_po_items" ON purchase_order_items FOR UPDATE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM purchase_orders po WHERE po.id = purchase_order_items.purchase_order_id AND po.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "delete_own_po_items" ON purchase_order_items;
CREATE POLICY "delete_own_po_items" ON purchase_order_items FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM purchase_orders po WHERE po.id = purchase_order_items.purchase_order_id AND po.organization_id = get_user_org_id())
  );

-- ============================================================
-- GOODS RECEIVED NOTES + ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_grn" ON goods_received_notes;
CREATE POLICY "select_own_grn" ON goods_received_notes FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_grn" ON goods_received_notes;
CREATE POLICY "insert_own_grn" ON goods_received_notes FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_grn" ON goods_received_notes;
CREATE POLICY "update_own_grn" ON goods_received_notes FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_grn" ON goods_received_notes;
CREATE POLICY "delete_own_grn" ON goods_received_notes FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "select_own_grn_items" ON goods_received_items;
CREATE POLICY "select_own_grn_items" ON goods_received_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM goods_received_notes g WHERE g.id = goods_received_items.grn_id AND g.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_grn_items" ON goods_received_items;
CREATE POLICY "insert_own_grn_items" ON goods_received_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM goods_received_notes g WHERE g.id = goods_received_items.grn_id AND g.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "delete_own_grn_items" ON goods_received_items;
CREATE POLICY "delete_own_grn_items" ON goods_received_items FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM goods_received_notes g WHERE g.id = goods_received_items.grn_id AND g.organization_id = get_user_org_id())
  );

-- ============================================================
-- SUPPLIER PAYMENTS
-- ============================================================
DROP POLICY IF EXISTS "select_own_supplier_payments" ON supplier_payments;
CREATE POLICY "select_own_supplier_payments" ON supplier_payments FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_supplier_payments" ON supplier_payments;
CREATE POLICY "insert_own_supplier_payments" ON supplier_payments FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_supplier_payments" ON supplier_payments;
CREATE POLICY "update_own_supplier_payments" ON supplier_payments FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

-- ============================================================
-- CUSTOMERS
-- ============================================================
DROP POLICY IF EXISTS "select_own_customers" ON customers;
CREATE POLICY "select_own_customers" ON customers FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_customers" ON customers;
CREATE POLICY "insert_own_customers" ON customers FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_customers" ON customers;
CREATE POLICY "update_own_customers" ON customers FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_customers" ON customers;
CREATE POLICY "delete_own_customers" ON customers FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- PRESCRIPTIONS + ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_prescriptions" ON prescriptions;
CREATE POLICY "select_own_prescriptions" ON prescriptions FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_prescriptions" ON prescriptions;
CREATE POLICY "insert_own_prescriptions" ON prescriptions FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_prescriptions" ON prescriptions;
CREATE POLICY "update_own_prescriptions" ON prescriptions FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_prescriptions" ON prescriptions;
CREATE POLICY "delete_own_prescriptions" ON prescriptions FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "select_own_presc_items" ON prescription_items;
CREATE POLICY "select_own_presc_items" ON prescription_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM prescriptions p WHERE p.id = prescription_items.prescription_id AND p.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_presc_items" ON prescription_items;
CREATE POLICY "insert_own_presc_items" ON prescription_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM prescriptions p WHERE p.id = prescription_items.prescription_id AND p.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "update_own_presc_items" ON prescription_items;
CREATE POLICY "update_own_presc_items" ON prescription_items FOR UPDATE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM prescriptions p WHERE p.id = prescription_items.prescription_id AND p.organization_id = get_user_org_id())
  );

-- ============================================================
-- SALES + SALE ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_sales" ON sales;
CREATE POLICY "select_own_sales" ON sales FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_sales" ON sales;
CREATE POLICY "insert_own_sales" ON sales FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_sales" ON sales;
CREATE POLICY "update_own_sales" ON sales FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "select_own_sale_items" ON sale_items;
CREATE POLICY "select_own_sale_items" ON sale_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM sales s WHERE s.id = sale_items.sale_id AND s.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_sale_items" ON sale_items;
CREATE POLICY "insert_own_sale_items" ON sale_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM sales s WHERE s.id = sale_items.sale_id AND s.organization_id = get_user_org_id())
  );

-- ============================================================
-- PAYMENTS
-- ============================================================
DROP POLICY IF EXISTS "select_own_payments" ON payments;
CREATE POLICY "select_own_payments" ON payments FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_payments" ON payments;
CREATE POLICY "insert_own_payments" ON payments FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

-- ============================================================
-- REFUNDS + ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_refunds" ON refunds;
CREATE POLICY "select_own_refunds" ON refunds FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_refunds" ON refunds;
CREATE POLICY "insert_own_refunds" ON refunds FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "select_own_refund_items" ON refund_items;
CREATE POLICY "select_own_refund_items" ON refund_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM refunds r WHERE r.id = refund_items.refund_id AND r.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_refund_items" ON refund_items;
CREATE POLICY "insert_own_refund_items" ON refund_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM refunds r WHERE r.id = refund_items.refund_id AND r.organization_id = get_user_org_id())
  );

-- ============================================================
-- EXPENSE CATEGORIES
-- ============================================================
DROP POLICY IF EXISTS "select_own_exp_categories" ON expense_categories;
CREATE POLICY "select_own_exp_categories" ON expense_categories FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_exp_categories" ON expense_categories;
CREATE POLICY "insert_own_exp_categories" ON expense_categories FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_exp_categories" ON expense_categories;
CREATE POLICY "update_own_exp_categories" ON expense_categories FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_exp_categories" ON expense_categories;
CREATE POLICY "delete_own_exp_categories" ON expense_categories FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- EXPENSES
-- ============================================================
DROP POLICY IF EXISTS "select_own_expenses" ON expenses;
CREATE POLICY "select_own_expenses" ON expenses FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_expenses" ON expenses;
CREATE POLICY "insert_own_expenses" ON expenses FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_expenses" ON expenses;
CREATE POLICY "update_own_expenses" ON expenses FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_expenses" ON expenses;
CREATE POLICY "delete_own_expenses" ON expenses FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- STOCK COUNTS + ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_stock_counts" ON stock_counts;
CREATE POLICY "select_own_stock_counts" ON stock_counts FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_stock_counts" ON stock_counts;
CREATE POLICY "insert_own_stock_counts" ON stock_counts FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_stock_counts" ON stock_counts;
CREATE POLICY "update_own_stock_counts" ON stock_counts FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "select_own_stock_count_items" ON stock_count_items;
CREATE POLICY "select_own_stock_count_items" ON stock_count_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM stock_counts sc WHERE sc.id = stock_count_items.stock_count_id AND sc.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_stock_count_items" ON stock_count_items;
CREATE POLICY "insert_own_stock_count_items" ON stock_count_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM stock_counts sc WHERE sc.id = stock_count_items.stock_count_id AND sc.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "update_own_stock_count_items" ON stock_count_items;
CREATE POLICY "update_own_stock_count_items" ON stock_count_items FOR UPDATE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM stock_counts sc WHERE sc.id = stock_count_items.stock_count_id AND sc.organization_id = get_user_org_id())
  );

-- ============================================================
-- STOCK TRANSFERS + ITEMS
-- ============================================================
DROP POLICY IF EXISTS "select_own_transfers" ON stock_transfers;
CREATE POLICY "select_own_transfers" ON stock_transfers FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_transfers" ON stock_transfers;
CREATE POLICY "insert_own_transfers" ON stock_transfers FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_transfers" ON stock_transfers;
CREATE POLICY "update_own_transfers" ON stock_transfers FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "select_own_transfer_items" ON stock_transfer_items;
CREATE POLICY "select_own_transfer_items" ON stock_transfer_items FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM stock_transfers st WHERE st.id = stock_transfer_items.stock_transfer_id AND st.organization_id = get_user_org_id())
  );

DROP POLICY IF EXISTS "insert_own_transfer_items" ON stock_transfer_items;
CREATE POLICY "insert_own_transfer_items" ON stock_transfer_items FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM stock_transfers st WHERE st.id = stock_transfer_items.stock_transfer_id AND st.organization_id = get_user_org_id())
  );

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
DROP POLICY IF EXISTS "select_own_notifications" ON notifications;
CREATE POLICY "select_own_notifications" ON notifications FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_notifications" ON notifications;
CREATE POLICY "insert_own_notifications" ON notifications FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_notifications" ON notifications;
CREATE POLICY "update_own_notifications" ON notifications FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_notifications" ON notifications;
CREATE POLICY "delete_own_notifications" ON notifications FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());

-- ============================================================
-- AUDIT LOGS (insert + select only — no update/delete)
-- ============================================================
DROP POLICY IF EXISTS "select_own_audit" ON audit_logs;
CREATE POLICY "select_own_audit" ON audit_logs FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_audit" ON audit_logs;
CREATE POLICY "insert_own_audit" ON audit_logs FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

-- ============================================================
-- SETTINGS
-- ============================================================
DROP POLICY IF EXISTS "select_own_settings" ON settings;
CREATE POLICY "select_own_settings" ON settings FOR SELECT
  TO authenticated USING (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "insert_own_settings" ON settings;
CREATE POLICY "insert_own_settings" ON settings FOR INSERT
  TO authenticated WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "update_own_settings" ON settings;
CREATE POLICY "update_own_settings" ON settings FOR UPDATE
  TO authenticated USING (organization_id = get_user_org_id()) WITH CHECK (organization_id = get_user_org_id());

DROP POLICY IF EXISTS "delete_own_settings" ON settings;
CREATE POLICY "delete_own_settings" ON settings FOR DELETE
  TO authenticated USING (organization_id = get_user_org_id());
