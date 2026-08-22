"use client";

import React, { useState, useEffect } from "react";
import {
  Settings,
  Sliders,
  AlertTriangle,
  CheckCircle2,
  Save,
  Smartphone,
  ShieldCheck,
  Cpu,
  Layers,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { FeatureFlag } from "@/types";

export default function SettingsPage() {
  const [flags, setFlags] = useState<FeatureFlag[]>([]);
  const [maintenanceMode, setMaintenanceMode] = useState(false);
  const [maintenanceMessage, setMaintenanceMessage] = useState(
    "SolveCalc AI servers are temporarily updating for improved mathematical accuracy. Offline calculation remains fully active."
  );
  const [isSavedToast, setIsSavedToast] = useState(false);

  useEffect(() => {
    adminService.getFeatureFlags().then(setFlags);
  }, []);

  const handleToggleFlag = async (id: string) => {
    await adminService.toggleFeatureFlag(id);
    const updated = await adminService.getFeatureFlags();
    setFlags([...updated]);
  };

  const handleSave = () => {
    setIsSavedToast(true);
    setTimeout(() => setIsSavedToast(false), 3000);
  };

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Settings className="text-blue-500" /> Platform & Application Settings
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Live feature flags, remote maintenance mode, and mobile application version enforcement.
            </p>
          </div>

          <button
            onClick={handleSave}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold shadow-md shadow-primary/20 hover:bg-primary/90"
          >
            <Save size={14} />
            <span>Save Settings</span>
          </button>
        </div>

        {isSavedToast && (
          <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-xs font-bold flex items-center gap-2">
            <CheckCircle2 size={16} />
            Settings and feature flags updated successfully!
          </div>
        )}

        {/* Section 1: Real-Time Feature Flags */}
        <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
          <div className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-2">
            <Sliders size={14} className="text-primary" /> Live Mobile Feature Flags
          </div>

          <div className="divide-y divide-border">
            {flags.map((flag) => (
              <div key={flag.id} className="py-3.5 flex items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-xs text-foreground">{flag.name}</span>
                    <span className="text-[10px] font-mono px-1.5 py-0.2 rounded bg-muted text-muted-foreground">
                      {flag.key}
                    </span>
                  </div>
                  <div className="text-xs text-muted-foreground mt-0.5">{flag.description}</div>
                </div>

                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={flag.isEnabled}
                    onChange={() => handleToggleFlag(flag.id)}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-muted peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary" />
                </label>
              </div>
            ))}
          </div>
        </div>

        {/* Section 2: Maintenance Mode Controls */}
        <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <AlertTriangle className="text-amber-500" size={18} />
              <h3 className="font-bold text-sm text-foreground">AI Remote Maintenance Mode</h3>
            </div>

            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={maintenanceMode}
                onChange={(e) => setMaintenanceMode(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-muted peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500" />
            </label>
          </div>

          <p className="text-xs text-muted-foreground">
            When enabled, mobile AI requests display a controlled notice while normal calculations continue operating offline.
          </p>

          {maintenanceMode && (
            <div>
              <label className="block text-xs font-bold mb-1">User Notice Message</label>
              <textarea
                rows={2}
                value={maintenanceMessage}
                onChange={(e) => setMaintenanceMessage(e.target.value)}
                className="w-full p-2.5 rounded-xl border border-border bg-background text-xs text-foreground focus:outline-none focus:border-primary"
              />
            </div>
          )}
        </div>

        {/* Section 3: App Version Enforcement */}
        <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
          <div className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-2">
            <Smartphone size={14} className="text-blue-500" /> Mobile Version Management
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
            <div>
              <label className="block text-[11px] font-bold text-muted-foreground mb-1">
                Latest App Version
              </label>
              <input
                type="text"
                defaultValue="1.0.4"
                className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground font-mono font-bold"
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-muted-foreground mb-1">
                Minimum Supported Android Version
              </label>
              <input
                type="text"
                defaultValue="1.0.2"
                className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground font-mono"
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-muted-foreground mb-1">
                Minimum Supported iOS Version
              </label>
              <input
                type="text"
                defaultValue="1.0.2"
                className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground font-mono"
              />
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
