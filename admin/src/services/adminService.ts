import {
  AdminUser,
  AdminRole,
  User,
  AccountStatus,
  Calculation,
  AISolution,
  ScanRecord,
  SolutionReport,
  ThemeItem,
  NotificationItem,
  AuditLog,
  FeatureFlag,
  SystemHealthItem,
  AIProviderConfig,
} from "../types";
import {
  INITIAL_ADMINS,
  INITIAL_USERS,
  INITIAL_CALCULATIONS,
  INITIAL_AI_SOLUTIONS,
  INITIAL_SCANS,
  INITIAL_REPORTS,
  INITIAL_THEMES,
  INITIAL_NOTIFICATIONS,
  INITIAL_AUDIT_LOGS,
  INITIAL_AI_PROVIDERS,
  INITIAL_FEATURE_FLAGS,
  INITIAL_SYSTEM_HEALTH,
} from "./mockDataStore";

// In-memory state store with localStorage persistence where available
class AdminDataService {
  private admins: AdminUser[] = [...INITIAL_ADMINS];
  private users: User[] = [...INITIAL_USERS];
  private calculations: Calculation[] = [...INITIAL_CALCULATIONS];
  private aiSolutions: AISolution[] = [...INITIAL_AI_SOLUTIONS];
  private scans: ScanRecord[] = [...INITIAL_SCANS];
  private reports: SolutionReport[] = [...INITIAL_REPORTS];
  private themes: ThemeItem[] = [...INITIAL_THEMES];
  private notifications: NotificationItem[] = [...INITIAL_NOTIFICATIONS];
  private auditLogs: AuditLog[] = [...INITIAL_AUDIT_LOGS];
  private aiProviders: AIProviderConfig[] = [...INITIAL_AI_PROVIDERS];
  private featureFlags: FeatureFlag[] = [...INITIAL_FEATURE_FLAGS];
  private systemHealth: SystemHealthItem[] = [...INITIAL_SYSTEM_HEALTH];
  private currentAdmin: AdminUser = INITIAL_ADMINS[0];

  // AUTH METHODS
  async login(email: string, password: string): Promise<AdminUser> {
    await new Promise((r) => setTimeout(r, 400));
    const admin = this.admins.find((a) => a.email.toLowerCase() === email.toLowerCase());
    if (!admin) {
      throw new Error("Invalid administrator credentials.");
    }
    if (admin.status === "SUSPENDED") {
      throw new Error("Administrator account is suspended. Contact Super Admin.");
    }
    this.currentAdmin = admin;
    this.logAction("ADMIN_LOGIN", "AdminUser", admin.id, `Admin ${admin.name} logged in.`);
    return admin;
  }

  getCurrentAdmin(): AdminUser {
    return this.currentAdmin;
  }

  switchRole(role: AdminRole): AdminUser {
    const admin = this.admins.find((a) => a.role === role) || {
      ...this.currentAdmin,
      role,
      name: `${role} Demo Admin`,
    };
    this.currentAdmin = admin;
    return admin;
  }

