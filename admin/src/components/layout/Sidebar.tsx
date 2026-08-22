"use client";

import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  Calculator,
  Brain,
  Camera,
  LineChart,
  Palette,
  Bell,
  ShieldCheck,
  FileText,
  Settings,
  ChevronLeft,
  ChevronRight,
  Activity,
  History,
  Lock,
  Cpu,
  DollarSign,
  Layers,
  Radio,
  Megaphone,
  SlidersHorizontal,
  BadgeAlert,
  Zap,
  X,
} from "lucide-react";
import { useAuth } from "@/lib/authContext";
import { cn } from "@/lib/utils";

interface NavItem {
  label: string;
  href: string;
  icon: React.ElementType;
  badge?: string | number;
  requiredPermission?: string;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

interface SidebarProps {
  mobileOpen?: boolean;
  onMobileClose?: () => void;
  collapsed?: boolean;
  onToggleCollapse?: () => void;
}

export function Sidebar({
  mobileOpen = false,
  onMobileClose,
  collapsed = false,
  onToggleCollapse,
}: SidebarProps) {
  const pathname = usePathname();
  const { role, admin } = useAuth();

  const sections: NavSection[] = [
    {
      title: "OVERVIEW",
      items: [
        { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
      ],
    },
    {
      title: "MONETIZATION & ADS",
      items: [
        { label: "Monetization Hub", href: "/monetization", icon: DollarSign, badge: "$19.8k" },
        { label: "Premium Purchases", href: "/monetization/premium", icon: Zap, badge: "$10" },
        { label: "Ad Networks & Waterfall", href: "/monetization/ad-providers", icon: Layers, badge: "AdMob" },
        { label: "House Ads Campaigns", href: "/monetization/house-ads", icon: Megaphone },
        { label: "Remote Ad Config", href: "/monetization/remote-config", icon: SlidersHorizontal, badge: "v43" },
        { label: "Network Health Alerts", href: "/monetization/alerts", icon: BadgeAlert },
      ],
    },
    {
      title: "CORE OPERATIONS",
      items: [
        { label: "Users", href: "/users", icon: Users, badge: "14.8k" },
        { label: "Calculator Logs", href: "/calculator", icon: Calculator },
        { label: "AI Solutions", href: "/ai/solutions", icon: Brain, badge: "Live" },
        { label: "Scanner & OCR", href: "/scanner", icon: Camera },
      ],
    },
    {
      title: "ANALYTICS & CONTENT",
      items: [
        { label: "Analytics", href: "/analytics", icon: LineChart },
        { label: "Themes (9 Presets)", href: "/themes", icon: Palette, badge: "9" },
        { label: "Notifications", href: "/notifications", icon: Bell },
        { label: "Reports & Exports", href: "/reports", icon: FileText },
      ],
    },
    {
      title: "SYSTEM & SECURITY",
      items: [
        { label: "Administrators", href: "/admins", icon: ShieldCheck },
        { label: "Audit Logs", href: "/audit-logs", icon: History },
        { label: "AI Providers & Cost", href: "/settings/ai", icon: Cpu },
        { label: "System Health", href: "/settings/system-health", icon: Activity },
        { label: "Settings", href: "/settings", icon: Settings },
      ],
    },
  ];

  return (
    <>
      {/* Mobile Backdrop Overlay */}
      {mobileOpen && (
        <div
          onClick={onMobileClose}
          className="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm lg:hidden animate-in fade-in"
        />
      )}

      <aside
        className={cn(
          "fixed lg:static top-0 bottom-0 left-0 z-50 flex flex-col border-r border-border bg-card transition-all duration-300 select-none h-screen",
          // Mobile state
          mobileOpen ? "translate-x-0 w-64 shadow-2xl" : "-translate-x-full lg:translate-x-0",
          // Desktop collapsed state
          collapsed ? "lg:w-20" : "lg:w-64"
        )}
      >
        {/* Brand Header */}
        <div className="flex h-16 items-center justify-between px-4 border-b border-border">
          {(!collapsed || mobileOpen) && (
            <Link href="/dashboard" onClick={onMobileClose} className="flex items-center gap-2.5">
              <div className="h-9 w-9 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-md shadow-blue-500/20 text-white font-black text-lg">
                S
              </div>
              <div>
                <div className="font-bold text-sm leading-tight text-foreground flex items-center gap-1.5">
                  SolveCalc
                  <span className="text-[10px] px-1.5 py-0.5 rounded-full font-bold bg-blue-500/10 text-blue-500 border border-blue-500/20">
                    PRO
                  </span>
                </div>
                <div className="text-[11px] text-muted-foreground">Admin Console</div>
              </div>
            </Link>
          )}

          {collapsed && !mobileOpen && (
            <div className="mx-auto h-9 w-9 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-white font-black text-lg shadow-md">
              S
            </div>
          )}

          {/* Desktop Collapse Button */}
          <button
            onClick={onToggleCollapse}
            className="hidden lg:block rounded-lg p-1.5 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
            title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
          >
            {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
          </button>

          {/* Mobile Close Button */}
          <button
            onClick={onMobileClose}
            className="lg:hidden rounded-lg p-1.5 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
          >
            <X size={18} />
          </button>
        </div>

        {/* Navigation Links */}
        <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6 scrollbar-thin">
          {sections.map((sec, idx) => (
            <div key={idx} className="space-y-1">
              {(!collapsed || mobileOpen) && (
                <div className="px-3 text-[10px] font-bold tracking-wider text-muted-foreground uppercase mb-2">
                  {sec.title}
                </div>
              )}
              {sec.items.map((item) => {
                const isActive =
                  item.href === "/dashboard"
                    ? pathname === "/dashboard" || pathname === "/"
                    : pathname === item.href ||
                      (item.href !== "/monetization" && pathname.startsWith(item.href));
                const Icon = item.icon;

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={onMobileClose}
                    className={cn(
                      "flex items-center gap-3 rounded-lg px-3 py-2 text-xs font-medium transition-all group",
                      isActive
                        ? "bg-primary text-primary-foreground font-semibold shadow-sm shadow-primary/20"
                        : "text-muted-foreground hover:bg-accent hover:text-foreground"
                    )}
                    title={collapsed && !mobileOpen ? item.label : undefined}
                  >
                    <Icon
                      size={17}
                      className={cn(
                        "shrink-0",
                        isActive
                          ? "text-primary-foreground"
                          : "text-muted-foreground group-hover:text-foreground"
                      )}
                    />
                    {(!collapsed || mobileOpen) && (
                      <span className="flex-1 truncate">{item.label}</span>
                    )}
                    {(!collapsed || mobileOpen) && item.badge && (
                      <span
                        className={cn(
                          "ml-auto text-[10px] px-1.5 py-0.5 rounded-full font-semibold",
                          isActive
                            ? "bg-primary-foreground/20 text-primary-foreground"
                            : "bg-muted text-muted-foreground"
                        )}
                      >
                        {item.badge}
                      </span>
                    )}
                  </Link>
                );
              })}
            </div>
          ))}
        </div>

        {/* Admin Profile Footer */}
        <div className="border-t border-border p-3 bg-muted/30">
          {!collapsed || mobileOpen ? (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-amber-500 to-orange-500 text-white font-bold text-xs flex items-center justify-center shrink-0">
                  {admin?.name ? admin.name[0].toUpperCase() : "A"}
                </div>
                <div className="min-w-0">
                  <div className="text-xs font-bold text-foreground truncate">
                    {admin?.name || "Admin"}
                  </div>
                  <div className="text-[10px] text-muted-foreground truncate flex items-center gap-1">
                    <span className="inline-block w-1.5 h-1.5 rounded-full bg-emerald-500" />
                    {role}
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="flex justify-center">
              <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-amber-500 to-orange-500 text-white font-bold text-xs flex items-center justify-center">
                {admin?.name ? admin.name[0].toUpperCase() : "A"}
              </div>
            </div>
          )}
        </div>
      </aside>
    </>
  );
}
