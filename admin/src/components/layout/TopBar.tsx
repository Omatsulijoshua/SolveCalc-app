"use client";

import React, { useState } from "react";
import {
  Search,
  Bell,
  Sun,
  Moon,
  Shield,
  LogOut,
  Sparkles,
  CheckCircle2,
  AlertTriangle,
} from "lucide-react";
import { useAuth } from "@/lib/authContext";
import { useTheme } from "@/lib/themeContext";
import { AdminRole } from "@/types";

interface TopBarProps {
  onOpenSearch: () => void;
}

export function TopBar({ onOpenSearch }: TopBarProps) {
  const { admin, role, switchRole, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const [showRoleMenu, setShowRoleMenu] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);

  const rolesList: AdminRole[] = [
    "SUPER_ADMIN",
    "ADMIN",
    "MODERATOR",
    "SUPPORT",
    "ANALYST",
  ];

  return (
    <header className="h-16 border-b border-border bg-card/60 backdrop-blur-md px-6 flex items-center justify-between sticky top-0 z-20">
      {/* Global Search Bar Trigger */}
      <div className="flex items-center gap-3 flex-1 max-w-md">
        <button
          onClick={onOpenSearch}
          className="flex items-center gap-2.5 w-full max-w-sm rounded-xl border border-border bg-background/80 px-3.5 py-2 text-xs text-muted-foreground hover:border-primary/40 hover:text-foreground transition-all shadow-sm"
        >
          <Search size={15} className="text-muted-foreground" />
          <span className="flex-1 text-left">Search users, equations, solutions, scans...</span>
          <kbd className="hidden sm:inline-block rounded bg-muted px-1.5 py-0.5 text-[10px] font-mono text-muted-foreground border border-border">
            Ctrl+K
          </kbd>
        </button>
      </div>

      {/* Action Center */}
      <div className="flex items-center gap-3">
        {/* Live Status Pill */}
        <div className="hidden lg:flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-[11px] font-semibold">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          API & Groq Active
        </div>

        {/* Role Quick-Switcher */}
        <div className="relative">
          <button
            onClick={() => setShowRoleMenu(!showRoleMenu)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-border bg-background hover:bg-accent text-xs font-semibold transition-colors"
          >
            <Shield size={14} className="text-amber-500" />
            <span>Role: {role}</span>
          </button>

          {showRoleMenu && (
            <div className="absolute right-0 mt-2 w-48 rounded-xl border border-border bg-popover p-1.5 shadow-xl z-50 animate-in fade-in zoom-in-95">
              <div className="px-2.5 py-1 text-[10px] font-bold text-muted-foreground uppercase">
                Switch Role Context
              </div>
              {rolesList.map((r) => (
                <button
                  key={r}
                  onClick={() => {
                    switchRole(r);
                    setShowRoleMenu(false);
                  }}
                  className={`w-full text-left px-2.5 py-1.5 rounded-lg text-xs font-medium transition-colors flex items-center justify-between ${
                    role === r
                      ? "bg-primary text-primary-foreground font-bold"
                      : "hover:bg-accent text-foreground"
                  }`}
                >
                  <span>{r}</span>
                  {role === r && <CheckCircle2 size={12} />}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Theme Toggle */}
        <button
          onClick={toggleTheme}
          className="rounded-lg p-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors border border-border"
          title={`Switch to ${theme === "dark" ? "Light" : "Dark"} Mode`}
        >
          {theme === "dark" ? <Sun size={16} /> : <Moon size={16} />}
        </button>

        {/* Notifications Popover */}
        <div className="relative">
          <button
            onClick={() => setShowNotifications(!showNotifications)}
            className="relative rounded-lg p-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors border border-border"
            title="Notifications"
          >
            <Bell size={16} />
            <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-blue-500" />
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 rounded-xl border border-border bg-popover p-3 shadow-xl z-50">
              <div className="flex items-center justify-between border-b border-border pb-2 mb-2">
                <span className="text-xs font-bold">System Alerts</span>
                <span className="text-[10px] text-blue-500 font-bold">3 Unread</span>
              </div>
              <div className="space-y-2 text-xs">
                <div className="p-2 rounded-lg bg-accent/50">
                  <div className="font-semibold text-foreground">Groq AI Verified 98.4%</div>
                  <div className="text-[11px] text-muted-foreground">Verification accuracy passed daily benchmark.</div>
                </div>
                <div className="p-2 rounded-lg bg-accent/50">
                  <div className="font-semibold text-foreground">New User Report #rep-001</div>
                  <div className="text-[11px] text-muted-foreground">Quadratic formula explanation review requested.</div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
