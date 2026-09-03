import { useState } from 'react';
import { Navigate, Link } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useToast } from '@/contexts/ToastContext';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { Stethoscope, Lock, Mail, ArrowRight, Building2, User } from 'lucide-react';

export function LoginPage() {
  const { user, loading, signIn } = useAuth();
  const { error: showError } = useToast();
  const [email, setEmail] = useState('owner@medicarepharmacy.co.ke');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && user) return <Navigate to="/dashboard" replace />;

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    const result = await signIn(email, password);
    setSubmitting(false);
    if (result.error) showError(result.error);
  };

  return (
    <div className="min-h-screen bg-gray-50 flex">
      <div className="hidden lg:flex lg:w-1/2 bg-primary-700 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-primary-800 via-primary-700 to-secondary-800" />
        <div className="relative z-10 flex flex-col justify-between p-12 text-white w-full">
          <div className="flex items-center gap-2">
            <div className="w-9 h-9 rounded-lg bg-white/15 flex items-center justify-center"><Stethoscope className="w-6 h-6" /></div>
            <span className="text-xl font-bold">PharmaFlow</span>
          </div>
          <div>
            <p className="text-primary-200 text-sm font-medium uppercase tracking-widest">Pharmacy operations, elevated</p>
            <h1 className="mt-4 text-4xl font-bold leading-tight">Every detail of your<br />pharmacy, in control.</h1>
            <p className="mt-5 text-primary-100 max-w-md leading-relaxed">Manage inventory, sales, suppliers and your team from one professional workspace built for modern pharmacy businesses.</p>
            <div className="mt-8 grid grid-cols-3 gap-6">
              <div><p className="text-2xl font-bold">112+</p><p className="text-primary-200 text-xs mt-1">Products tracked</p></div>
              <div><p className="text-2xl font-bold">FEFO</p><p className="text-primary-200 text-xs mt-1">Expiry control</p></div>
              <div><p className="text-2xl font-bold">KES</p><p className="text-primary-200 text-xs mt-1">Kenya-ready</p></div>
            </div>
          </div>
          <p className="text-primary-200 text-xs">© 2026 PharmaFlow. Built for better pharmacy care.</p>
        </div>
      </div>
      <div className="flex-1 flex items-center justify-center p-6">
        <div className="w-full max-w-md">
          <div className="lg:hidden flex items-center justify-center gap-2 mb-10"><div className="w-9 h-9 rounded-lg bg-primary-600 flex items-center justify-center"><Stethoscope className="w-6 h-6 text-white" /></div><span className="text-xl font-bold text-gray-900">PharmaFlow</span></div>
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
            <div className="mb-7"><h2 className="text-2xl font-bold text-gray-900">Welcome back</h2><p className="text-sm text-gray-500 mt-1">Sign in to your pharmacy workspace.</p></div>
            <form onSubmit={submit} className="space-y-4">
              <Input label="Email address" type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@pharmacy.com" icon={<Mail className="w-4 h-4" />} required />
              <Input label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Enter your password" icon={<Lock className="w-4 h-4" />} required />
              <div className="flex justify-end"><button type="button" className="text-xs text-primary-600 hover:text-primary-700 font-medium">Forgot password?</button></div>
              <Button type="submit" className="w-full" size="lg" loading={submitting} icon={<ArrowRight className="w-4 h-4" />}>Sign in</Button>
            </form>
            <div className="mt-6 pt-6 border-t border-gray-100 text-center"><p className="text-sm text-gray-500">New to PharmaFlow? <Link to="/signup" className="text-primary-600 font-semibold hover:text-primary-700">Create an account</Link></p></div>
          </div>
          <p className="text-center text-xs text-gray-400 mt-5">Secure access for authorized pharmacy personnel</p>
        </div>
      </div>
    </div>
  );
}

export function SignupPage() {
  const { user, loading, signUp } = useAuth();
  const { error: showError, success } = useToast();
  const [form, setForm] = useState({ fullName: '', email: '', password: '', orgName: '' });
  const [submitting, setSubmitting] = useState(false);

  if (!loading && user) return <Navigate to="/dashboard" replace />;
  const update = (key: keyof typeof form, value: string) => setForm((f) => ({ ...f, [key]: value }));
  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    const result = await signUp(form.email, form.password, form.fullName, form.orgName);
    setSubmitting(false);
    if (result.error) showError(result.error); else success('Account created. Welcome to PharmaFlow!');
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-6">
      <div className="w-full max-w-md">
        <div className="flex items-center justify-center gap-2 mb-7"><div className="w-9 h-9 rounded-lg bg-primary-600 flex items-center justify-center"><Stethoscope className="w-6 h-6 text-white" /></div><span className="text-xl font-bold text-gray-900">PharmaFlow</span></div>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
          <div className="mb-6"><h2 className="text-2xl font-bold text-gray-900">Set up your pharmacy</h2><p className="text-sm text-gray-500 mt-1">Start managing your operations in minutes.</p></div>
          <form onSubmit={submit} className="space-y-4">
            <Input label="Your full name" value={form.fullName} onChange={(e) => update('fullName', e.target.value)} placeholder="John Kamau" icon={<User className="w-4 h-4" />} required />
            <Input label="Pharmacy / business name" value={form.orgName} onChange={(e) => update('orgName', e.target.value)} placeholder="MediCare Pharmacy" icon={<Building2 className="w-4 h-4" />} required />
            <Input label="Work email" type="email" value={form.email} onChange={(e) => update('email', e.target.value)} placeholder="you@pharmacy.com" icon={<Mail className="w-4 h-4" />} required />
            <Input label="Password" type="password" value={form.password} onChange={(e) => update('password', e.target.value)} placeholder="At least 6 characters" icon={<Lock className="w-4 h-4" />} minLength={6} required />
            <Button type="submit" className="w-full" size="lg" loading={submitting}>Create workspace <ArrowRight className="w-4 h-4" /></Button>
          </form>
          <div className="mt-6 pt-6 border-t border-gray-100 text-center"><p className="text-sm text-gray-500">Already have an account? <Link to="/login" className="text-primary-600 font-semibold">Sign in</Link></p></div>
        </div>
      </div>
    </div>
  );
}
