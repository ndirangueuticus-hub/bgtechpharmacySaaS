import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

type Variant = 'default' | 'primary' | 'success' | 'warning' | 'error' | 'info' | 'neutral';

interface BadgeProps {
  children: ReactNode;
  variant?: Variant;
  className?: string;
}

const variants: Record<Variant, string> = {
  default: 'bg-gray-100 text-gray-700',
  primary: 'bg-primary-100 text-primary-700',
  success: 'bg-success-100 text-success-700',
  warning: 'bg-warning-100 text-warning-700',
  error: 'bg-error-100 text-error-700',
  info: 'bg-secondary-100 text-secondary-700',
  neutral: 'bg-gray-800 text-white',
};

export function Badge({ children, variant = 'default', className }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium',
        variants[variant],
        className
      )}
    >
      {children}
    </span>
  );
}

export function StatusBadge({ status }: { status: string }) {
  const map: Record<string, Variant> = {
    active: 'success',
    inactive: 'default',
    expired: 'error',
    completed: 'success',
    pending: 'warning',
    approved: 'success',
    rejected: 'error',
    cancelled: 'default',
    draft: 'default',
    submitted: 'info',
    ordered: 'info',
    partially_received: 'warning',
    received: 'success',
    closed: 'default',
    requested: 'warning',
    in_transit: 'info',
    in_progress: 'info',
    dispensed: 'success',
    partially_dispensed: 'warning',
    paid: 'success',
    credit: 'warning',
    partially_paid: 'warning',
    refunded: 'error',
  };
  return (
    <Badge variant={map[status] ?? 'default'} className="capitalize">
      {status.replace(/_/g, ' ')}
    </Badge>
  );
}
