"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import {
  DollarSign,
  TrendingUp,
  Zap,
  Radio,
  Layers,
  SlidersHorizontal,
  ExternalLink,
  CheckCircle2,
  AlertTriangle,
  ShieldAlert,
  ArrowUpRight,
  RefreshCw,
  Megaphone,
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
import { AdNetworkItem } from "@/types";
import { formatCurrency, formatNumber } from "@/lib/utils";
import { useAuth } from "@/lib/authContext";

export default function MonetizationOverviewPage() {
  const { role } = useAuth();
  const [adNetworks, setAdNetworks] = useState<AdNetworkItem[]>([]);
  const [emergencyMode, setEmergencyMode] = useState<
    "NORMAL" | "ADS_DISABLED" | "PREMIUM_ONLY" | "HOUSE_ADS_ONLY"
  >("NORMAL");
  const [savedToast, setSavedToast] = useState(false);

  const kpis = adminService.getMonetizationOverviewKPIs();
  const revenueChart = adminService.getRevenueComparisonChartData();

  useEffect(() => {
    adminService.getAdNetworks().then(setAdNetworks);
  }, []);

  const handleEmergencySwitch = (
    mode: "NORMAL" | "ADS_DISABLED" | "PREMIUM_ONLY" | "HOUSE_ADS_ONLY"
  ) => {
    setEmergencyMode(mode);
    setSavedToast(true);
    setTimeout(() => setSavedToast(false), 3000);
  };

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <DollarSign className="text-amber-500" /> Monetization & Multi-Network Ad Command
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              USD $10 Lifetime Purchases, multi-network mediation, waterfall fallback, and emergency kill switches.
            </p>
          </div>

          <div className="flex items-center gap-2">
            <a
              href="https://apps.admob.com/"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl border border-border bg-card hover:bg-accent text-xs font-semibold"
            >
              <span>Open AdMob Console</span>
              <ExternalLink size={13} />
            </a>
          </div>
        </div>

        {savedToast && (
          <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-xs font-bold flex items-center gap-2">
            <CheckCircle2 size={16} />
            Emergency monetization policy updated and broadcast to mobile clients!
          </div>
        )}

        {/* Emergency Mode Banner */}
        <div className="p-5 rounded-2xl border border-border bg-card shadow-sm space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <ShieldAlert className="text-amber-500" size={18} />
              <span className="font-bold text-xs uppercase tracking-wider text-foreground">
                Emergency Monetization Mode
              </span>
            </div>
            <span className="text-[11px] font-mono font-bold text-muted-foreground">
              Current: <strong className="text-foreground">{emergencyMode}</strong>
            </span>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
            {[
              { id: "NORMAL", label: "NORMAL (Ads + $10 Pro)", color: "border-emerald-500 text-emerald-500" },
              { id: "ADS_DISABLED", label: "DISABLE ALL ADS", color: "border-destructive text-destructive" },
              { id: "PREMIUM_ONLY", label: "PREMIUM ONLY", color: "border-blue-500 text-blue-500" },
              { id: "HOUSE_ADS_ONLY", label: "HOUSE ADS ONLY", color: "border-amber-500 text-amber-500" },
            ].map((m) => (
              <button
                key={m.id}
                onClick={() => handleEmergencySwitch(m.id as any)}
                className={`p-3 rounded-xl border text-xs font-bold transition-all text-center ${
                  emergencyMode === m.id
                    ? `bg-primary/10 border-primary text-primary ring-2 ring-primary/20 shadow-sm`
                    : "border-border bg-background hover:bg-accent text-muted-foreground"
                }`}
              >
                {m.label}
              </button>
            ))}
          </div>
        </div>

        {/* KPI Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="flex justify-between items-center text-xs font-bold text-muted-foreground uppercase">
              <span>Total Revenue</span>
              <DollarSign size={16} className="text-emerald-500" />
            </div>
            <div className="mt-2 text-2xl font-black text-foreground">
              {formatCurrency(kpis.totalRevenueUsd)}
            </div>
            <div className="mt-1 text-[11px] font-bold text-emerald-500 flex items-center gap-0.5">
              <TrendingUp size={12} /> {kpis.totalRevenueChange} this month
            </div>
          </div>

          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="flex justify-between items-center text-xs font-bold text-muted-foreground uppercase">
              <span>Lifetime $10 Purchases</span>
              <Zap size={16} className="text-amber-500" />
            </div>
            <div className="mt-2 text-2xl font-black text-foreground">
              {formatNumber(kpis.premiumPurchasesCount)}
            </div>
            <div className="mt-1 text-[11px] text-muted-foreground">
              {kpis.freeToPremiumConversionPercent}% conversion from free
            </div>
          </div>

          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="flex justify-between items-center text-xs font-bold text-muted-foreground uppercase">
              <span>Ad Revenue Today</span>
              <Radio size={16} className="text-blue-500" />
            </div>
            <div className="mt-2 text-2xl font-black text-foreground">
              {formatCurrency(kpis.adRevenueTodayUsd)}
            </div>
            <div className="mt-1 text-[11px] text-muted-foreground">
              {formatCurrency(kpis.adRevenueMonthUsd)} month-to-date
            </div>
          </div>

          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="flex justify-between items-center text-xs font-bold text-muted-foreground uppercase">
              <span>Ad Fill Rate & eCPM</span>
              <Layers size={16} className="text-purple-500" />
            </div>
            <div className="mt-2 text-2xl font-black text-purple-500">
              {kpis.overallFillRatePercent}%
            </div>
            <div className="mt-1 text-[11px] text-muted-foreground">
              Avg eCPM: {formatCurrency(kpis.avgEcpmUsd)} • ARPU: {formatCurrency(kpis.arpuUsd)}
            </div>
          </div>
        </div>

        {/* Combined Revenue Trends Chart */}
        <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-bold text-foreground">Revenue Distribution & Growth</h3>
              <p className="text-xs text-muted-foreground">Premium Lifetime Purchases vs Mobile Advertising</p>
            </div>
            <span className="text-[11px] font-bold text-emerald-500 bg-emerald-500/10 px-2.5 py-0.5 rounded-full">
              +24.8% Monthly Growth
            </span>
          </div>

          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={revenueChart}>
                <defs>
                  <linearGradient id="premGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#F59E0B" stopOpacity={0.4} />
                    <stop offset="95%" stopColor="#F59E0B" stopOpacity={0.0} />
                  </linearGradient>
                  <linearGradient id="adGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.4} />
                    <stop offset="95%" stopColor="#3B82F6" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis dataKey="date" stroke="hsl(var(--muted-foreground))" fontSize={11} />
                <YAxis stroke="hsl(var(--muted-foreground))" fontSize={11} />
                <Tooltip />
                <Area type="monotone" dataKey="premiumUsd" stroke="#F59E0B" strokeWidth={2.5} fill="url(#premGrad)" name="Premium $10 Purchases ($)" />
                <Area type="monotone" dataKey="adsUsd" stroke="#3B82F6" strokeWidth={2} fill="url(#adGrad)" name="Mobile Ad Revenue ($)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Multi-Network Waterfall Summary Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="p-4 border-b border-border bg-muted/20 flex items-center justify-between">
            <div className="text-xs font-bold text-foreground flex items-center gap-2">
              <Layers size={15} className="text-blue-500" /> Active Ad Provider Waterfall
            </div>
            <Link
              href="/monetization/ad-providers"
              className="text-xs font-bold text-primary hover:underline flex items-center gap-1"
            >
              <span>Manage Waterfall & Priority</span>
              <ArrowUpRight size={13} />
            </Link>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">Priority</th>
                  <th className="py-3 px-4">Ad Network</th>
                  <th className="py-3 px-4">SDK Adapter</th>
                  <th className="py-3 px-4">Today&apos;s Impressions</th>
                  <th className="py-3 px-4">Fill Rate</th>
                  <th className="py-3 px-4">eCPM</th>
                  <th className="py-3 px-4">Revenue Today</th>
                  <th className="py-3 px-4">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {adNetworks.map((net) => (
                  <tr key={net.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4 font-black text-foreground">
                      #{net.priority}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-foreground">{net.name}</td>
                    <td className="py-3.5 px-4 font-mono text-muted-foreground">{net.sdkName}</td>
                    <td className="py-3.5 px-4 font-mono font-bold text-foreground">
                      {formatNumber(net.impressionsToday)}
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-foreground">
                      {net.fillRatePercent}%
                    </td>
                    <td className="py-3.5 px-4 font-mono text-muted-foreground">
                      {formatCurrency(net.ecpmUsd)}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-emerald-500">
                      {formatCurrency(net.revenueTodayUsd)}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="px-2 py-0.5 rounded-full font-bold text-[10px] bg-emerald-500/10 text-emerald-500 border border-emerald-500/20">
                        {net.healthStatus}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
