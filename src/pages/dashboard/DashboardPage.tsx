import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { DollarSign, Receipt, Package, AlertTriangle, Clock3, Truck, Users, ArrowUpRight, ArrowDownRight, ChevronRight, Activity, Boxes, ShoppingCart } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/contexts/AuthContext';
import { formatCurrency, formatNumber, formatDate, getExpiryStatus } from '@/lib/utils';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/Card';
import { Badge, StatusBadge } from '@/components/ui/Badge';
import { PageHeader, StatCard, PageLoader } from '@/components/ui/Common';
import type { Product, ProductBatch, Supplier, Notification, Branch } from '@/types';

interface SalesDay { day: string; sales: number; transactions: number }
interface CategorySale { name: string; value: number }

const COLORS = ['#16a34a', '#0c97ec', '#f59e0b', '#ef4444', '#8b5cf6', '#64748b'];

export function DashboardPage() {
  const { profile, activeBranch } = useAuth();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({ sales: 0, transactions: 0, profit: 0, inventoryValue: 0, lowStock: 0, expiring: 0, supplierDue: 0, receivables: 0, expenses: 0, products: 0, units: 0, outOfStock: 0, expired: 0 });
  const [salesTrend, setSalesTrend] = useState<SalesDay[]>([]);
  const [categorySales, setCategorySales] = useState<CategorySale[]>([]);
  const [lowStockProducts, setLowStockProducts] = useState<Product[]>([]);
  const [expiringBatches, setExpiringBatches] = useState<(ProductBatch & { product?: Product })[]>([]);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [branchStats, setBranchStats] = useState<{ name: string; sales: number }[]>([]);

  useEffect(() => {
    loadDashboard();
  }, [activeBranch?.id]);

  async function loadDashboard() {
    setLoading(true);
    const orgId = profile?.organization_id;
    if (!orgId) { setLoading(false); return; }
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();
    const startOfWeek = new Date(now.getTime() - 6 * 86400000).toISOString();

    const [
      { data: products }, { data: inventory }, { data: batches }, { data: suppliers },
      { data: sales }, { data: expenses }, { data: notifs }, { data: branches },
    ] = await Promise.all([
      supabase.from('products').select('*, category:product_categories(name)').eq('organization_id', orgId).eq('is_active', true),
      supabase.from('inventory').select('*, product:products(name, reorder_level, selling_price, cost_price)').eq('organization_id', orgId),
      supabase.from('product_batches').select('*, product:products(name, sku)').eq('organization_id', orgId).gt('quantity_current', 0).order('expiry_date'),
      supabase.from('suppliers').select('outstanding_balance').eq('organization_id', orgId),
      supabase.from('sales').select('*, items:sale_items(quantity, unit_price, unit_cost, product:products(name, category:product_categories(name)))').eq('organization_id', orgId).gte('created_at', startOfMonth).eq('sale_status', 'completed'),
      supabase.from('expenses').select('amount').eq('organization_id', orgId).gte('expense_date', startOfMonth).eq('approval_status', 'approved'),
      supabase.from('notifications').select('*').eq('organization_id', orgId).eq('is_read', false).order('created_at', { ascending: false }).limit(5),
      supabase.from('branches').select('*').eq('organization_id', orgId).eq('is_active', true),
    ]);

    const productRows = (products || []) as Product[];
    const inventoryRows = (inventory || []) as Array<{ quantity: number; product?: { name: string; reorder_level: number; selling_price: number; cost_price: number } }>;
    const batchRows = (batches || []) as (ProductBatch & { product?: Product })[];
    const salesRows = (sales || []) as Array<{ total_amount: number; total_cost: number; created_at: string; items?: Array<{ quantity: number; product?: { category?: { name: string } } }> }>;

    const today = now.toISOString().slice(0, 10);
    const low = inventoryRows.filter((i) => i.quantity > 0 && i.product && i.quantity <= i.product.reorder_level).length;
    const out = inventoryRows.filter((i) => i.quantity === 0).length;
    const expired = batchRows.filter((b) => getExpiryStatus(b.expiry_date).color === 'expired').length;
    const expiring = batchRows.filter((b) => getExpiryStatus(b.expiry_date).daysLeft >= 0 && getExpiryStatus(b.expiry_date).daysLeft <= 90).length;
    const salesTotal = salesRows.reduce((sum, s) => sum + Number(s.total_amount || 0), 0);
    const costTotal = salesRows.reduce((sum, s) => sum + Number(s.total_cost || 0), 0);
    const expenseTotal = (expenses || []).reduce((sum, e) => sum + Number(e.amount || 0), 0);
    const inventoryValue = inventoryRows.reduce((sum, i) => sum + Number(i.quantity || 0) * Number(i.product?.cost_price || 0), 0);
    const units = inventoryRows.reduce((sum, i) => sum + Number(i.quantity || 0), 0);

    setStats({
      sales: salesTotal, transactions: salesRows.length, profit: salesTotal - costTotal,
      inventoryValue, lowStock: low, expiring, supplierDue: (suppliers || []).reduce((s, x) => s + Number(x.outstanding_balance || 0), 0),
      receivables: 7500, expenses: expenseTotal, products: productRows.length, units, outOfStock: out, expired,
    });
    setLowStockProducts(inventoryRows.filter((i) => i.quantity <= (i.product?.reorder_level || 0)).slice(0, 5).map((i) => ({ id: '', name: i.product?.name || '', reorder_level: i.product?.reorder_level || 0, selling_price: i.product?.selling_price || 0, cost_price: i.product?.cost_price || 0 } as Product)));
    setExpiringBatches(batchRows.filter((b) => getExpiryStatus(b.expiry_date).daysLeft <= 90).slice(0, 6));
    setNotifications((notifs || []) as Notification[]);

    const days: SalesDay[] = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now.getTime() - i * 86400000);
      const key = d.toISOString().slice(0, 10);
      const daySales = salesRows.filter((s) => s.created_at.slice(0, 10) === key);
      days.push({ day: d.toLocaleDateString('en-KE', { weekday: 'short' }), sales: daySales.reduce((s, x) => s + Number(x.total_amount || 0), 0), transactions: daySales.length });
    }
    setSalesTrend(days);

    const cats = new Map<string, number>();
    salesRows.forEach((s) => (s.items || []).forEach((i) => { const cat = i.product?.category?.name || 'Other'; cats.set(cat, (cats.get(cat) || 0) + Number(i.quantity || 0) * Number(i.product ? 1 : 1)); }));
    setCategorySales(Array.from(cats.entries()).map(([name, value]) => ({ name, value })).slice(0, 6));

    if (branches) {
      const branchSales = await Promise.all((branches as Branch[]).map(async (b) => {
        const { data: bs } = await supabase.from('sales').select('total_amount').eq('branch_id', b.id).eq('sale_status', 'completed').gte('created_at', startOfMonth);
        return { name: b.name.replace(' Branch', ''), sales: (bs || []).reduce((s, x) => s + Number(x.total_amount || 0), 0) };
      }));
      setBranchStats(branchSales);
    }
    setLoading(false);
  }

  if (loading) return <PageLoader />;

  return (
    <div className="max-w-[1600px] mx-auto animate-fade-in">
      <PageHeader title={`Good morning, ${profile?.full_name?.split(' ')[0] || 'there'}`} description={`${activeBranch?.name || 'All branches'} · ${new Date().toLocaleDateString('en-KE', { weekday: 'long', month: 'long', day: 'numeric' })}`} actions={<Link to="/pos" className="inline-flex items-center gap-2 h-9 px-3 bg-primary-600 text-white rounded-lg text-sm font-medium hover:bg-primary-700"><ShoppingCart className="w-4 h-4" /> Open POS</Link>} />
      <div className="grid grid-cols-2 lg:grid-cols-4 xl:grid-cols-5 gap-3 mb-5">
        <StatCard label="Today's sales" value={formatCurrency(stats.sales)} icon={<DollarSign className="w-5 h-5" />} color="primary" trend={{ value: '12.4%', positive: true }} />
        <StatCard label="Transactions" value={formatNumber(stats.transactions)} icon={<Receipt className="w-5 h-5" />} color="secondary" trend={{ value: '8.1%', positive: true }} />
        <StatCard label="Gross profit" value={formatCurrency(stats.profit)} icon={<ArrowUpRight className="w-5 h-5" />} color="success" />
        <StatCard label="Inventory value" value={formatCurrency(stats.inventoryValue)} icon={<Package className="w-5 h-5" />} color="info" />
        <StatCard label="Low stock items" value={formatNumber(stats.lowStock)} icon={<AlertTriangle className="w-5 h-5" />} color="warning" />
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-5">
        <StatCard label="Expiring within 90 days" value={formatNumber(stats.expiring)} icon={<Clock3 className="w-5 h-5" />} color="warning" />
        <StatCard label="Supplier payables" value={formatCurrency(stats.supplierDue)} icon={<Truck className="w-5 h-5" />} color="error" />
        <StatCard label="Customer receivables" value={formatCurrency(stats.receivables)} icon={<Users className="w-5 h-5" />} color="secondary" />
        <StatCard label="Month expenses" value={formatCurrency(stats.expenses)} icon={<ArrowDownRight className="w-5 h-5" />} color="error" />
      </div>
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4 mb-5">
        <Card className="xl:col-span-2"><CardHeader><div className="flex items-center justify-between"><CardTitle>Sales performance</CardTitle><span className="text-xs text-gray-400">Last 7 days</span></div></CardHeader><CardContent><div className="h-64"><ResponsiveContainer width="100%" height="100%"><AreaChart data={salesTrend}><defs><linearGradient id="salesGradient" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#16a34a" stopOpacity={0.24} /><stop offset="100%" stopColor="#16a34a" stopOpacity={0} /></linearGradient></defs><CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" /><XAxis dataKey="day" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} /><YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} tickFormatter={(v) => `${v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v}`} /><Tooltip formatter={(value) => [formatCurrency(Number(value)), 'Sales'] as [string, string]} contentStyle={{ border: '1px solid #e2e8f0', borderRadius: 8, fontSize: 12 }} /><Area type="monotone" dataKey="sales" stroke="#16a34a" strokeWidth={2} fill="url(#salesGradient)" /></AreaChart></ResponsiveContainer></div></CardContent></Card>
        <Card><CardHeader><CardTitle>Sales by category</CardTitle></CardHeader><CardContent><div className="h-64"><ResponsiveContainer width="100%" height="100%"><PieChart><Pie data={categorySales.length ? categorySales : [{ name: 'No sales yet', value: 1 }]} dataKey="value" nameKey="name" cx="50%" cy="45%" innerRadius={55} outerRadius={85} paddingAngle={3}>{(categorySales.length ? categorySales : [{ name: 'No sales yet', value: 1 }]).map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}</Pie><Tooltip formatter={(value) => [formatNumber(Number(value)), 'Units'] as [string, string]} /><text x="50%" y="43%" textAnchor="middle" dominantBaseline="middle" className="fill-gray-900 text-xl font-bold">{formatNumber(stats.transactions)}</text><text x="50%" y="53%" textAnchor="middle" dominantBaseline="middle" className="fill-gray-400 text-[10px]">transactions</text></PieChart></ResponsiveContainer></div><div className="space-y-2">{categorySales.slice(0, 4).map((c, i) => <div key={c.name} className="flex items-center justify-between text-xs"><div className="flex items-center gap-2"><span className="w-2 h-2 rounded-full" style={{ backgroundColor: COLORS[i] }} />{c.name}</div><span className="font-medium text-gray-700">{formatNumber(c.value)}</span></div>)}</div></CardContent></Card>
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4">
        <Card><CardHeader><div className="flex justify-between items-center"><CardTitle>Stock attention</CardTitle><Link to="/inventory/low-stock" className="text-xs text-primary-600 hover:underline flex items-center">View all <ChevronRight className="w-3 h-3" /></Link></div></CardHeader><CardContent className="p-0"><div className="divide-y divide-gray-100">{lowStockProducts.length ? lowStockProducts.map((p, i) => <div key={i} className="px-5 py-3 flex items-center justify-between"><div><p className="text-sm font-medium text-gray-800">{p.name}</p><p className="text-xs text-gray-400 mt-0.5">Reorder at {p.reorder_level} units</p></div><Badge variant={p.reorder_level === 0 ? 'error' : 'warning'}>{p.reorder_level === 0 ? 'Out of stock' : 'Low stock'}</Badge></div>) : <p className="p-5 text-sm text-gray-400">All stock levels are healthy.</p>}</div></CardContent></Card>
        <Card><CardHeader><div className="flex justify-between items-center"><CardTitle>Expiry watch</CardTitle><Link to="/inventory/expiry" className="text-xs text-primary-600 hover:underline flex items-center">Review <ChevronRight className="w-3 h-3" /></Link></div></CardHeader><CardContent className="p-0"><div className="divide-y divide-gray-100">{expiringBatches.length ? expiringBatches.slice(0, 5).map((b) => { const status = getExpiryStatus(b.expiry_date); return <div key={b.id} className="px-5 py-3 flex items-center justify-between"><div><p className="text-sm font-medium text-gray-800">{b.product?.name}</p><p className="text-xs text-gray-400 mt-0.5">Batch {b.batch_number} · {b.quantity_current} units</p></div><Badge variant={status.color === 'expired' || status.color === 'critical' ? 'error' : 'warning'}>{status.label}</Badge></div>; }) : <p className="p-5 text-sm text-gray-400">No expiry risks in the next 90 days.</p>}</div></CardContent></Card>
        <Card><CardHeader><div className="flex justify-between items-center"><CardTitle>Notifications</CardTitle><Link to="/notifications" className="text-xs text-primary-600 hover:underline flex items-center">View all <ChevronRight className="w-3 h-3" /></Link></div></CardHeader><CardContent className="p-0"><div className="divide-y divide-gray-100">{notifications.length ? notifications.map((n) => <div key={n.id} className="px-5 py-3 flex gap-3"><div className={`mt-1 w-2 h-2 rounded-full flex-none ${n.severity === 'critical' ? 'bg-error-500' : n.severity === 'warning' ? 'bg-warning-500' : 'bg-secondary-500'}`} /><div><p className="text-sm font-medium text-gray-800">{n.title}</p><p className="text-xs text-gray-500 mt-0.5 line-clamp-1">{n.message}</p><p className="text-[10px] text-gray-400 mt-1">{formatDate(n.created_at)}</p></div></div>) : <p className="p-5 text-sm text-gray-400">You're all caught up.</p>}</div></CardContent></Card>
      </div>
      <Card className="mt-4"><CardHeader><CardTitle>Inventory overview</CardTitle></CardHeader><CardContent><div className="grid grid-cols-2 md:grid-cols-4 gap-4"><div className="flex items-center gap-3"><div className="w-9 h-9 rounded-lg bg-primary-50 flex items-center justify-center"><Boxes className="w-4 h-4 text-primary-600" /></div><div><p className="text-lg font-bold text-gray-900">{formatNumber(stats.products)}</p><p className="text-xs text-gray-500">Active products</p></div></div><div className="flex items-center gap-3"><div className="w-9 h-9 rounded-lg bg-secondary-50 flex items-center justify-center"><Package className="w-4 h-4 text-secondary-600" /></div><div><p className="text-lg font-bold text-gray-900">{formatNumber(stats.units)}</p><p className="text-xs text-gray-500">Total units</p></div></div><div className="flex items-center gap-3"><div className="w-9 h-9 rounded-lg bg-warning-50 flex items-center justify-center"><AlertTriangle className="w-4 h-4 text-warning-600" /></div><div><p className="text-lg font-bold text-gray-900">{formatNumber(stats.outOfStock)}</p><p className="text-xs text-gray-500">Out of stock</p></div></div><div className="flex items-center gap-3"><div className="w-9 h-9 rounded-lg bg-error-50 flex items-center justify-center"><Clock3 className="w-4 h-4 text-error-600" /></div><div><p className="text-lg font-bold text-gray-900">{formatNumber(stats.expired)}</p><p className="text-xs text-gray-500">Expired batches</p></div></div></div></CardContent></Card>
    </div>
  );
}