  // AUDIT LOGGING
  private logAction(
    action: string,
    resource: string,
    resourceId: string,
    details: string,
    status: "SUCCESS" | "FAILED" = "SUCCESS"
  ) {
    const log: AuditLog = {
      id: `aud-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      adminId: this.currentAdmin.id,
      adminName: this.currentAdmin.name,
      adminRole: this.currentAdmin.role,
      action,
      resource,
      resourceId,
      details,
      ipAddress: "127.0.0.1",
      status,
      timestamp: new Date().toISOString(),
    };
    this.auditLogs.unshift(log);
  }

  async getAuditLogs(search?: string, actionFilter?: string): Promise<AuditLog[]> {
    await new Promise((r) => setTimeout(r, 200));
    return this.auditLogs.filter((log) => {
      if (actionFilter && actionFilter !== "ALL" && log.action !== actionFilter) return false;
      if (search) {
        const q = search.toLowerCase();
        return (
          log.adminName.toLowerCase().includes(q) ||
          log.details.toLowerCase().includes(q) ||
          log.resource.toLowerCase().includes(q)
        );
      }
      return true;
    });
  }

  // USERS
  async getUsers(params?: {
    search?: string;
    status?: string;
    accountType?: string;
    page?: number;
    limit?: number;
  }): Promise<{ users: User[]; total: number }> {
    await new Promise((r) => setTimeout(r, 250));
    let filtered = [...this.users];
    if (params?.search) {
      const q = params.search.toLowerCase();
      filtered = filtered.filter(
        (u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q) || u.id.includes(q)
      );
    }
    if (params?.status && params.status !== "ALL") {
      filtered = filtered.filter((u) => u.status === params.status);
    }
    if (params?.accountType && params.accountType !== "ALL") {
      filtered = filtered.filter((u) => u.accountType === params.accountType);
    }
    const page = params?.page || 1;
    const limit = params?.limit || 10;
    const start = (page - 1) * limit;
    return {
      users: filtered.slice(start, start + limit),
      total: filtered.length,
    };
  }

  async getUserById(id: string): Promise<User | undefined> {
    return this.users.find((u) => u.id === id);
  }

  async updateUserStatus(id: string, status: AccountStatus, reason?: string): Promise<User> {
    const user = this.users.find((u) => u.id === id);
    if (!user) throw new Error("User not found.");
    user.status = status;
    this.logAction(
      `USER_STATUS_${status}`,
      "User",
      id,
      `Changed status of ${user.name} (${user.email}) to ${status}. Reason: ${reason || "Admin update"}`
    );
    return user;
  }

  async deleteUser(id: string): Promise<boolean> {
    const user = this.users.find((u) => u.id === id);
    if (!user) return false;
    user.status = "DELETED";
    this.logAction("DELETE_USER", "User", id, `Soft deleted user ${user.name} (${user.email}).`);
    return true;
  }

  // CALCULATOR
  async getCalculations(search?: string, mode?: string): Promise<Calculation[]> {
    await new Promise((r) => setTimeout(r, 200));
    return this.calculations.filter((c) => {
      if (mode && mode !== "ALL" && c.mode !== mode) return false;
      if (search) {
        const q = search.toLowerCase();
        return c.expression.toLowerCase().includes(q) || c.userName.toLowerCase().includes(q);
      }
      return true;
    });
  }

  getFunctionPopularity() {
    return [
      { name: "Addition (+)", count: 4820, percentage: 32 },
      { name: "Multiplication (×)", count: 3910, percentage: 26 },
      { name: "Division (÷)", count: 2740, percentage: 18 },
      { name: "Sine / Trig (sin, cos)", count: 1890, percentage: 12 },
      { name: "Square Root (√)", count: 1420, percentage: 9 },
      { name: "Logarithms (log, ln)", count: 850, percentage: 6 },
      { name: "Powers (x², xʸ)", count: 720, percentage: 5 },
      { name: "Factorials (x!)", count: 340, percentage: 2 },
    ];
  }

  // AI SOLUTIONS
  async getAISolutions(search?: string, status?: string): Promise<AISolution[]> {
    await new Promise((r) => setTimeout(r, 250));
    return this.aiSolutions.filter((s) => {
      if (status && status !== "ALL" && s.status !== status) return false;
      if (search) {
        const q = search.toLowerCase();
        return (
          s.question.toLowerCase().includes(q) ||
          s.finalAnswer.toLowerCase().includes(q) ||
          s.userName.toLowerCase().includes(q)
        );
      }
      return true;
    });
  }

  async getSolutionReports(): Promise<SolutionReport[]> {
    await new Promise((r) => setTimeout(r, 200));
    return this.reports;
  }

  async updateReportStatus(
    id: string,
    status: "PENDING" | "INVESTIGATING" | "RESOLVED" | "DISMISSED",
    notes?: string
  ): Promise<SolutionReport> {
    const report = this.reports.find((r) => r.id === id);
    if (!report) throw new Error("Report not found.");
    report.status = status;
    this.logAction("UPDATE_REPORT_STATUS", "SolutionReport", id, `Report marked as ${status}. Note: ${notes || ""}`);
    return report;
  }

  // SCANNER
  async getScans(status?: string): Promise<ScanRecord[]> {
    await new Promise((r) => setTimeout(r, 200));
    return this.scans.filter((s) => !status || status === "ALL" || s.status === status);
  }

  // THEMES
  async getThemes(): Promise<ThemeItem[]> {
    return this.themes;
  }

  async createTheme(theme: Omit<ThemeItem, "id" | "order">): Promise<ThemeItem> {
    const newTheme: ThemeItem = {
      ...theme,
      id: `theme-${Date.now()}`,
      order: this.themes.length + 1,
    };
    this.themes.push(newTheme);
    this.logAction("CREATE_THEME", "ThemeItem", newTheme.id, `Created theme "${newTheme.name}".`);
    return newTheme;
  }

  async toggleThemeActive(id: string): Promise<ThemeItem> {
    const theme = this.themes.find((t) => t.id === id);
    if (!theme) throw new Error("Theme not found.");
    theme.isActive = !theme.isActive;
    this.logAction("TOGGLE_THEME", "ThemeItem", id, `Set theme "${theme.name}" active=${theme.isActive}.`);
    return theme;
  }

  async setDefaultTheme(id: string): Promise<ThemeItem> {
    const theme = this.themes.find((t) => t.id === id);
    if (!theme) throw new Error("Theme not found.");
    this.themes.forEach((t) => (t.isDefault = t.id === id));
    this.logAction("SET_DEFAULT_THEME", "ThemeItem", id, `Set "${theme.name}" as default calculator theme.`);
    return theme;
  }

  // NOTIFICATIONS
  async getNotifications(): Promise<NotificationItem[]> {
    return this.notifications;
  }

  async sendNotification(
    data: Omit<NotificationItem, "id" | "deliveredCount" | "openedCount" | "sentAt" | "status">
  ): Promise<NotificationItem> {
    const notif: NotificationItem = {
      ...data,
      id: `notif-${Date.now()}`,
      status: "SENT",
      sentAt: new Date().toISOString(),
      deliveredCount: 1350,
      openedCount: 0,
    };
    this.notifications.unshift(notif);
    this.logAction("SEND_NOTIFICATION", "NotificationItem", notif.id, `Sent push notification: "${notif.title}".`);
    return notif;
  }

  // AI PROVIDERS & COSTS
  async getAIProviders(): Promise<AIProviderConfig[]> {
    return this.aiProviders;
  }

  async updateAIProvider(id: string, updates: Partial<AIProviderConfig>): Promise<AIProviderConfig> {
    const provider = this.aiProviders.find((p) => p.id === id);
    if (!provider) throw new Error("Provider not found.");
    Object.assign(provider, updates);
    this.logAction("UPDATE_AI_PROVIDER", "AIProviderConfig", id, `Updated configuration for ${provider.name}.`);
    return provider;
  }

  async setPrimaryAIProvider(id: string): Promise<void> {
    this.aiProviders.forEach((p) => (p.isPrimary = p.id === id));
    this.logAction("SET_PRIMARY_AI_PROVIDER", "AIProviderConfig", id, `Set primary AI provider to ${id}.`);
  }

  // FEATURE FLAGS & SYSTEM
  async getFeatureFlags(): Promise<FeatureFlag[]> {
    return this.featureFlags;
  }

  async toggleFeatureFlag(id: string): Promise<FeatureFlag> {
    const flag = this.featureFlags.find((f) => f.id === id);
    if (!flag) throw new Error("Flag not found.");
    flag.isEnabled = !flag.isEnabled;
    this.logAction("TOGGLE_FEATURE_FLAG", "FeatureFlag", id, `Toggled ${flag.name} to ${flag.isEnabled}.`);
    return flag;
  }

  async getSystemHealth(): Promise<SystemHealthItem[]> {
    return this.systemHealth;
  }

  // ADMINS
  async getAdmins(): Promise<AdminUser[]> {
    return this.admins;
  }

  async createAdmin(data: Omit<AdminUser, "id" | "createdAt" | "lastLoginAt">): Promise<AdminUser> {
    const newAdmin: AdminUser = {
      ...data,
      id: `adm-${Date.now()}`,
      createdAt: new Date().toISOString(),
    };
    this.admins.push(newAdmin);
    this.logAction("CREATE_ADMIN", "AdminUser", newAdmin.id, `Created admin ${newAdmin.name} with role ${newAdmin.role}.`);
    return newAdmin;
  }

  async updateAdminRole(id: string, role: AdminRole): Promise<AdminUser> {
    const admin = this.admins.find((a) => a.id === id);
    if (!admin) throw new Error("Admin not found.");
    admin.role = role;
    this.logAction("UPDATE_ADMIN_ROLE", "AdminUser", id, `Changed role of ${admin.name} to ${role}.`);
    return admin;
  }

  // ANALYTICS OVERVIEW
  getOverviewKPIs() {
    return {
      totalUsers: 14850,
      totalUsersChange: "+14.2%",
      activeUsersToday: 2410,
      activeUsersChange: "+8.5%",
      proSubscribers: 1820,
      proSubscribersChange: "+24.0%",
      lifetimeRevenueUsd: 18200,
      calculationsToday: 18420,
      calculationsChange: "+12.1%",
      aiSolvesToday: 3240,
      aiSolvesChange: "+18.4%",
      ocrScansToday: 1480,
      ocrSuccessRate: 96.8,
      avgSolvingTimeMs: 410,
      estimatedMonthlyAiCostUsd: 180.9,
    };
  }

  getUserGrowthChartData() {
    return [
      { date: "May 1", users: 11200, active: 1850, calculations: 12400 },
      { date: "May 5", users: 11800, active: 1980, calculations: 13900 },
      { date: "May 10", users: 12600, active: 2150, calculations: 15100 },
      { date: "May 15", users: 13400, active: 2280, calculations: 16800 },
      { date: "May 20", users: 14100, active: 2350, calculations: 17400 },
      { date: "May 22", users: 14850, active: 2410, calculations: 18420 },
    ];
  }

  getAIUsageChartData() {
    return [
      { date: "May 1", requests: 1800, verified: 1720, failed: 80, costUsd: 2.7 },
      { date: "May 5", requests: 2100, verified: 2030, failed: 70, costUsd: 3.15 },
      { date: "May 10", requests: 2450, verified: 2380, failed: 70, costUsd: 3.68 },
      { date: "May 15", requests: 2890, verified: 2810, failed: 80, costUsd: 4.33 },
      { date: "May 20", requests: 3100, verified: 3020, failed: 80, costUsd: 4.65 },
      { date: "May 22", requests: 3240, verified: 3160, failed: 80, costUsd: 4.85 },
    ];
  }

  getPlatformDistribution() {
    return [
      { name: "iOS (Apple iPhone/iPad)", value: 58, count: 8613, color: "#3B82F6" },
      { name: "Android (Samsung, Pixel, etc.)", value: 42, count: 6237, color: "#10B981" },
    ];
  }

  getQuestionCategoryDistribution() {
    return [
      { name: "Algebra & Linear", value: 38, count: 1230, color: "#3B82F6" },
      { name: "Arithmetic & Percentages", value: 24, count: 780, color: "#10B981" },
      { name: "Calculus & Integrals", value: 16, count: 520, color: "#8B5CF6" },
      { name: "Trigonometry", value: 14, count: 450, color: "#F59E0B" },
      { name: "Other & Word Problems", value: 8, count: 260, color: "#EC4899" },
    ];
  }
}

export const adminService = new AdminDataService();
