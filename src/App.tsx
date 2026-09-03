import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { AppLayout } from '@/components/layout/AppLayout';
import { LoginPage, SignupPage } from '@/pages/auth/AuthPages';
import { DashboardPage } from '@/pages/dashboard/DashboardPage';
import { ProductsPage, InventoryPage, SuppliersPage, CustomersPage } from '@/pages/OperationsPages';
import { POSPage, SalesHistoryPage, FinancePage, NotificationsPage, AdminPage } from '@/pages/CommercePages';
import { PageLoader } from '@/components/ui/Common';

function Protected({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  if (loading) return <PageLoader />;
  if (!user) return <Navigate to="/login" replace />;
  return <AppLayout>{children}</AppLayout>;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/signup" element={<SignupPage />} />
      <Route path="/dashboard" element={<Protected><DashboardPage /></Protected>} />
      <Route path="/pos" element={<Protected><POSPage /></Protected>} />
      <Route path="/products" element={<Protected><ProductsPage /></Protected>} />
      <Route path="/inventory" element={<Protected><InventoryPage mode="stock" /></Protected>} />
      <Route path="/inventory/low-stock" element={<Protected><InventoryPage mode="low" /></Protected>} />
      <Route path="/inventory/expiry" element={<Protected><InventoryPage mode="expiry" /></Protected>} />
      <Route path="/inventory/stock-count" element={<Protected><InventoryPage mode="stock" /></Protected>} />
      <Route path="/suppliers" element={<Protected><SuppliersPage /></Protected>} />
      <Route path="/purchases/orders" element={<Protected><AdminPage type="reports" /></Protected>} />
      <Route path="/purchases/receiving" element={<Protected><AdminPage type="reports" /></Protected>} />
      <Route path="/transfers" element={<Protected><AdminPage type="reports" /></Protected>} />
      <Route path="/customers" element={<Protected><CustomersPage /></Protected>} />
      <Route path="/prescriptions" element={<Protected><AdminPage type="reports" /></Protected>} />
      <Route path="/sales/history" element={<Protected><SalesHistoryPage /></Protected>} />
      <Route path="/sales/returns" element={<Protected><AdminPage type="reports" /></Protected>} />
      <Route path="/finance" element={<Protected><FinancePage /></Protected>} />
      <Route path="/finance/expenses" element={<Protected><FinancePage expenses /></Protected>} />
      <Route path="/reports" element={<Protected><AdminPage type="reports" /></Protected>} />
      <Route path="/notifications" element={<Protected><NotificationsPage /></Protected>} />
      <Route path="/users" element={<Protected><AdminPage type="users" /></Protected>} />
      <Route path="/roles" element={<Protected><AdminPage type="roles" /></Protected>} />
      <Route path="/branches" element={<Protected><AdminPage type="branches" /></Protected>} />
      <Route path="/audit" element={<Protected><AdminPage type="audit" /></Protected>} />
      <Route path="/settings" element={<Protected><AdminPage type="settings" /></Protected>} />
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}
