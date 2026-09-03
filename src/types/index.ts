export interface Organization {
  id: string;
  name: string;
  legal_name: string | null;
  country: string;
  currency: string;
  timezone: string;
  tax_id: string | null;
  phone: string | null;
  email: string | null;
  address: string | null;
  logo_url: string | null;
  is_active: boolean;
  created_at: string;
}

export interface Branch {
  id: string;
  organization_id: string;
  name: string;
  code: string | null;
  location: string | null;
  address: string | null;
  phone: string | null;
  email: string | null;
  manager_id: string | null;
  is_active: boolean;
  created_at: string;
}

export interface UserProfile {
  id: string;
  organization_id: string | null;
  role_id: string | null;
  full_name: string;
  email: string;
  phone: string | null;
  system_role: string;
  is_global_access: boolean;
  is_active: boolean;
  created_at: string;
}

export interface Role {
  id: string;
  organization_id: string;
  name: string;
  description: string | null;
  is_system_role: boolean;
}

export interface Permission {
  id: string;
  code: string;
  name: string;
  module: string;
  description: string | null;
}

export interface ProductCategory {
  id: string;
  organization_id: string;
  name: string;
  description: string | null;
}

export interface Manufacturer {
  id: string;
  organization_id: string;
  name: string;
  country: string | null;
  contact_phone: string | null;
  contact_email: string | null;
  is_active: boolean;
}

export interface Product {
  id: string;
  organization_id: string;
  category_id: string | null;
  manufacturer_id: string | null;
  name: string;
  generic_name: string | null;
  brand_name: string | null;
  product_code: string | null;
  sku: string | null;
  barcode: string | null;
  dosage_form: string | null;
  strength: string | null;
  unit: string | null;
  description: string | null;
  is_prescription_required: boolean;
  reorder_level: number;
  max_stock_level: number;
  selling_price: number;
  cost_price: number;
  tax_rate: number;
  is_active: boolean;
  deleted_at: string | null;
  created_at: string;
  updated_at: string;
  category?: ProductCategory;
  manufacturer?: Manufacturer;
}

export interface ProductBatch {
  id: string;
  organization_id: string;
  product_id: string;
  branch_id: string;
  batch_number: string;
  manufacturing_date: string | null;
  expiry_date: string;
  quantity_received: number;
  quantity_current: number;
  cost_price: number;
  selling_price: number;
  supplier_id: string | null;
  status: string;
  created_at: string;
  product?: Product;
  branch?: Branch;
}

export interface Inventory {
  id: string;
  organization_id: string;
  product_id: string;
  branch_id: string;
  quantity: number;
  reserved_quantity: number;
  created_at: string;
  updated_at: string;
  product?: Product;
  branch?: Branch;
}

export interface InventoryMovement {
  id: string;
  organization_id: string;
  product_id: string;
  batch_id: string | null;
  branch_id: string;
  quantity: number;
  direction: 'IN' | 'OUT';
  movement_type: string;
  previous_balance: number;
  new_balance: number;
  user_id: string | null;
  reference_type: string | null;
  reference_id: string | null;
  reason: string | null;
  created_at: string;
  product?: Product;
  branch?: Branch;
}

export interface Supplier {
  id: string;
  organization_id: string;
  name: string;
  contact_person: string | null;
  phone: string | null;
  email: string | null;
  address: string | null;
  tax_id: string | null;
  payment_terms: string | null;
  credit_limit: number;
  outstanding_balance: number;
  status: string;
  created_at: string;
}

export interface PurchaseOrder {
  id: string;
  organization_id: string;
  branch_id: string;
  supplier_id: string;
  po_number: string;
  status: string;
  total_amount: number;
  notes: string | null;
  created_by: string | null;
  approved_by: string | null;
  created_at: string;
  updated_at: string;
  supplier?: Supplier;
  branch?: Branch;
  items?: PurchaseOrderItem[];
}

export interface PurchaseOrderItem {
  id: string;
  purchase_order_id: string;
  product_id: string;
  quantity_ordered: number;
  quantity_received: number;
  unit_cost: number;
  total_cost: number;
  product?: Product;
}

export interface GoodsReceivedNote {
  id: string;
  organization_id: string;
  branch_id: string;
  purchase_order_id: string | null;
  supplier_id: string;
  grn_number: string;
  total_amount: number;
  status: string;
  received_by: string | null;
  notes: string | null;
  created_at: string;
  supplier?: Supplier;
  branch?: Branch;
  items?: GoodsReceivedItem[];
}

