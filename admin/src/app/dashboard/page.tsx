"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  Users,
  Calculator,
  Brain,
  Camera,
  TrendingUp,
  DollarSign,
  Activity,
  CheckCircle2,
  AlertTriangle,
  ArrowUpRight,
  ShieldCheck,
  Palette,
  Bell,
  Sparkles,
  Cpu,
  Layers,
} from "lucide-react";
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { useAuth } from "@/lib/authContext";
import { formatNumber, formatCurrency } from "@/lib/utils";

export default function DashboardPage() {
  const { role, hasPermission } = useAuth();
  const [timeRange, setTimeRange] = useState("30d");

  const kpis = adminService.getOverviewKPIs();
  const growthData = adminService.getUserGrowthChartData();
  const aiData = adminService.getAIUsageChartData();
  const platforms = adminService.getPlatformDistribution();
  const categories = adminService.getQuestionCategoryDistribution();
  const functionStats = adminService.getFunctionPopularity();

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in duration-300">
        {/* Header Title & Date Range Filter */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black tracking-tight text-foreground flex items-center gap-2">
              SolveCalc Platform Command Center
              <span className="text-xs px-2.5 py-1 rounded-full font-bold bg-blue-500/10 text-blue-500 border border-blue-500/20">
                v1.0.4 Live
              </span>
            </h1>
            <p className="text-xs text-muted-foreground mt-1">
              Operational intelligence, AI solver telemetry, OCR pipeline, and monetization health.
            </p>
          </div>

          <div className="flex items-center gap-2">
            {["7d", "30d", "90d", "Year"].map((range) => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                  timeRange === range
                    ? "bg-primary text-primary-foreground shadow-sm shadow-primary/20"
                    : "bg-card border border-border text-muted-foreground hover:text-foreground"
                }`}
              >
                {range === "7d"
                  ? "Last 7 Days"
                  : range === "30d"
                  ? "Last 30 Days"
                  : range === "90d"
                  ? "Last 90 Days"
                  : "This Year"}
              </button>
            ))}
          </div>
        </div>

        {/* Top KPI Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {/* Card 1: Users */}
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm hover:border-primary/30 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                Total Users
              </span>
              <div className="p-2 rounded-xl bg-blue-500/10 text-blue-500">
                <Users size={18} />
              </div>
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-2xl font-black text-foreground">
                {formatNumber(kpis.totalUsers)}
              </span>
              <span className="text-xs font-bold text-emerald-500 flex items-center">
                <TrendingUp size={12} className="mr-0.5" />
                {kpis.totalUsersChange}
              </span>
            </div>
            <div className="mt-2 text-[11px] text-muted-foreground">
              <strong>{formatNumber(kpis.activeUsersToday)}</strong> active today •{" "}
              <span className="text-blue-500 font-semibold">{formatNumber(kpis.proSubscribers)} Pro</span>
            </div>
          </div>

          {/* Card 2: Monetization ($10 Lifetime Tier) */}
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm hover:border-amber-500/30 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                Lifetime Revenue ($10 Tier)
              </span>
              <div className="p-2 rounded-xl bg-amber-500/10 text-amber-500">
                <DollarSign size={18} />
              </div>
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-2xl font-black text-foreground">
                {formatCurrency(kpis.lifetimeRevenueUsd)}
              </span>
              <span className="text-xs font-bold text-emerald-500 flex items-center">
                <TrendingUp size={12} className="mr-0.5" />
                {kpis.proSubscribersChange}
              </span>
            </div>
            <div className="mt-2 text-[11px] text-muted-foreground">
              <strong>1,820</strong> lifetime purchases • $10 USD one-time
            </div>
          </div>

          {/* Card 3: Calculations Today */}
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm hover:border-emerald-500/30 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                Calculations Today
              </span>
              <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-500">
                <Calculator size={18} />
              </div>
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-2xl font-black text-foreground">
                {formatNumber(kpis.calculationsToday)}
              </span>
              <span className="text-xs font-bold text-emerald-500 flex items-center">
                <TrendingUp size={12} className="mr-0.5" />
                {kpis.calculationsChange}
              </span>
            </div>
            <div className="mt-2 text-[11px] text-muted-foreground">
              Avg 7.6 calcs/active user • 64% Scientific mode
            </div>
          </div>

          {/* Card 4: AI Solves & Quality */}
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm hover:border-purple-500/30 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                AI Math Solves Today
              </span>
              <div className="p-2 rounded-xl bg-purple-500/10 text-purple-500">
                <Brain size={18} />
              </div>
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-2xl font-black text-foreground">
                {formatNumber(kpis.aiSolvesToday)}
              </span>
              <span className="text-xs font-bold text-emerald-500 flex items-center">
                <TrendingUp size={12} className="mr-0.5" />
                {kpis.aiSolvesChange}
              </span>
            </div>
            <div className="mt-2 text-[11px] text-muted-foreground">
              {kpis.ocrSuccessRate}% OCR accuracy • {kpis.avgSolvingTimeMs}ms avg latency
            </div>
          </div>
        </div>

        {/* Quick Actions Panel */}
        <div className="p-4 rounded-2xl border border-border bg-card/60 backdrop-blur-sm">
          <div className="text-xs font-bold uppercase tracking-wider text-muted-foreground mb-3 flex items-center gap-2">
            <Sparkles size={14} className="text-amber-500" />
            Administrator Quick Actions
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
            <Link
              href="/users"
              className="flex flex-col items-center justify-center p-3 rounded-xl border border-border bg-background hover:border-primary hover:bg-accent transition-all text-center group"
            >
              <Users size={20} className="text-blue-500 mb-1.5 group-hover:scale-110 transition-transform" />
              <span className="text-xs font-semibold text-foreground">Manage Users</span>
            </Link>

            <Link
              href="/ai/solutions"
              className="flex flex-col items-center justify-center p-3 rounded-xl border border-border bg-background hover:border-purple-500 hover:bg-accent transition-all text-center group"
            >
              <Brain size={20} className="text-purple-500 mb-1.5 group-hover:scale-110 transition-transform" />
              <span className="text-xs font-semibold text-foreground">Inspect AI Solves</span>
            </Link>

            <Link
              href="/scanner"
              className="flex flex-col items-center justify-center p-3 rounded-xl border border-border bg-background hover:border-emerald-500 hover:bg-accent transition-all text-center group"
            >
              <Camera size={20} className="text-emerald-500 mb-1.5 group-hover:scale-110 transition-transform" />
              <span className="text-xs font-semibold text-foreground">OCR Reviews</span>
            </Link>

            <Link
              href="/themes"
              className="flex flex-col items-center justify-center p-3 rounded-xl border border-border bg-background hover:border-pink-500 hover:bg-accent transition-all text-center group"
            >
              <Palette size={20} className="text-pink-500 mb-1.5 group-hover:scale-110 transition-transform" />
              <span className="text-xs font-semibold text-foreground">9 Theme Presets</span>
            </Link>

            <Link
              href="/settings/ai"
              className="flex flex-col items-center justify-center p-3 rounded-xl border border-border bg-background hover:border-amber-500 hover:bg-accent transition-all text-center group"
            >
              <Cpu size={20} className="text-amber-500 mb-1.5 group-hover:scale-110 transition-transform" />
              <span className="text-xs font-semibold text-foreground">Groq & AI Config</span>
            </Link>

            <Link
              href="/notifications"
              className="flex flex-col items-center justify-center p-3 rounded-xl border border-border bg-background hover:border-indigo-500 hover:bg-accent transition-all text-center group"
            >
              <Bell size={20} className="text-indigo-500 mb-1.5 group-hover:scale-110 transition-transform" />
              <span className="text-xs font-semibold text-foreground">Send Push Alert</span>
            </Link>
          </div>
        </div>

        {/* Charts Grid Row 1: User Growth & AI Solving Telemetry */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Chart 1: User Growth & Daily Calculations */}
          <div className="p-6 rounded-2xl border border-border bg-card shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-sm font-bold text-foreground">User Growth & Calculation Activity</h3>
                <p className="text-xs text-muted-foreground">Daily registered users vs calculation volume</p>
              </div>
              <span className="text-[11px] font-bold text-blue-500 bg-blue-500/10 px-2 py-0.5 rounded-full">
                +14.2% Growth
              </span>
            </div>
            <div className="h-64 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={growthData}>
                  <defs>
                    <linearGradient id="userGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#3B82F6" stopOpacity={0.0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="date" stroke="hsl(var(--muted-foreground))" fontSize={11} />
                  <YAxis stroke="hsl(var(--muted-foreground))" fontSize={11} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      borderColor: "hsl(var(--border))",
                      borderRadius: "12px",
                      fontSize: "12px",
                    }}
                  />
                  <Area type="monotone" dataKey="users" stroke="#3B82F6" strokeWidth={2.5} fillOpacity={1} fill="url(#userGrad)" name="Total Users" />
                  <Area type="monotone" dataKey="calculations" stroke="#10B981" strokeWidth={2} fillOpacity={0} name="Calculations" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Chart 2: AI Solving Telemetry & Daily Groq Spend */}
          <div className="p-6 rounded-2xl border border-border bg-card shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-sm font-bold text-foreground">AI Solves & Verification Quality</h3>
                <p className="text-xs text-muted-foreground">Verified solutions vs failed requests</p>
              </div>
              <span className="text-[11px] font-bold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full">
                97.5% Verified
              </span>
            </div>
            <div className="h-64 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={aiData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="date" stroke="hsl(var(--muted-foreground))" fontSize={11} />
                  <YAxis stroke="hsl(var(--muted-foreground))" fontSize={11} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      borderColor: "hsl(var(--border))",
                      borderRadius: "12px",
                      fontSize: "12px",
                    }}
                  />
                  <Bar dataKey="verified" fill="#8B5CF6" radius={[4, 4, 0, 0]} name="Verified Solves" />
                  <Bar dataKey="failed" fill="#EF4444" radius={[4, 4, 0, 0]} name="Failed / Retried" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Charts Grid Row 2: Platform Share & Question Categories */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Donut Chart: Mobile Platforms */}
          <div className="p-6 rounded-2xl border border-border bg-card shadow-sm">
            <h3 className="text-sm font-bold text-foreground mb-1">Mobile Platform Share</h3>
            <p className="text-xs text-muted-foreground mb-4">Active devices by OS</p>
            <div className="h-44 w-full flex items-center justify-center">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={platforms} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={45} outerRadius={68} paddingAngle={4}>
                    {platforms.map((p, idx) => (
                      <Cell key={idx} fill={p.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="space-y-1.5 mt-2">
              {platforms.map((p, idx) => (
                <div key={idx} className="flex items-center justify-between text-xs">
                  <span className="flex items-center gap-2 text-muted-foreground">
                    <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: p.color }} />
                    {p.name.split(" ")[0]}
                  </span>
                  <span className="font-bold text-foreground">{p.value}% ({formatNumber(p.count)})</span>
                </div>
              ))}
            </div>
          </div>

          {/* Question Categories Breakdown */}
          <div className="p-6 rounded-2xl border border-border bg-card shadow-sm">
            <h3 className="text-sm font-bold text-foreground mb-1">Question Subject Breakdown</h3>
            <p className="text-xs text-muted-foreground mb-4">AI solved problem topics</p>
            <div className="space-y-3">
              {categories.map((cat, idx) => (
                <div key={idx} className="space-y-1">
                  <div className="flex justify-between text-xs">
                    <span className="font-semibold text-foreground">{cat.name}</span>
                    <span className="text-muted-foreground">{cat.value}% ({cat.count})</span>
                  </div>
                  <div className="w-full h-2 rounded-full bg-muted overflow-hidden">
                    <div className="h-full rounded-full transition-all" style={{ width: `${cat.value}%`, backgroundColor: cat.color }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Popular Calculator Functions */}
          <div className="p-6 rounded-2xl border border-border bg-card shadow-sm">
            <h3 className="text-sm font-bold text-foreground mb-1">Top Calculator Functions</h3>
            <p className="text-xs text-muted-foreground mb-4">Most executed operations</p>
            <div className="space-y-2.5">
              {functionStats.slice(0, 5).map((f, idx) => (
                <div key={idx} className="flex items-center justify-between p-2 rounded-xl bg-accent/40 text-xs">
                  <span className="font-mono font-bold text-foreground">{f.name}</span>
                  <span className="font-semibold text-primary">{formatNumber(f.count)} uses ({f.percentage}%)</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
