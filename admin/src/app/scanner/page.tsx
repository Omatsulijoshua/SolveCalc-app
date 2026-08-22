"use client";

import React, { useState, useEffect } from "react";
import {
  Camera,
  CheckCircle2,
  AlertTriangle,
  FileCheck2,
  Clock,
  Sparkles,
  ArrowRight,
  Eye,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { ScanRecord } from "@/types";
import { formatDate } from "@/lib/utils";

export default function ScannerPage() {
  const [scans, setScans] = useState<ScanRecord[]>([]);
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [selectedScan, setSelectedScan] = useState<ScanRecord | null>(null);

  useEffect(() => {
    adminService.getScans(statusFilter).then(setScans);
  }, [statusFilter]);

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <Camera className="text-emerald-500" /> Scanner & OCR Quality Operations
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Groq Vision camera math recognition telemetry, OCR confidence scores, and manual correction logs.
          </p>
        </div>

        {/* OCR Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase">OCR Recognition Rate</div>
            <div className="mt-2 text-2xl font-black text-emerald-500">96.8%</div>
            <div className="text-[11px] text-muted-foreground mt-1">1,480 total scans captured today</div>
          </div>
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase">Average OCR Latency</div>
            <div className="mt-2 text-2xl font-black text-blue-500">650 ms</div>
            <div className="text-[11px] text-muted-foreground mt-1">Groq Vision Llama-3.2-Vision model</div>
          </div>
          <div className="p-5 rounded-2xl border border-border bg-card shadow-sm">
            <div className="text-xs font-bold text-muted-foreground uppercase">User Manual Correction Rate</div>
            <div className="mt-2 text-2xl font-black text-amber-500">3.2%</div>
            <div className="text-[11px] text-muted-foreground mt-1">Users edited equation before solving</div>
          </div>
        </div>

        {/* Filters */}
        <div className="flex items-center gap-2">
          {["ALL", "SUCCESS", "MANUALLY_CORRECTED", "FAILED"].map((st) => (
            <button
              key={st}
              onClick={() => setStatusFilter(st)}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                statusFilter === st
                  ? "bg-primary text-primary-foreground font-bold shadow-sm"
                  : "bg-card border border-border text-muted-foreground hover:text-foreground"
              }`}
            >
              {st === "ALL" ? "All Scans" : st.replace("_", " ")}
            </button>
          ))}
        </div>

        {/* Scanned Questions Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">User</th>
                  <th className="py-3 px-4">Raw OCR Recognition</th>
                  <th className="py-3 px-4">Corrected Equation</th>
                  <th className="py-3 px-4">Confidence</th>
                  <th className="py-3 px-4">Latency</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Timestamp</th>
                  <th className="py-3 px-4 text-right">Review</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {scans.map((s) => (
                  <tr key={s.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-foreground">{s.userName}</td>
                    <td className="py-3.5 px-4 font-mono font-bold text-blue-500">{s.rawOcrText}</td>
                    <td className="py-3.5 px-4 font-mono text-foreground">
                      {s.correctedText ? (
                        <span className="font-bold text-amber-500">{s.correctedText}</span>
                      ) : (
                        <span className="text-muted-foreground">None (Exact match)</span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-foreground">
                      {(s.confidence * 100).toFixed(0)}%
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{s.latencyMs} ms</td>
                    <td className="py-3.5 px-4">
                      {s.status === "SUCCESS" && (
                        <span className="px-2 py-0.5 rounded-full font-bold text-[10px] bg-emerald-500/10 text-emerald-500 border border-emerald-500/20">
                          SUCCESS
                        </span>
                      )}
                      {s.status === "MANUALLY_CORRECTED" && (
                        <span className="px-2 py-0.5 rounded-full font-bold text-[10px] bg-amber-500/10 text-amber-500 border border-amber-500/20">
                          CORRECTED
                        </span>
                      )}
                      {s.status === "FAILED" && (
                        <span className="px-2 py-0.5 rounded-full font-bold text-[10px] bg-destructive/10 text-destructive border border-destructive/20">
                          FAILED
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{formatDate(s.timestamp)}</td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        onClick={() => setSelectedScan(s)}
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

        {/* Side-by-side OCR Review Modal */}
        {selectedScan && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-xl rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-6 animate-in zoom-in-95">
              <div className="flex items-center justify-between border-b border-border pb-4">
                <div className="flex items-center gap-2.5">
                  <Camera className="text-emerald-500" />
                  <h3 className="font-bold text-base text-foreground">OCR Vision Comparison</h3>
                </div>
                <button onClick={() => setSelectedScan(null)} className="text-muted-foreground hover:text-foreground">
                  ✕
                </button>
              </div>

              {/* Side-by-side Cards */}
              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 rounded-xl bg-accent/30 border border-border space-y-2">
                  <div className="text-[10px] font-bold uppercase text-muted-foreground">Raw OCR Recognition</div>
                  <div className="font-mono text-sm font-bold text-blue-500 bg-background p-3 rounded-lg border border-border">
                    {selectedScan.rawOcrText}
                  </div>
                </div>

                <div className="p-4 rounded-xl bg-accent/30 border border-border space-y-2">
                  <div className="text-[10px] font-bold uppercase text-muted-foreground">User Corrected Input</div>
                  <div className="font-mono text-sm font-bold text-emerald-500 bg-background p-3 rounded-lg border border-border">
                    {selectedScan.correctedText || selectedScan.rawOcrText}
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-xs">
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Confidence Score</span>
                  <span className="font-bold text-foreground">{(selectedScan.confidence * 100).toFixed(1)}%</span>
                </div>
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Processing Latency</span>
                  <span className="font-bold text-foreground">{selectedScan.latencyMs} ms</span>
                </div>
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Scanned By</span>
                  <span className="font-bold text-foreground">{selectedScan.userName} ({selectedScan.userId})</span>
                </div>
              </div>

              <div className="flex justify-end gap-2">
                <button
                  onClick={() => setSelectedScan(null)}
                  className="px-4 py-2 rounded-xl border border-border text-xs font-semibold hover:bg-accent"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
