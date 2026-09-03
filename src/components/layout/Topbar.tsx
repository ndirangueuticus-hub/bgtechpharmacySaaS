import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Menu, ChevronDown, LogOut, User, Bell, Search, Building2 } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { cn } from '@/lib/utils';

export function Topbar({ onMenuClick }: { onMenuClick: () => void }) {
  const { profile, branches, activeBranch, setActiveBranch, signOut } = useAuth();
  const navigate = useNavigate();
  const [userMenu, setUserMenu] = useState(false);
  const [branchMenu, setBranchMenu] = useState(false);
  const userRef = useRef<HTMLDivElement>(null);
  const branchRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (userRef.current && !userRef.current.contains(e.target as Node)) setUserMenu(false);
      if (branchRef.current && !branchRef.current.contains(e.target as Node)) setBranchMenu(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  return (
    <header className="h-14 bg-white border-b border-gray-200 flex items-center justify-between px-4 sticky top-0 z-20">
      <div className="flex items-center gap-3">
        <button onClick={onMenuClick} className="lg:hidden text-gray-500 hover:text-gray-700">
          <Menu className="w-5 h-5" />
        </button>
      </div>

      <div className="flex items-center gap-3">
        {/* Branch selector */}
        <div className="relative" ref={branchRef}>
          <button
            onClick={() => setBranchMenu((v) => !v)}
            className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-600 hover:bg-gray-50 rounded-lg border border-gray-200"
          >
            <Building2 className="w-4 h-4 text-gray-400" />
            <span className="font-medium max-w-32 truncate">{activeBranch?.name ?? 'Select Branch'}</span>
            <ChevronDown className="w-3.5 h-3.5 text-gray-400" />
          </button>
          {branchMenu && (
            <div className="absolute right-0 top-full mt-1 w-56 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
              {branches.map((b) => (
                <button
                  key={b.id}
                  onClick={() => {
                    setActiveBranch(b);
                    setBranchMenu(false);
                  }}
                  className={cn(
                    'w-full text-left px-3 py-2 text-sm hover:bg-gray-50 flex items-center gap-2',
                    activeBranch?.id === b.id ? 'text-primary-700 font-medium' : 'text-gray-700'
                  )}
                >
                  <Building2 className="w-3.5 h-3.5 text-gray-400" />
                  {b.name}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Notifications */}
        <button
          onClick={() => navigate('/notifications')}
          className="relative p-2 text-gray-500 hover:bg-gray-50 rounded-lg"
        >
          <Bell className="w-5 h-5" />
          <span className="absolute top-1 right-1 w-2 h-2 bg-error-500 rounded-full" />
        </button>

        {/* User menu */}
        <div className="relative" ref={userRef}>
          <button
            onClick={() => setUserMenu((v) => !v)}
            className="flex items-center gap-2 px-2 py-1.5 hover:bg-gray-50 rounded-lg"
          >
            <div className="w-7 h-7 rounded-full bg-primary-600 flex items-center justify-center text-white text-xs font-semibold">
              {profile?.full_name?.charAt(0).toUpperCase() ?? 'U'}
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-sm font-medium text-gray-900 leading-tight">{profile?.full_name}</p>
              <p className="text-xs text-gray-400 capitalize leading-tight">{profile?.system_role}</p>
            </div>
            <ChevronDown className="w-3.5 h-3.5 text-gray-400" />
          </button>
          {userMenu && (
            <div className="absolute right-0 top-full mt-1 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
              <button
                onClick={() => {
                  setUserMenu(false);
                  navigate('/settings');
                }}
                className="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
              >
                <User className="w-4 h-4 text-gray-400" />
                Profile
              </button>
              <button
                onClick={() => signOut()}
                className="w-full text-left px-3 py-2 text-sm text-error-600 hover:bg-error-50 flex items-center gap-2"
              >
                <LogOut className="w-4 h-4" />
                Sign Out
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
