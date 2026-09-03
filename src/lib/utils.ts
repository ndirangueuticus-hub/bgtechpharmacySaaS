import { clsx, type ClassValue } from 'clsx';

export function cn(...inputs: ClassValue[]) {
  return clsx(inputs);
}

export function formatCurrency(amount: number | null | undefined): string {
  if (amount === null || amount === undefined || isNaN(amount)) return 'KES 0.00';
  return new Intl.NumberFormat('en-KE', {
    style: 'currency',
    currency: 'KES',
    minimumFractionDigits: 2,
  }).format(amount);
}

export function formatNumber(value: number | null | undefined): string {
  if (value === null || value === undefined || isNaN(value)) return '0';
  return new Intl.NumberFormat('en-KE').format(value);
}

export function formatDate(date: string | Date | null | undefined): string {
  if (!date) return '-';
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('en-KE', { year: 'numeric', month: 'short', day: 'numeric' });
}

export function formatDateTime(date: string | Date | null | undefined): string {
  if (!date) return '-';
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleString('en-KE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function daysUntil(date: string | Date | null | undefined): number {
  if (!date) return Infinity;
  const d = typeof date === 'string' ? new Date(date) : date;
  const diff = d.getTime() - new Date().getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

export function getExpiryStatus(expiryDate: string | Date | null | undefined): {
  label: string;
  color: 'expired' | 'critical' | 'warning' | 'safe';
  daysLeft: number;
} {
  const days = daysUntil(expiryDate);
  if (days < 0) return { label: 'Expired', color: 'expired', daysLeft: days };
  if (days <= 7) return { label: `${days}d left`, color: 'critical', daysLeft: days };
  if (days <= 30) return { label: `${days}d left`, color: 'warning', daysLeft: days };
  if (days <= 90) return { label: `${days}d left`, color: 'warning', daysLeft: days };
  return { label: 'Safe', color: 'safe', daysLeft: days };
}

export function generateNumber(prefix: string, count: number): string {
  return `${prefix}-${new Date().getFullYear()}-${String(count).padStart(4, '0')}`;
}

export function generateSaleNumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `SALE-${ts}`;
}

export function generatePONumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `PO-${ts}`;
}

export function generateGRNNumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `GRN-${ts}`;
}

export function generateExpenseNumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `EXP-${new Date().getFullYear()}-${ts}`;
}

export function generateTransferNumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `TRF-${ts}`;
}

export function generateStockCountNumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `SC-${ts}`;
}

export function generatePrescriptionNumber(): string {
  const ts = Date.now().toString().slice(-6);
  return `RX-${ts}`;
}

export function downloadCSV(filename: string, rows: Record<string, unknown>[]) {
  if (rows.length === 0) return;
  const headers = Object.keys(rows[0]);
  const csvContent = [
    headers.join(','),
    ...rows.map((row) =>
      headers
        .map((header) => {
          const value = row[header];
          const str = value === null || value === undefined ? '' : String(value);
          return `"${str.replace(/"/g, '""')}"`;
        })
        .join(',')
    ),
  ].join('\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
  URL.revokeObjectURL(link.href);
}

export function printContent(content: string) {
  const printWindow = window.open('', '_blank');
  if (!printWindow) return;
  printWindow.document.write(content);
  printWindow.document.close();
  printWindow.focus();
  setTimeout(() => printWindow.print(), 250);
}
