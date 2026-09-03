import { createContext, useContext, useEffect, useState, ReactNode, useCallback } from 'react';
import { Session, User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';
import type { UserProfile, Branch, Role, Permission } from '@/types';

interface AuthContextValue {
  user: User | null;
  session: Session | null;
  profile: UserProfile | null;
  branches: Branch[];
  activeBranch: Branch | null;
  roles: Role[];
  permissions: string[];
  loading: boolean;
  setActiveBranch: (branch: Branch) => void;
  signIn: (email: string, password: string) => Promise<{ error: string | null }>;
  signUp: (email: string, password: string, fullName: string, orgName: string) => Promise<{ error: string | null }>;
  signOut: () => Promise<void>;
  hasPermission: (code: string) => boolean;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

const ACTIVE_BRANCH_KEY = 'pharmaflow_active_branch';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [activeBranch, setActiveBranchState] = useState<Branch | null>(null);
  const [roles, setRoles] = useState<Role[]>([]);
  const [permissions, setPermissions] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  const loadUserData = useCallback(async (userId: string) => {
    const { data: prof } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (!prof) {
      setLoading(false);
      return;
    }

    setProfile(prof);

    if (prof.organization_id) {
      const [{ data: brs }, { data: rls }, { data: userBranches }] = await Promise.all([
        supabase.from('branches').select('*').eq('organization_id', prof.organization_id).eq('is_active', true),
        supabase.from('roles').select('*').eq('organization_id', prof.organization_id),
        supabase.from('user_branches').select('branch_id').eq('user_id', userId),
      ]);

      setBranches(brs || []);
      setRoles(rls || []);

      // Determine accessible branches
      let accessibleBranches = brs || [];
      if (!prof.is_global_access && userBranches) {
        const branchIds = userBranches.map((ub: { branch_id: string }) => ub.branch_id);
        accessibleBranches = (brs || []).filter((b) => branchIds.includes(b.id));
      }

      // Set active branch
      const stored = localStorage.getItem(ACTIVE_BRANCH_KEY);
      let branch = accessibleBranches.find((b) => b.id === stored) || accessibleBranches[0] || null;
      setActiveBranchState(branch);
      if (branch) localStorage.setItem(ACTIVE_BRANCH_KEY, branch.id);

      // Load permissions
      if (prof.role_id) {
        const { data: rp } = await supabase
          .from('role_permissions')
          .select('permission:permissions(code)')
          .eq('role_id', prof.role_id);

        const codes = (rp || []).map((r: Record<string, unknown>) => {
          const perm = r.permission as unknown;
          if (Array.isArray(perm)) return (perm[0] as { code: string })?.code;
          return (perm as { code: string } | null)?.code;
        }).filter(Boolean) as string[];
        setPermissions(codes);
      } else if (prof.system_role === 'super_admin' || prof.system_role === 'owner') {
        const { data: allPerms } = await supabase.from('permissions').select('code');
        setPermissions((allPerms || []).map((p: { code: string }) => p.code));
      }
    }

    setLoading(false);
  }, []);

  const refreshProfile = useCallback(async () => {
    if (user) await loadUserData(user.id);
  }, [user, loadUserData]);

  useEffect(() => {
    let mounted = true;

    supabase.auth.getSession().then(({ data: { session: s } }) => {
      if (!mounted) return;
      setSession(s);
      setUser(s?.user ?? null);
      if (s?.user) {
        loadUserData(s.user.id);
      } else {
        setLoading(false);
      }
    });

    const { data: authListener } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s);
      setUser(s?.user ?? null);
      if (s?.user) {
        loadUserData(s.user.id);
      } else {
        setProfile(null);
        setBranches([]);
        setActiveBranchState(null);
        setPermissions([]);
        setLoading(false);
      }
    });

    return () => {
      mounted = false;
      authListener.subscription.unsubscribe();
    };
  }, [loadUserData]);

  const setActiveBranch = useCallback((branch: Branch) => {
    setActiveBranchState(branch);
    localStorage.setItem(ACTIVE_BRANCH_KEY, branch.id);
  }, []);

  const signIn = useCallback(async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error: error?.message ?? null };
  }, []);

  const signUp = useCallback(
    async (email: string, password: string, fullName: string, orgName: string) => {
      const { data, error } = await supabase.auth.signUp({ email, password });
      if (error) return { error: error.message };
      if (!data.user) return { error: 'Failed to create account.' };

      // Create organization
      const { data: org, error: orgErr } = await supabase
        .from('organizations')
        .insert({ name: orgName, legal_name: orgName })
        .select()
        .single();
      if (orgErr) return { error: orgErr.message };

      // Create default branch
      const { data: branch } = await supabase
        .from('branches')
        .insert({ organization_id: org.id, name: 'Main Branch', code: 'MAIN-01' })
        .select()
        .single();

      // Create owner role
      const { data: role } = await supabase
        .from('roles')
        .insert({ organization_id: org.id, name: 'Owner', description: 'Full system access', is_system_role: true })
        .select()
        .single();

      // Create user profile
      const { error: profErr } = await supabase.from('user_profiles').insert({
        id: data.user.id,
        organization_id: org.id,
        role_id: role?.id,
        full_name: fullName,
        email,
        system_role: 'owner',
        is_global_access: true,
        is_active: true,
      });
      if (profErr) return { error: profErr.message };

      // Assign all permissions to owner role
      const { data: allPerms } = await supabase.from('permissions').select('id');
      if (allPerms && role) {
        await supabase.from('role_permissions').insert(
          allPerms.map((p: { id: string }) => ({ role_id: role.id, permission_id: p.id }))
        );
      }

      // Assign user to branch
      if (branch) {
        await supabase.from('user_branches').insert({ user_id: data.user.id, branch_id: branch.id });
      }

      return { error: null };
    },
    []
  );

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setProfile(null);
    setBranches([]);
    setActiveBranchState(null);
    setPermissions([]);
  }, []);

  const hasPermission = useCallback(
    (code: string) => {
      if (!profile) return false;
      if (profile.system_role === 'super_admin' || profile.system_role === 'owner') return true;
      return permissions.includes(code);
    },
    [profile, permissions]
  );

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        profile,
        branches,
        activeBranch,
        roles,
        permissions,
        loading,
        setActiveBranch,
        signIn,
        signUp,
        signOut,
        hasPermission,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
