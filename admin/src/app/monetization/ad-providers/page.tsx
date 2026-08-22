"use client";

import React, { useState, useEffect } from "react";
import {
  Layers,
  ArrowUp,
  ArrowDown,
  CheckCircle2,
  AlertTriangle,
  Radio,
  ExternalLink,
  ShieldCheck,
  Zap,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { AdNetworkItem } from "@/types";
import { formatCurrency, formatNumber } from "@/lib/utils";
import { useAuth } from "@/lib/authContext";

export default function AdProvidersPage() {
  const { role } = useAuth();
  const [networks, setNetworks] = useState<AdNetworkItem[]>([]);
  const isSuperAdmin = role === "SUPER_ADMIN";

  const loadNetworks = async () => {
    const list = await adminService.getAdNetworks();
    setNetworks([...list]);
  };

  useEffect(() => {
    loadNetworks();
  }, []);

  const handleToggle = async (id: string) => {
    await adminService.toggleAdNetwork(id);
    await loadNetworks();
  };

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Layers className="text-blue-500" /> Multi-Network Providers & Waterfall
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Control active mobile SDK adapters, priority waterfall hierarchy, and placement formats.
            </p>
          </div>

          <a
            href="https://apps.admob.com/"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl border border-border bg-card hover:bg-accent text-xs font-semibold"
          >
            <span>Google AdMob Portal</span>
            <ExternalLink size={13} />
          </a>
        </div>

        {/* Networks Waterfall Cards */}
        <div className="space-y-4">
          {networks.map((net, index) => (
            <div
              key={net.id}
              className={`p-6 rounded-2xl border bg-card shadow-sm transition-all ${
                net.isEnabled ? "border-border" : "border-border/50 opacity-60"
              }`}
            >
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div className="flex items-start gap-3.5">
                  <div className="h-10 w-10 rounded-xl bg-muted flex items-center justify-center font-black text-sm text-foreground shrink-0">
                    #{net.priority}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-bold text-sm text-foreground">{net.name}</h3>
                      <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-muted text-muted-foreground">
                        {net.sdkName}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="flex items-center gap-1 text-[11px] font-bold text-emerald-500 bg-emerald-500/10 px-2 py-0.2 rounded-full">
                        <CheckCircle2 size={11} /> {net.healthStatus}
                      </span>
                      <span className="text-[11px] text-muted-foreground">• Checked: {net.lastHealthCheck}</span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-6">
                  {/* Performance stats */}
                  <div className="grid grid-cols-3 gap-4 text-center sm:text-right">
                    <div>
                      <div className="text-[10px] uppercase font-bold text-muted-foreground">Impressions</div>
                      <div className="font-mono font-bold text-xs text-foreground">
                        {formatNumber(net.impressionsToday)}
                      </div>
                    </div>
                    <div>
                      <div className="text-[10px] uppercase font-bold text-muted-foreground">Fill Rate</div>
                      <div className="font-mono font-bold text-xs text-blue-500">{net.fillRatePercent}%</div>
                    </div>
                    <div>
                      <div className="text-[10px] uppercase font-bold text-muted-foreground">Revenue</div>
                      <div className="font-mono font-bold text-xs text-emerald-500">
                        {formatCurrency(net.revenueTodayUsd)}
                      </div>
                    </div>
                  </div>

                  {/* Enable Switch */}
                  {isSuperAdmin && (
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={net.isEnabled}
                        onChange={() => handleToggle(net.id)}
                        className="sr-only peer"
                      />
                      <div className="w-11 h-6 bg-muted peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary" />
                    </label>
                  )}
                </div>
              </div>

              {/* Supported Placements Badges */}
              <div className="mt-4 pt-3 border-t border-border flex items-center gap-2 text-[11px] text-muted-foreground">
                <span className="font-bold">Active Formats:</span>
                <span className={`px-2 py-0.5 rounded-md ${net.appOpenEnabled ? "bg-primary/10 text-primary font-bold" : "bg-muted text-muted-foreground line-through"}`}>
                  App Open
                </span>
                <span className={`px-2 py-0.5 rounded-md ${net.bannerEnabled ? "bg-primary/10 text-primary font-bold" : "bg-muted text-muted-foreground line-through"}`}>
                  Top Banner
                </span>
                <span className={`px-2 py-0.5 rounded-md ${net.nativeEnabled ? "bg-primary/10 text-primary font-bold" : "bg-muted text-muted-foreground line-through"}`}>
                  Native
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
