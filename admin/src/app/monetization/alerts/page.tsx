"use client";

import React, { useState, useEffect } from "react";
import {
  BadgeAlert,
  AlertTriangle,
  CheckCircle2,
  Info,
  Layers,
  Clock,
  ShieldCheck,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { MonetizationAlert } from "@/types";

export default function MonetizationAlertsPage() {
  const [alerts, setAlerts] = useState<MonetizationAlert[]>([]);

  useEffect(() => {
    adminService.getMonetizationAlerts().then(setAlerts);
  }, []);

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <BadgeAlert className="text-amber-500" /> Ad Network Health & Anomaly Alerts
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Real-time threshold telemetry monitoring zero-fill periods, network response timeouts, and eCPM anomalies.
          </p>
        </div>

        {/* Alerts List */}
        <div className="space-y-3">
          {alerts.map((al) => (
            <div
              key={al.id}
              className={`p-5 rounded-2xl border bg-card shadow-sm flex items-start gap-4 ${
                al.severity === "WARNING"
                  ? "border-amber-500/30 bg-amber-500/5"
                  : al.severity === "CRITICAL"
                  ? "border-destructive/30 bg-destructive/5"
                  : "border-border"
              }`}
            >
              <div className="p-2.5 rounded-xl bg-background border border-border shrink-0 mt-0.5">
                {al.severity === "WARNING" ? (
                  <AlertTriangle size={18} className="text-amber-500" />
                ) : al.severity === "CRITICAL" ? (
                  <BadgeAlert size={18} className="text-destructive" />
                ) : (
                  <Info size={18} className="text-blue-500" />
                )}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <h3 className="font-bold text-xs text-foreground">{al.title}</h3>
                  <span className="text-[10px] text-muted-foreground flex items-center gap-1">
                    <Clock size={11} /> {al.timestamp}
                  </span>
                </div>
                <p className="text-xs text-muted-foreground mt-1">{al.message}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
