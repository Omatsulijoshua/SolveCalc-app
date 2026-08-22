"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { AdminUser, AdminRole } from "../types";
import { adminService } from "../services/adminService";
import { hasPermission as checkPermission, canAccessRoute, Permission } from "./permissions";

interface AuthContextType {
  admin: AdminUser | null;
  role: AdminRole;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, pass: string) => Promise<void>;
  logout: () => void;
  switchRole: (role: AdminRole) => void;
  hasPermission: (permission: Permission) => boolean;
  canAccess: (pathname: string) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [admin, setAdmin] = useState<AdminUser | null>(adminService.getCurrentAdmin());
  const [isLoading, setIsLoading] = useState<boolean>(false);

  useEffect(() => {
    // Check saved session if available
    const current = adminService.getCurrentAdmin();
    if (current) setAdmin(current);
  }, []);

  const login = async (email: string, pass: string) => {
    setIsLoading(true);
    try {
      const logged = await adminService.login(email, pass);
      setAdmin(logged);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    setAdmin(null);
  };

  const switchRole = (newRole: AdminRole) => {
    const updated = adminService.switchRole(newRole);
    setAdmin({ ...updated });
  };

  const role: AdminRole = admin?.role || "SUPER_ADMIN";

  const hasPermission = (permission: Permission) => {
    return checkPermission(role, permission);
  };

  const canAccess = (pathname: string) => {
    return canAccessRoute(role, pathname);
  };

  return (
    <AuthContext.Provider
      value={{
        admin,
        role,
        isAuthenticated: !!admin,
        isLoading,
        login,
        logout,
        switchRole,
        hasPermission,
        canAccess,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
