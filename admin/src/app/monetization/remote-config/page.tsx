"use client";

import React, { useState, useEffect } from "react";
import {
  SlidersHorizontal,
  History,
  RotateCcw,
  CheckCircle2,
  AlertTriangle,
  Radio,
  Layers,
  Save,
  Send,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { RemoteConfigVersion } from "@/types";
import { formatDate } from "@/lib/utils";
import { useAuth } from "@/lib/authContext";

export default function RemoteConfigPage() {
  const { role } = useAuth();
  const isSuperAdmin = role === "SUPER_ADMIN";

  const [versions, setVersions] = useState<RemoteConfigVersion[]>([]);
  const [primaryProvider, setPrimaryProvider] = useState("admob");
  const [appOpenCooldown, setAppOpenCooldown] = useState(15);
  const [appOpenMax, setAppOpenMax] = useState(1);
  const [bannerRefresh, setBannerRefresh] = useState(30);
  const [changeSummary, setChangeSummary] = useState("");
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const loadVersions = async () => {
    const list = await adminService.getRemoteConfigVersions();
    setVersions([...list]);
  };

  useEffect(() => {
    loadVersions();
  }, []);

  const handlePublish = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!changeSummary.trim()) return;

    await adminService.publishRemoteConfig({
      emergencyMode: "NORMAL",
      primaryProvider,
      fallbackProviders: ["network_b", "network_c", "house_ad"],
      appOpenCooldownMin: appOpenCooldown,
      appOpenMaxPerSession: appOpenMax,
      bannerRefreshSec: bannerRefresh,
      changeSummary,
    });

    setChangeSummary("");
    setToastMessage("New remote configuration version published to mobile clients!");
    setTimeout(() => setToastMessage(null), 3000);
    await loadVersions();
  };

  const handleRollback = async (verStr: string) => {
    await adminService.rollbackRemoteConfig(verStr);
    setToastMessage(`Successfully rolled back active remote configuration to ${verStr}!`);
    setTimeout(() => setToastMessage(null), 3000);
    await loadVersions();
  };

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <SlidersHorizontal className="text-indigo-500" /> Remote Ad Configuration & Rollback Engine
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Dynamically adjust mobile ad parameters, frequency limits, and rollback configuration releases instantly.
          </p>
        </div>

        {toastMessage && (
          <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-xs font-bold flex items-center gap-2">
            <CheckCircle2 size={16} />
            {toastMessage}
          </div>
        )}

        {/* Configuration Publisher Form */}
        {isSuperAdmin && (
          <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
            <div className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
              <Send size={14} className="text-primary" /> Publish New Configuration Release
            </div>

            <form onSubmit={handlePublish} className="space-y-4 text-xs">
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block font-bold mb-1">Primary Ad Network</label>
                  <select
                    value={primaryProvider}
                    onChange={(e) => setPrimaryProvider(e.target.value)}
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground font-semibold focus:outline-none"
                  >
                    <option value="admob">Google AdMob (Recommended)</option>
                    <option value="network_b">Network B (AppLovin MAX)</option>
                    <option value="network_c">Network C (Unity Ads)</option>
                    <option value="house_ad">SolveCalc House Ads</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold mb-1">App-Open Cooldown (Minutes)</label>
                  <input
                    type="number"
                    min={1}
                    max={120}
                    value={appOpenCooldown}
                    onChange={(e) => setAppOpenCooldown(parseInt(e.target.value) || 15)}
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground font-mono focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Banner Refresh Interval (Seconds)</label>
                  <input
                    type="number"
                    min={10}
                    max={120}
                    value={bannerRefresh}
                    onChange={(e) => setBannerRefresh(parseInt(e.target.value) || 30)}
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground font-mono focus:outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block font-bold mb-1">Changelog / Release Summary Note</label>
                <input
                  type="text"
                  required
                  value={changeSummary}
                  onChange={(e) => setChangeSummary(e.target.value)}
                  placeholder="e.g. Set banner refresh interval to 30s and enabled Network B fallback."
                  className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none focus:border-primary"
                />
              </div>

              <div className="flex justify-end">
                <button
                  type="submit"
                  className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-primary text-primary-foreground font-bold shadow-md shadow-primary/20 hover:bg-primary/90 transition-all"
                >
                  <Save size={14} />
                  <span>Publish Versioned Config</span>
                </button>
              </div>
            </form>
          </div>
        )}

        {/* Version History & Rollback Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="p-4 border-b border-border bg-muted/20 text-xs font-bold text-foreground flex items-center gap-2">
            <History size={14} className="text-blue-500" /> Release Version History & Rollback Matrix
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">Version</th>
                  <th className="py-3 px-4">Published By</th>
                  <th className="py-3 px-4">Primary Network</th>
                  <th className="py-3 px-4">Cooldown</th>
                  <th className="py-3 px-4">Release Note</th>
                  <th className="py-3 px-4">Date</th>
                  {isSuperAdmin && <th className="py-3 px-4 text-right">Rollback</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {versions.map((ver) => (
                  <tr key={ver.version} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4">
                      <div className="font-bold text-foreground flex items-center gap-1.5">
                        {ver.version}
                        {ver.isActive && (
                          <span className="px-2 py-0.2 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-500">
                            Active
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-foreground">{ver.publishedBy}</td>
                    <td className="py-3.5 px-4 font-mono text-muted-foreground">{ver.primaryProvider}</td>
                    <td className="py-3.5 px-4 font-mono text-foreground">{ver.appOpenCooldownMin}m</td>
                    <td className="py-3.5 px-4 text-muted-foreground max-w-xs truncate">
                      {ver.changeSummary}
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{formatDate(ver.publishedAt)}</td>
                    {isSuperAdmin && (
                      <td className="py-3.5 px-4 text-right">
                        {!ver.isActive && (
                          <button
                            onClick={() => handleRollback(ver.version)}
                            className="flex items-center gap-1 ml-auto px-2.5 py-1 rounded-lg border border-border bg-background hover:bg-accent text-[11px] font-semibold text-foreground"
                          >
                            <RotateCcw size={12} />
                            <span>Rollback</span>
                          </button>
                        )}
                      </td>
                    )}
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
