import { NavLink, useLocation } from 'react-router-dom';
import { useState } from 'react';
import {
  LayoutDashboard, ShoppingCart, Receipt, Package, Warehouse, Truck, Users,
  FileText, DollarSign, BarChart3, Bell, UserCog, Shield, Building2,
  Settings, ChevronDown, ChevronRight, Boxes, ClipboardList, AlertTriangle,
  CalendarClock, ArrowLeftRight, PackageOpen, UserPlus, ScrollText, Stethoscope,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface NavItem {
  label: string;
  path?: string;
  icon: React.ReactNode;
  children?: { label: string; path: string }[];
}

const navItems: NavItem[] = [
  { label: 'Dashboard', path: '/dashboard', icon: <LayoutDashboard className="w-4 h-4" /> },
  { label: 'Point of Sale', path: '/pos', icon: <ShoppingCart className="w-4 h-4" /> },
  {
    label: 'Sales',
    icon: <Receipt className="w-4 h-4" />,
    children: [
      { label: 'Sales History', path: '/sales/history' },
      { label: 'Returns', path: '/sales/returns' },
    ],
  },
  {
    label: 'Inventory',
    icon: <Warehouse className="w-4 h-4" />,
    children: [
      { label: 'Products', path: '/products' },
      { label: 'Stock', path: '/inventory' },
      { label: 'Low Stock', path: '/inventory/low-stock' },
      { label: 'Expiry', path: '/inventory/expiry' },
      { label: 'Stock Count', path: '/inventory/stock-count' },
      { label: 'Transfers', path: '/transfers' },
    ],
  },
  {
    label: 'Procurement',
    icon: <Truck className="w-4 h-4" />,
    children: [
      { label: 'Suppliers', path: '/suppliers' },
      { label: 'Purchase Orders', path: '/purchases/orders' },
      { label: 'Receiving', path: '/purchases/receiving' },
    ],
  },
  {
    label: 'Customers',
    icon: <Users className="w-4 h-4" />,
    children: [
      { label: 'Customers', path: '/customers' },
      { label: 'Prescriptions', path: '/prescriptions' },
    ],
  },
  {
    label: 'Finance',
    icon: <DollarSign className="w-4 h-4" />,
    children: [
      { label: 'Revenue', path: '/finance' },
      { label: 'Expenses', path: '/finance/expenses' },
    ],
  },
  { label: 'Reports', path: '/reports', icon: <BarChart3 className="w-4 h-4" /> },
  { label: 'Notifications', path: '/notifications', icon: <Bell className="w-4 h-4" /> },
  {
    label: 'Administration',
    icon: <Shield className="w-4 h-4" />,
    children: [
      { label: 'Users', path: '/users' },
      { label: 'Roles', path: '/roles' },
      { label: 'Branches', path: '/branches' },
      { label: 'Audit Logs', path: '/audit' },
      { label: 'Settings', path: '/settings' },
    ],
  },
];

export function Sidebar({ open, onClose }: { open: boolean; onClose: () => void }) {
  const location = useLocation();
  const [expanded, setExpanded] = useState<string[]>(() => {
    // Auto-expand the group containing the current path
    for (const item of navItems) {
      if (item.children) {
        for (const child of item.children) {
          if (location.pathname.startsWith(child.path)) {
            return [item.label];
          }
        }
      }
    }
    return [];
  });

  const toggle = (label: string) => {
    setExpanded((prev) => (prev.includes(label) ? prev.filter((l) => l !== label) : [...prev, label]));
  };

  return (
    <>
      {open && <div className="fixed inset-0 bg-black/30 z-30 lg:hidden" onClick={onClose} />}
      <aside
        className={cn(
          'fixed lg:static inset-y-0 left-0 z-40 w-60 bg-white border-r border-gray-200 flex flex-col transition-transform',
          open ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        )}
      >
        <div className="h-14 flex items-center gap-2 px-4 border-b border-gray-200">
          <div className="w-8 h-8 rounded-lg bg-primary-600 flex items-center justify-center">
            <Stethoscope className="w-5 h-5 text-white" />
          </div>
          <span className="font-bold text-gray-900 text-base">PharmaFlow</span>
        </div>

        <nav className="flex-1 overflow-y-auto scrollbar-thin py-2">
          {navItems.map((item) => {
            if (item.children) {
              const isExpanded = expanded.includes(item.label);
              const hasActiveChild = item.children.some((c) => location.pathname.startsWith(c.path));
              return (
                <div key={item.label}>
                  <button
                    onClick={() => toggle(item.label)}
                    className={cn(
                      'w-full flex items-center gap-2 px-3 py-2 text-sm font-medium rounded-lg mx-2 transition-colors',
                      hasActiveChild ? 'text-primary-700 bg-primary-50' : 'text-gray-600 hover:bg-gray-50'
                    )}
                    style={{ width: 'calc(100% - 1rem)' }}
                  >
                    {item.icon}
                    <span className="flex-1 text-left">{item.label}</span>
                    {isExpanded ? <ChevronDown className="w-3.5 h-3.5" /> : <ChevronRight className="w-3.5 h-3.5" />}
                  </button>
                  {isExpanded && (
                    <div className="mt-0.5 mb-1">
                      {item.children.map((child) => (
                        <NavLink
                          key={child.path}
                          to={child.path}
                          onClick={onClose}
                          className={({ isActive }) =>
                            cn(
                              'flex items-center gap-2 pl-8 pr-3 py-1.5 text-sm rounded-lg mx-2 transition-colors',
                              isActive
                                ? 'text-primary-700 bg-primary-50 font-medium'
                                : 'text-gray-500 hover:bg-gray-50 hover:text-gray-700'
                            )
                          }
                          style={{ width: 'calc(100% - 1rem)' }}
                        >
                          {child.label}
                        </NavLink>
                      ))}
                    </div>
                  )}
                </div>
              );
            }
            return (
              <NavLink
                key={item.label}
                to={item.path!}
                onClick={onClose}
                className={({ isActive }) =>
                  cn(
                    'flex items-center gap-2 px-3 py-2 text-sm font-medium rounded-lg mx-2 transition-colors',
                    isActive
                      ? 'text-primary-700 bg-primary-50'
                      : 'text-gray-600 hover:bg-gray-50'
                  )
                }
                style={{ width: 'calc(100% - 1rem)' }}
              >
                {item.icon}
                {item.label}
              </NavLink>
            );
          })}
        </nav>
      </aside>
    </>
  );
}
