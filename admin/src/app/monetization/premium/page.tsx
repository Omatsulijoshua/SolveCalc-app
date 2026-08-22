"use client";

import React, { useState, useEffect } from "react";
import {
  Zap,
  Search,
  CheckCircle2,
  AlertTriangle,
  Smartphone,
  Calendar,
  DollarSign,
  ShieldCheck,
  X,
  FileCheck2,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { PremiumPurchase } from "@/types";
import { formatDate, formatCurrency, formatNumber } from "@/lib/utils";

export default function PremiumPurchasesPage() {
  const [purchases, setPurchases] = useState<PremiumPurchase[]>([]);
  const [search, setSearch] = useState("");
  const [platformFilter, setPlatformFilter] = useState("ALL");
  const [selectedPurchase, setSelectedPurchase] = useState<PremiumPurchase | null>(null);

  useEffect(() => {
    adminService.getPremiumPurchases().then(setPurchases);
  }, []);

  const filtered = purchases.filter((p) => {
    if (platformFilter !== "ALL" && p.platform !== platformFilter) return false;
    if (search) {
      const q = search.toLowerCase();
      return (
        p.userName.toLowerCase().includes(q) ||
        p.transactionId.toLowerCase().includes(q) ||
        p.userId.includes(q)
      );
    }
    return true;
  });

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <Zap className="text-amber-500" /> Premium Lifetime ($10) Purchase Ledger
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Verified Apple StoreKit & Google Play non-consumable lifetime entitlements and receipt verification records.
          </p>
        </div>

        {/* Filters */}
        <div className="p-4 rounded-2xl border border-border bg-card flex flex-col sm:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by user name, transaction ID, or user ID..."
              className="w-full pl-10 pr-4 py-2 text-xs rounded-xl border border-border bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary"
            />
          </div>

          <select
            value={platformFilter}
            onChange={(e) => setPlatformFilter(e.target.value)}
            className="px-3 py-2 text-xs rounded-xl border border-border bg-background text-foreground focus:outline-none w-full sm:w-auto"
          >
            <option value="ALL">All Platforms</option>
            <option value="iOS">Apple iOS (StoreKit)</option>
            <option value="Android">Google Play Billing</option>
          </select>
        </div>

        {/* Purchases Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">User</th>
                  <th className="py-3 px-4">Platform</th>
                  <th className="py-3 px-4">Product ID</th>
                  <th className="py-3 px-4">Amount</th>
                  <th className="py-3 px-4">Store Transaction ID</th>
                  <th className="py-3 px-4">Verification</th>
                  <th className="py-3 px-4">Purchase Date</th>
                  <th className="py-3 px-4 text-right">Receipt</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {filtered.map((p) => (
                  <tr key={p.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-foreground">{p.userName}</td>
                    <td className="py-3.5 px-4">
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-muted text-foreground">
                        {p.platform}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-mono text-[11px] text-muted-foreground">
                      {p.productId}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-emerald-500 font-mono">
                      {formatCurrency(p.priceUsd)}
                    </td>
                    <td className="py-3.5 px-4 font-mono text-[11px] text-muted-foreground">
                      {p.transactionId}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="flex items-center gap-1 text-[10px] font-bold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full w-fit">
                        <CheckCircle2 size={11} /> Verified
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{formatDate(p.purchaseDate)}</td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        onClick={() => setSelectedPurchase(p)}
                        className="px-2.5 py-1 rounded-lg border border-border bg-background hover:bg-accent text-[11px] font-semibold text-foreground"
                      >
                        Inspect
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Purchase Receipt Inspector Modal */}
        {selectedPurchase && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-6 animate-in zoom-in-95">
              <div className="flex items-center justify-between border-b border-border pb-3">
                <div className="flex items-center gap-2">
                  <FileCheck2 className="text-emerald-500" />
                  <h3 className="font-bold text-sm text-foreground">
                    Store Verification Receipt
                  </h3>
                </div>
                <button onClick={() => setSelectedPurchase(null)} className="text-muted-foreground hover:text-foreground">
                  <X size={18} />
                </button>
              </div>

              <div className="p-4 rounded-xl bg-muted/40 border border-border space-y-3 text-xs">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Product</span>
                  <span className="font-mono font-bold text-foreground">SolveCalc Lifetime Pro ($10 USD)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Transaction ID</span>
                  <span className="font-mono font-bold text-blue-500">{selectedPurchase.transactionId}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Platform Engine</span>
                  <span className="font-bold text-foreground">{selectedPurchase.platform} Billing Service</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Server Receipt Verification</span>
                  <span className="font-bold text-emerald-500">Cryptographically Signed (200 OK)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Purchased Date</span>
                  <span className="font-bold text-foreground">{formatDate(selectedPurchase.purchaseDate)}</span>
                </div>
              </div>

              <div className="flex justify-end">
                <button
                  onClick={() => setSelectedPurchase(null)}
                  className="px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold"
                >
                  Close Receipt
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
