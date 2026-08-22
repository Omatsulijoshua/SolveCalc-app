import { AdminRole } from "../types";

export type Permission =
  | "*"
  | "dashboard.view"
  | "users.view"
  | "users.edit"
  | "users.suspend"
  | "users.delete"
  | "calculator.view"
  | "calculator.analytics"
  | "ai.solutions.view"
  | "ai.quality.view"
  | "ai.reports.manage"
  | "ai.providers.manage"
  | "ai.costs.view"
  | "scanner.view"
  | "scanner.review"
  | "themes.view"
  | "themes.manage"
  | "notifications.view"
  | "notifications.manage"
  | "analytics.view"
  | "reports.export"
  | "system.health"
  | "system.errors"
  | "system.features"
  | "system.versions"
  | "system.maintenance"
  | "admins.view"
  | "admins.manage"
  | "audit.view"
  | "privacy.manage";

const ROLE_PERMISSIONS: Record<AdminRole, Permission[]> = {
  SUPER_ADMIN: ["*"],
  ADMIN: [
    "dashboard.view",
    "users.view",
    "users.edit",
    "users.suspend",
    "calculator.view",
    "calculator.analytics",
    "ai.solutions.view",
    "ai.quality.view",
    "ai.reports.manage",
    "ai.costs.view",
    "scanner.view",
    "scanner.review",
    "themes.view",
    "themes.manage",
    "notifications.view",
    "notifications.manage",
    "analytics.view",
    "reports.export",
    "system.health",
    "system.errors",
    "system.features",
    "audit.view",
  ],
  MODERATOR: [
    "dashboard.view",
    "users.view",
    "scanner.view",
    "scanner.review",
    "ai.solutions.view",
    "ai.reports.manage",
    "ai.quality.view",
  ],
  SUPPORT: [
    "dashboard.view",
    "users.view",
    "calculator.view",
    "ai.solutions.view",
    "scanner.view",
    "ai.reports.manage",
  ],
  ANALYST: [
    "dashboard.view",
    "analytics.view",
    "reports.export",
    "calculator.analytics",
    "ai.costs.view",
    "ai.quality.view",
    "users.view",
  ],
};

export function hasPermission(role: AdminRole, permission: Permission): boolean {
  if (role === "SUPER_ADMIN") return true;
  const permissions = ROLE_PERMISSIONS[role] || [];
  return permissions.includes("*") || permissions.includes(permission);
}

export function canAccessRoute(role: AdminRole, pathname: string): boolean {
  if (role === "SUPER_ADMIN") return true;

  if (pathname === "/dashboard" || pathname === "/") return true;
  if (pathname.startsWith("/users")) return hasPermission(role, "users.view");
  if (pathname.startsWith("/calculator")) return hasPermission(role, "calculator.view") || hasPermission(role, "calculator.analytics");
  if (pathname.startsWith("/ai/solutions")) return hasPermission(role, "ai.solutions.view");
  if (pathname.startsWith("/ai/reports")) return hasPermission(role, "ai.reports.manage");
  if (pathname.startsWith("/ai/providers")) return hasPermission(role, "ai.providers.manage");
  if (pathname.startsWith("/ai/costs")) return hasPermission(role, "ai.costs.view");
  if (pathname.startsWith("/scanner")) return hasPermission(role, "scanner.view");
  if (pathname.startsWith("/themes")) return hasPermission(role, "themes.view");
  if (pathname.startsWith("/notifications")) return hasPermission(role, "notifications.view");
  if (pathname.startsWith("/analytics")) return hasPermission(role, "analytics.view");
  if (pathname.startsWith("/reports")) return hasPermission(role, "reports.export");
  if (pathname.startsWith("/admins")) return hasPermission(role, "admins.view");
  if (pathname.startsWith("/audit-logs")) return hasPermission(role, "audit.view");
  if (pathname.startsWith("/settings")) {
    if (pathname.includes("/ai")) return hasPermission(role, "ai.providers.manage");
    if (pathname.includes("/features")) return hasPermission(role, "system.features");
    if (pathname.includes("/privacy")) return hasPermission(role, "privacy.manage");
    return hasPermission(role, "system.health");
  }

  return true;
}