export interface GoodsReceivedItem {
  id: string;
  grn_id: string;
  product_id: string;
  batch_number: string;
  expiry_date: string;
  quantity_received: number;
  unit_cost: number;
  total_cost: number;
  product?: Product;
}

export interface Customer {
  id: string;
  organization_id: string;
  customer_number: string | null;
  name: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  outstanding_balance: number;
  status: string;
  created_at: string;
}

export interface Prescription {
  id: string;
  organization_id: string;
  branch_id: string;
  customer_id: string | null;
  prescription_number: string;
  prescriber_name: string | null;
  prescriber_license: string | null;
  prescription_date: string;
  status: string;
  pharmacist_id: string | null;
  notes: string | null;
  created_at: string;
  customer?: Customer;
  items?: PrescriptionItem[];
}

export interface PrescriptionItem {
  id: string;
  prescription_id: string;
  product_id: string;
  dosage: string | null;
  frequency: string | null;
  duration: string | null;
  instructions: string | null;
  quantity: number;
  is_dispensed: boolean;
  product?: Product;
}

export interface Sale {
  id: string;
  organization_id: string;
  branch_id: string;
  sale_number: string;
  customer_id: string | null;
  prescription_id: string | null;
  subtotal: number;
  discount_amount: number;
  tax_amount: number;
  total_amount: number;
  total_cost: number;
  payment_status: string;
  sale_status: string;
  served_by: string | null;
  notes: string | null;
  created_at: string;
  customer?: Customer;
  items?: SaleItem[];
  payments?: Payment[];
}

export interface SaleItem {
  id: string;
  sale_id: string;
  product_id: string;
  batch_id: string | null;
  quantity: number;
  unit_price: number;
  unit_cost: number;
  discount_amount: number;
  tax_amount: number;
  line_total: number;
  product?: Product;
}

export interface Payment {
  id: string;
  organization_id: string;
  sale_id: string;
  amount: number;
  payment_method: string;
  reference: string | null;
  created_at: string;
}

export interface Expense {
  id: string;
  organization_id: string;
  branch_id: string;
  expense_number: string;
  category_id: string | null;
  amount: number;
  expense_date: string;
  description: string | null;
  payment_method: string;
  approval_status: string;
  created_at: string;
  category?: ExpenseCategory;
  branch?: Branch;
}

export interface ExpenseCategory {
  id: string;
  organization_id: string;
  name: string;
  description: string | null;
}

export interface StockCount {
  id: string;
  organization_id: string;
  branch_id: string;
  count_number: string;
  status: string;
  initiated_by: string | null;
  approved_by: string | null;
  notes: string | null;
  created_at: string;
  branch?: Branch;
  items?: StockCountItem[];
}

export interface StockCountItem {
  id: string;
  stock_count_id: string;
  product_id: string;
  system_quantity: number;
  physical_quantity: number;
  variance: number;
  variance_value: number;
  product?: Product;
}

export interface StockTransfer {
  id: string;
  organization_id: string;
  transfer_number: string;
  from_branch_id: string;
  to_branch_id: string;
  status: string;
  requested_by: string | null;
  approved_by: string | null;
  received_by: string | null;
  notes: string | null;
  created_at: string;
  from_branch?: Branch;
  to_branch?: Branch;
  items?: StockTransferItem[];
}

export interface StockTransferItem {
  id: string;
  stock_transfer_id: string;
  product_id: string;
  quantity: number;
  product?: Product;
}

export interface Notification {
  id: string;
  organization_id: string;
  user_id: string | null;
  title: string;
  message: string;
  type: string;
  severity: 'info' | 'warning' | 'critical';
  is_read: boolean;
  reference_type: string | null;
  reference_id: string | null;
  created_at: string;
}

export interface AuditLog {
  id: string;
  organization_id: string;
  user_id: string | null;
  action: string;
  entity_type: string | null;
  entity_id: string | null;
  old_values: Record<string, unknown> | null;
  new_values: Record<string, unknown> | null;
  ip_address: string | null;
  description: string | null;
  created_at: string;
}

export interface Setting {
  id: string;
  organization_id: string;
  key: string;
  value: string;
  category: string;
}

export interface CartItem {
  product_id: string;
  name: string;
  barcode: string | null;
  selling_price: number;
  cost_price: number;
  quantity: number;
  tax_rate: number;
  max_available: number;
  batch_id?: string;
  batch_number?: string;
  is_prescription: boolean;
}
