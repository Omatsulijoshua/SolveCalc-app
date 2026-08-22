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
  PremiumPurchase,
  AdNetworkItem,
  HouseAdCampaign,
  RemoteConfigVersion,
  MonetizationAlert,
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
  INITIAL_PREMIUM_PURCHASES,
  INITIAL_AD_NETWORKS,
  INITIAL_HOUSE_ADS,
  INITIAL_CONFIG_VERSIONS,
  INITIAL_MONETIZATION_ALERTS,
} from "./mockDataStore";

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

  // Monetization Data
  private purchases: PremiumPurchase[] = [...INITIAL_PREMIUM_PURCHASES];
  private adNetworks: AdNetworkItem[] = [...INITIAL_AD_NETWORKS];
  private houseAds: HouseAdCampaign[] = [...INITIAL_HOUSE_ADS];
  private configVersions: RemoteConfigVersion[] = [...INITIAL_CONFIG_VERSIONS];
  private alerts: MonetizationAlert[] = [...INITIAL_MONETIZATION_ALERTS];

  // AUTH METHODS
  async login(email: string, password: string): Promise<AdminUser> {
    await new Promise((r) => setTimeout(r, 300));
    const admin = this.admins.find((a) => a.email.toLowerCase() === email.toLowerCase());
    if (!admin) {
      throw new Error("Invalid administrator credentials.");
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
    await new Promise((r) => setTimeout(r, 150));
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
    await new Promise((r) => setTimeout(r, 200));
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

  async updateUserStatus(id: string, status: AccountStatus, reason?: string): Promise<User> {
    const user = this.users.find((u) => u.id === id);
    if (!user) throw new Error("User not found.");
    user.status = status;
    this.logAction(
      `USER_STATUS_${status}`,
      "User",
      id,
      `Changed status of ${user.name} to ${status}. Reason: ${reason || "Admin update"}`
    );
    return user;
  }

  // MONETIZATION & IN-APP PURCHASES
  async getPremiumPurchases(): Promise<PremiumPurchase[]> {
    await new Promise((r) => setTimeout(r, 150));
    return this.purchases;
  }

  async getAdNetworks(): Promise<AdNetworkItem[]> {
    await new Promise((r) => setTimeout(r, 150));
    return this.adNetworks.sort((a, b) => a.priority - b.priority);
  }

  async toggleAdNetwork(id: string): Promise<AdNetworkItem> {
    const net = this.adNetworks.find((n) => n.id === id);
    if (!net) throw new Error("Network not found.");
    net.isEnabled = !net.isEnabled;
    this.logAction("TOGGLE_AD_NETWORK", "AdNetworkItem", id, `Set ${net.name} enabled=${net.isEnabled}.`);
    return net;
  }

  async getHouseAds(): Promise<HouseAdCampaign[]> {
    return this.houseAds;
  }

  async createHouseAd(ad: Omit<HouseAdCampaign, "id" | "impressions" | "clicks" | "ctrPercent" | "createdAt">): Promise<HouseAdCampaign> {
    const created: HouseAdCampaign = {
      ...ad,
      id: `house-${Date.now()}`,
      impressions: 0,
      clicks: 0,
      ctrPercent: 0,
      createdAt: new Date().toISOString(),
    };
    this.houseAds.push(created);
    this.logAction("CREATE_HOUSE_AD", "HouseAdCampaign", created.id, `Created house campaign "${created.title}".`);
    return created;
  }

  async getRemoteConfigVersions(): Promise<RemoteConfigVersion[]> {
    return this.configVersions;
  }

  async publishRemoteConfig(config: Omit<RemoteConfigVersion, "version" | "publishedAt" | "publishedBy" | "isActive">): Promise<RemoteConfigVersion> {
    const newVer = `v${this.configVersions.length + 41}`;
    this.configVersions.forEach((c) => (c.isActive = false));
    const published: RemoteConfigVersion = {
      ...config,
      version: `${newVer} (Current)`,
      publishedBy: this.currentAdmin.name,
      publishedAt: new Date().toISOString(),
      isActive: true,
    };
    this.configVersions.unshift(published);
    this.logAction("PUBLISH_REMOTE_CONFIG", "RemoteConfigVersion", newVer, `Published remote config ${newVer}: ${config.changeSummary}`);
    return published;
  }

  async rollbackRemoteConfig(versionStr: string): Promise<void> {
    this.configVersions.forEach((c) => (c.isActive = c.version.includes(versionStr)));
    this.logAction("ROLLBACK_REMOTE_CONFIG", "RemoteConfigVersion", versionStr, `Rolled back to remote config ${versionStr}.`);
  }

  async getMonetizationAlerts(): Promise<MonetizationAlert[]> {
    return this.alerts;
  }

  // MONETIZATION KPI ANALYTICS
  getMonetizationOverviewKPIs() {
    return {
      totalRevenueUsd: 19840.5,
      totalRevenueChange: "+24.8%",
      premiumRevenueUsd: 18200.0,
      premiumPurchasesCount: 1820,
      adRevenueTodayUsd: 96.62,
      adRevenueMonthUsd: 1640.5,
      overallFillRatePercent: 96.4,
      avgEcpmUsd: 4.62,
      arpuUsd: 1.34,
      freeToPremiumConversionPercent: 12.2,
    };
  }

  getRevenueComparisonChartData() {
    return [
      { date: "May 1", premiumUsd: 420, adsUsd: 48.2, totalUsd: 468.2 },
      { date: "May 5", premiumUsd: 580, adsUsd: 62.5, totalUsd: 642.5 },
      { date: "May 10", premiumUsd: 710, adsUsd: 74.0, totalUsd: 784.0 },
      { date: "May 15", premiumUsd: 890, adsUsd: 88.5, totalUsd: 978.5 },
      { date: "May 20", premiumUsd: 980, adsUsd: 94.2, totalUsd: 1074.2 },
      { date: "May 22", premiumUsd: 1120, adsUsd: 96.6, totalUsd: 1216.6 },
    ];
  }

  // CALCULATOR
  async getCalculations(search?: string, mode?: string): Promise<Calculation[]> {
    await new Promise((r) => setTimeout(r, 150));
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
    ];
  }

  // AI SOLUTIONS
  async getAISolutions(search?: string): Promise<AISolution[]> {
    return this.aiSolutions.filter((s) => !search || s.question.toLowerCase().includes(search.toLowerCase()));
  }

  async getSolutionReports(): Promise<SolutionReport[]> {
    return this.reports;
  }

  async updateReportStatus(id: string, status: "PENDING" | "INVESTIGATING" | "RESOLVED" | "DISMISSED", notes?: string): Promise<SolutionReport> {
    const report = this.reports.find((r) => r.id === id);
    if (!report) throw new Error("Report not found.");
    report.status = status;
    this.logAction("UPDATE_REPORT_STATUS", "SolutionReport", id, `Report marked as ${status}. Note: ${notes || ""}`);
    return report;
  }

  // SCANNER
  async getScans(status?: string): Promise<ScanRecord[]> {
    return this.scans.filter((s) => !status || status === "ALL" || s.status === status);
  }

  // THEMES
  async getThemes(): Promise<ThemeItem[]> {
    return this.themes;
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

  async sendNotification(data: Omit<NotificationItem, "id" | "deliveredCount" | "openedCount" | "sentAt" | "status">): Promise<NotificationItem> {
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

  // AI PROVIDERS & FEATURE FLAGS
  async getAIProviders(): Promise<AIProviderConfig[]> {
    return this.aiProviders;
  }

  async setPrimaryAIProvider(id: string): Promise<void> {
    this.aiProviders.forEach((p) => (p.isPrimary = p.id === id));
    this.logAction("SET_PRIMARY_AI_PROVIDER", "AIProviderConfig", id, `Set primary AI provider to ${id}.`);
  }

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
