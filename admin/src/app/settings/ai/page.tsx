"use client";

import React, { useState, useEffect } from "react";
import {
  Cpu,
  Shield,
  Key,
  DollarSign,
  AlertTriangle,
  CheckCircle2,
  Sliders,
  Sparkles,
  Save,
  Zap,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { AIProviderConfig } from "@/types";
import { formatCurrency } from "@/lib/utils";

export default function AISettingsPage() {
  const [providers, setProviders] = useState<AIProviderConfig[]>([]);
  const [isSavedToast, setIsSavedToast] = useState(false);

  useEffect(() => {
    adminService.getAIProviders().then(setProviders);
  }, []);

  const handleTogglePrimary = async (id: string) => {
    await adminService.setPrimaryAIProvider(id);
    const updated = await adminService.getAIProviders();
    setProviders([...updated]);
  };

  const handleSave = () => {
    setIsSavedToast(true);
    setTimeout(() => setIsSavedToast(false), 3000);
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Cpu className="text-amber-500" /> AI Provider & Cost Architecture
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Configure primary & fallback LLM endpoints, token limits, and daily expense safeguards.
            </p>
          </div>

          <button
            onClick={handleSave}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold shadow-md shadow-primary/20 hover:bg-primary/90 transition-all"
          >
            <Save size={14} />
            <span>Save AI Configuration</span>
          </button>
        </div>

        {isSavedToast && (
          <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-xs font-bold flex items-center gap-2 animate-in fade-in">
            <CheckCircle2 size={16} />
            AI Provider and cost threshold configuration saved successfully!
          </div>
        )}

        {/* AI Cost Telemetry Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase flex items-center gap-1.5">
              <DollarSign size={14} className="text-emerald-500" />
              Today&apos;s AI Spending
            </div>
            <div className="mt-2 text-2xl font-black text-foreground">{formatCurrency(5.77)}</div>
            <div className="text-[11px] text-muted-foreground mt-1">Daily cap: $50.00 USD (11.5% utilized)</div>
          </div>

          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase flex items-center gap-1.5">
              <DollarSign size={14} className="text-blue-500" />
              Month-to-Date Spend
            </div>
            <div className="mt-2 text-2xl font-black text-foreground">{formatCurrency(180.9)}</div>
            <div className="text-[11px] text-muted-foreground mt-1">Monthly cap: $1,200.00 USD (15.1% utilized)</div>
          </div>

          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase flex items-center gap-1.5">
              <Zap size={14} className="text-amber-500" />
              Average Cost Per Solution
            </div>
            <div className="mt-2 text-2xl font-black text-amber-500">$0.0018</div>
            <div className="text-[11px] text-muted-foreground mt-1">Groq Llama-3.3 high token efficiency</div>
          </div>
        </div>

        {/* Configured AI Providers List */}
        <div className="space-y-4">
          <div className="text-xs font-bold uppercase text-muted-foreground tracking-wider">
            Active Provider Endpoints
          </div>

          {providers.map((p) => (
            <div
              key={p.id}
              className={`p-6 rounded-2xl border bg-card transition-all ${
                p.isPrimary
                  ? "border-primary shadow-md shadow-primary/10"
                  : "border-border"
              }`}
            >
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-border pb-4 mb-4">
                <div className="flex items-center gap-3">
                  <div
                    className={`p-2.5 rounded-xl ${
                      p.isPrimary
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted text-muted-foreground"
                    }`}
                  >
                    <Cpu size={20} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-bold text-sm text-foreground">{p.name}</h3>
                      {p.isPrimary && (
                        <span className="px-2 py-0.5 rounded-full bg-primary/10 text-primary border border-primary/20 text-[10px] font-black">
                          PRIMARY SOLVER
                        </span>
                      )}
                      {p.isFallback && (
                        <span className="px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-500 border border-amber-500/20 text-[10px] font-black">
                          FALLBACK
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-muted-foreground mt-0.5">Model: {p.model}</div>
                  </div>
                </div>

                {!p.isPrimary && (
                  <button
                    onClick={() => handleTogglePrimary(p.id)}
                    className="px-3 py-1.5 rounded-xl border border-border bg-background hover:bg-accent text-xs font-semibold"
                  >
                    Set as Primary
                  </button>
                )}
              </div>

              {/* Parameter Settings Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                <div>
                  <label className="block text-[11px] font-bold text-muted-foreground mb-1">
                    API Key (Encrypted Secret)
                  </label>
                  <input
                    type="text"
                    readOnly
                    value={p.apiKeyMasked}
                    className="w-full p-2 rounded-xl border border-border bg-background font-mono text-muted-foreground"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-bold text-muted-foreground mb-1">
                    Timeout Limit (ms)
                  </label>
                  <input
                    type="number"
                    defaultValue={p.timeoutMs}
                    className="w-full p-2 rounded-xl border border-border bg-background font-mono text-foreground focus:outline-none focus:border-primary"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-bold text-muted-foreground mb-1">
                    Max Generation Tokens
                  </label>
                  <input
                    type="number"
                    defaultValue={p.maxTokens}
                    className="w-full p-2 rounded-xl border border-border bg-background font-mono text-foreground focus:outline-none focus:border-primary"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
