"use client";

import React, { useState } from "react";
import {
  LineChart as ChartIcon,
  Users,
  Brain,
  Calculator,
  Camera,
  TrendingUp,
  Smartphone,
  Layers,
} from "lucide-react";
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { formatNumber } from "@/lib/utils";

export default function AnalyticsPage() {
  const growthData = adminService.getUserGrowthChartData();
  const aiData = adminService.getAIUsageChartData();
  const platforms = adminService.getPlatformDistribution();

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <ChartIcon className="text-blue-500" /> Platform Analytics & Cohorts
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Deep-dive operational metrics across user retention, calculation frequency, AI latency, and mobile OS share.
          </p>
        </div>

        {/* Retention & DAU/MAU Summary */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase">Daily Active Users (DAU)</div>
            <div className="mt-2 text-2xl font-black text-foreground">{formatNumber(2410)}</div>
            <div className="text-[11px] text-emerald-500 font-bold mt-1">+8.5% vs yesterday</div>
          </div>
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase">Weekly Active Users (WAU)</div>
            <div className="mt-2 text-2xl font-black text-foreground">{formatNumber(8940)}</div>
            <div className="text-[11px] text-emerald-500 font-bold mt-1">+12.4% vs last week</div>
          </div>
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase">Monthly Active Users (MAU)</div>
            <div className="mt-2 text-2xl font-black text-foreground">{formatNumber(13200)}</div>
            <div className="text-[11px] text-blue-500 font-bold mt-1">88.8% user retention rate</div>
          </div>
        </div>

        {/* Growth Trends Chart */}
        <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
          <h3 className="text-sm font-bold text-foreground">User Growth & Retention Velocity</h3>
          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={growthData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis dataKey="date" stroke="hsl(var(--muted-foreground))" fontSize={11} />
                <YAxis stroke="hsl(var(--muted-foreground))" fontSize={11} />
                <Tooltip />
                <Area type="monotone" dataKey="users" stroke="#3B82F6" strokeWidth={2.5} fill="#3B82F6" fillOpacity={0.2} name="Total Registered Users" />
                <Area type="monotone" dataKey="active" stroke="#10B981" strokeWidth={2.5} fill="#10B981" fillOpacity={0.2} name="Active Users" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
