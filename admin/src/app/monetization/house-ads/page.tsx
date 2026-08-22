"use client";

import React, { useState, useEffect } from "react";
import {
  Megaphone,
  Plus,
  CheckCircle2,
  TrendingUp,
  MousePointerClick,
  Eye,
  X,
  Smartphone,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { HouseAdCampaign } from "@/types";
import { formatNumber } from "@/lib/utils";

export default function HouseAdsPage() {
  const [campaigns, setCampaigns] = useState<HouseAdCampaign[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [ctaText, setCtaText] = useState("LEARN MORE");
  const [destination, setDestination] = useState("paywall");

  const loadCampaigns = async () => {
    const list = await adminService.getHouseAds();
    setCampaigns([...list]);
  };

  useEffect(() => {
    loadCampaigns();
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !description.trim()) return;

    await adminService.createHouseAd({
      title,
      description,
      ctaText,
      destination,
      isActive: true,
      priority: campaigns.length + 1,
    });

    setTitle("");
    setDescription("");
    setShowModal(false);
    await loadCampaigns();
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Megaphone className="text-amber-500" /> House Advertising & Promotion Engine
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Self-hosted promotional campaigns displayed when external ad networks produce zero fill or low eCPM.
            </p>
          </div>

          <button
            onClick={() => setShowModal(true)}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold shadow-md shadow-primary/20 hover:bg-primary/90"
          >
            <Plus size={14} />
            <span>Create Campaign</span>
          </button>
        </div>

        {/* Campaigns Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {campaigns.map((c) => (
            <div key={c.id} className="p-5 rounded-2xl border border-border bg-card shadow-sm space-y-4 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-muted text-muted-foreground">
                    Priority #{c.priority}
                  </span>
                  <span className="flex items-center gap-1 text-[10px] font-bold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full">
                    <CheckCircle2 size={11} /> Active
                  </span>
                </div>

                <h3 className="font-bold text-sm text-foreground mt-3">{c.title}</h3>
                <p className="text-xs text-muted-foreground mt-1 leading-relaxed">{c.description}</p>
              </div>

              <div className="space-y-3 pt-3 border-t border-border">
                <div className="grid grid-cols-3 gap-2 text-center text-xs">
                  <div className="p-2 rounded-xl bg-muted/40">
                    <div className="text-[10px] text-muted-foreground uppercase font-bold">Impressions</div>
                    <div className="font-mono font-bold text-foreground mt-0.5">{formatNumber(c.impressions)}</div>
                  </div>
                  <div className="p-2 rounded-xl bg-muted/40">
                    <div className="text-[10px] text-muted-foreground uppercase font-bold">Clicks</div>
                    <div className="font-mono font-bold text-blue-500 mt-0.5">{formatNumber(c.clicks)}</div>
                  </div>
                  <div className="p-2 rounded-xl bg-muted/40">
                    <div className="text-[10px] text-muted-foreground uppercase font-bold">CTR</div>
                    <div className="font-mono font-bold text-emerald-500 mt-0.5">{c.ctrPercent}%</div>
                  </div>
                </div>

                <div className="flex items-center justify-between text-[11px]">
                  <span className="text-muted-foreground font-semibold">CTA Button:</span>
                  <span className="px-2 py-0.5 rounded bg-primary/10 text-primary font-black">{c.ctaText}</span>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Modal */}
        {showModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-md rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-4 animate-in zoom-in-95">
              <div className="flex items-center justify-between border-b border-border pb-3">
                <div className="flex items-center gap-2">
                  <Megaphone className="text-primary" size={18} />
                  <h3 className="font-bold text-sm text-foreground">New House Ad Campaign</h3>
                </div>
                <button onClick={() => setShowModal(false)} className="text-muted-foreground hover:text-foreground">
                  <X size={18} />
                </button>
              </div>

              <form onSubmit={handleCreate} className="space-y-3 text-xs">
                <div>
                  <label className="block font-bold mb-1">Headline</label>
                  <input
                    type="text"
                    required
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="e.g. Try our new Casio Scientific Theme!"
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none focus:border-primary"
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Description</label>
                  <textarea
                    rows={2}
                    required
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="e.g. Vintage calculator green LCD matrix styling."
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none focus:border-primary"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block font-bold mb-1">CTA Button Text</label>
                    <input
                      type="text"
                      required
                      value={ctaText}
                      onChange={(e) => setCtaText(e.target.value)}
                      placeholder="e.g. GO PRO"
                      className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none"
                    />
                  </div>

                  <div>
                    <label className="block font-bold mb-1">App Screen Target</label>
                    <select
                      value={destination}
                      onChange={(e) => setDestination(e.target.value)}
                      className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none"
                    >
                      <option value="paywall">Pro Paywall ($10)</option>
                      <option value="themes">Themes Screen</option>
                      <option value="scanner">Camera Scanner</option>
                    </select>
                  </div>
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t border-border">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 rounded-xl border border-border font-semibold hover:bg-accent"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 rounded-xl bg-primary text-primary-foreground font-bold hover:bg-primary/90"
                  >
                    Publish Campaign
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
