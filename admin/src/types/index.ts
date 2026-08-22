export type AdminRole =
  | 'SUPER_ADMIN'
  | 'ADMIN'
  | 'MODERATOR'
  | 'SUPPORT'
  | 'ANALYST';

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
  avatar?: string;
  status: 'ACTIVE' | 'SUSPENDED';
  twoFactorEnabled: boolean;
  lastLoginAt?: string;
  createdAt: string;
}

export type AccountStatus = 'ACTIVE' | 'SUSPENDED' | 'BANNED' | 'DELETED';
export type AccountType = 'FREE' | 'PRO_LIFETIME';

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  status: AccountStatus;
  accountType: AccountType;
  calculationsCount: number;
  aiSolvesCount: number;
  scansCount: number;
  registeredAt: string;
  lastActiveAt: string;
  devicePlatform: 'iOS' | 'Android';
  appVersion: string;
}

export interface Calculation {
  id: string;
  userId: string;
  userName: string;
  expression: string;
  result: string;
  mode: 'basic' | 'scientific';
  angleMode: 'DEG' | 'RAD' | 'GRAD';
  isError: boolean;
  timestamp: string;
}

export interface SolutionStep {
  stepNumber: number;
  title: string;
  explanation: string;
  whyExplanation?: string;
  equation?: string;
}

export interface AISolution {
  id: string;
  userId: string;
  userName: string;
  question: string;
  questionType: string;
  finalAnswer: string;
  solverType: string;
  provider: string;
  model: string;
  tokensUsed: number;
  latencyMs: number;
  verificationStatus: 'VERIFIED' | 'UNVERIFIED' | 'FAILED';
  status: 'COMPLETED' | 'FLAGGED' | 'FAILED';
  steps: SolutionStep[];
  timestamp: string;
}

export interface ScanRecord {
  id: string;
  userId: string;
  userName: string;
  originalImageUrl?: string;
  rawOcrText: string;
  correctedText?: string;
  finalQuestion: string;
  status: 'SUCCESS' | 'FAILED' | 'MANUALLY_CORRECTED';
  confidence: number;
  latencyMs: number;
  timestamp: string;
}

export interface SolutionReport {
  id: string;
  solutionId: string;
  userId: string;
  userName: string;
  question: string;
  answer: string;
  reason: 'INCORRECT_ANSWER' | 'MISREAD_IMAGE' | 'CONFUSING_EXPLANATION' | 'OTHER';
  userComment?: string;
  status: 'PENDING' | 'INVESTIGATING' | 'RESOLVED' | 'DISMISSED';
  createdAt: string;
}

export interface ThemeItem {
  id: string;
  name: string;
  description: string;
  primaryColor: string;
  secondaryColor: string;
  backgroundColor: string;
  surfaceColor: string;
  numberButtonColor: string;
  operatorButtonColor: string;
  isDark: boolean;
  isActive: boolean;
  isDefault: boolean;
  isPremium: boolean;
  order: number;
}

export interface NotificationItem {
  id: string;
  title: string;
  message: string;
  type: 'SYSTEM' | 'FEATURE' | 'MAINTENANCE' | 'PROMO';
  targetAudience: 'ALL' | 'ANDROID' | 'IOS' | 'SPECIFIC_USER';
  targetUserId?: string;
  status: 'SENT' | 'SCHEDULED' | 'FAILED';
  scheduledFor?: string;
  sentAt?: string;
  deliveredCount: number;
  openedCount: number;
}

export interface AuditLog {
  id: string;
  adminId: string;
  adminName: string;
  adminRole: AdminRole;
  action: string;
  resource: string;
  resourceId?: string;
  details: string;
  ipAddress: string;
  status: 'SUCCESS' | 'FAILED';
  timestamp: string;
}

export interface FeatureFlag {
  id: string;
  key: string;
  name: string;
  description: string;
  isEnabled: boolean;
  category: 'CORE' | 'AI' | 'SCANNER' | 'MONETIZATION' | 'EXPERIMENTAL';
}

export interface SystemHealthItem {
  name: string;
  status: 'ONLINE' | 'DEGRADED' | 'OFFLINE';
  latencyMs: number;
  message: string;
  lastChecked: string;
}

export interface AIProviderConfig {
  id: string;
  name: string;
  providerType: 'GROQ' | 'GEMINI' | 'OPENAI' | 'LOCAL_DETERMINISTIC';
  isPrimary: boolean;
  isFallback: boolean;
  isEnabled: boolean;
  apiKeyMasked: string;
  model: string;
  timeoutMs: number;
  maxTokens: number;
  dailyLimitUsd: number;
  monthlyLimitUsd: number;
  currentDaySpendUsd: number;
  currentMonthSpendUsd: number;
}

// MONETIZATION & ADVERTISING MODELS
export interface PremiumPurchase {
  id: string;
  userId: string;
  userName: string;
  platform: 'iOS' | 'Android';
  productId: string;
  priceUsd: number;
  transactionId: string;
  purchaseDate: string;
  status: 'VERIFIED' | 'PENDING' | 'REFUNDED' | 'REVOKED';
  receiptVerified: boolean;
}

export interface AdNetworkItem {
  id: string;
  name: string;
  sdkName: string;
  priority: number; // 1 = Primary, 2 = Secondary, etc.
  isEnabled: boolean;
  appOpenEnabled: boolean;
  bannerEnabled: boolean;
  nativeEnabled: boolean;
  impressionsToday: number;
  fillRatePercent: number;
  ecpmUsd: number;
  revenueTodayUsd: number;
  healthStatus: 'HEALTHY' | 'DEGRADED' | 'ERROR';
  lastHealthCheck: string;
}

export interface HouseAdCampaign {
  id: string;
  title: string;
  description: string;
  ctaText: string;
  destination: string;
  isActive: boolean;
  priority: number;
  impressions: number;
  clicks: number;
  ctrPercent: number;
  createdAt: string;
}

export interface RemoteConfigVersion {
  version: string;
  publishedBy: string;
  publishedAt: string;
  emergencyMode: 'NORMAL' | 'ADS_DISABLED' | 'PREMIUM_ONLY' | 'HOUSE_ADS_ONLY';
  primaryProvider: string;
  fallbackProviders: string[];
  appOpenCooldownMin: number;
  appOpenMaxPerSession: number;
  bannerRefreshSec: number;
  changeSummary: string;
  isActive: boolean;
}

export interface MonetizationAlert {
  id: string;
  severity: 'WARNING' | 'CRITICAL' | 'INFO';
  title: string;
  message: string;
  providerId?: string;
  timestamp: string;
  isResolved: boolean;
}
