"use client";

import React, { useState, useEffect } from "react";
import {
  Activity,
  CheckCircle2,
  AlertTriangle,
  Server,
  Database,
  Cpu,
  RefreshCw,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { SystemHealthItem } from "@/types";

export default function SystemHealthPage() {
  const [health, setHealth] = useState<SystemHealthItem[]>([]);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadHealth = async () => {
    setIsRefreshing(true);
    const data = await adminService.getSystemHealth();
    setHealth(data);
    setTimeout(() => setIsRefreshing(false), 300);
  };

  useEffect(() => {
    loadHealth();
  }, []);

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Activity className="text-emerald-500" /> Infrastructure & System Health
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Live service status, response time latencies, database connections, and cache memory.
            </p>
          </div>

          <button
            onClick={loadHealth}
            disabled={isRefreshing}
            className="flex items-center gap-2 px-3.5 py-2 rounded-xl border border-border bg-card hover:bg-accent text-xs font-semibold"
          >
            <RefreshCw size={14} className={isRefreshing ? "animate-spin" : ""} />
            <span>Refresh Telemetry</span>
          </button>
        </div>

        {/* Health Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {health.map((item, idx) => (
            <div key={idx} className="p-5 rounded-2xl border border-border bg-card shadow-sm space-y-3">
              <div className="flex items-center justify-between">
                <span className="font-bold text-sm text-foreground">{item.name}</span>
                <span className="flex items-center gap-1 text-[11px] font-bold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full">
                  <CheckCircle2 size={12} /> {item.status}
                </span>
              </div>
              <div className="flex items-baseline gap-2">
                <span className="text-2xl font-black text-foreground font-mono">{item.latencyMs}</span>
                <span className="text-xs text-muted-foreground">ms response latency</span>
              </div>
              <div className="text-xs text-muted-foreground">{item.message}</div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
