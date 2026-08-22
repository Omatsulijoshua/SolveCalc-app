"use client";

import React, { useState, useEffect } from "react";
import {
  Brain,
  Search,
  CheckCircle2,
  AlertTriangle,
  FileCheck2,
  Clock,
  Sparkles,
  ShieldAlert,
  ArrowRight,
  Eye,
  MessageSquareWarning,
  X,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { AISolution, SolutionReport } from "@/types";
import { formatDate } from "@/lib/utils";

export default function AISolutionsPage() {
  const [activeTab, setActiveTab] = useState<"solutions" | "reports">("solutions");
  const [solutions, setSolutions] = useState<AISolution[]>([]);
  const [reports, setReports] = useState<SolutionReport[]>([]);
  const [search, setSearch] = useState("");
  const [selectedSolution, setSelectedSolution] = useState<AISolution[] | null>(null);
  const [activeSolution, setActiveSolution] = useState<AISolution | null>(null);

  const loadData = async () => {
    const s = await adminService.getAISolutions(search);
    const r = await adminService.getSolutionReports();
    setSolutions(s);
    setReports(r);
  };

  useEffect(() => {
    loadData();
  }, [search]);

  const handleResolveReport = async (id: string, newStatus: "RESOLVED" | "DISMISSED") => {
    await adminService.updateReportStatus(id, newStatus, "Handled by administrator");
    loadData();
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header & Tabs */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Brain className="text-purple-500" /> AI Mathematics Solving Engine
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Groq Cloud Llama-3.3-70b step-by-step solutions, deterministic verifications, and user accuracy reports.
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setActiveTab("solutions")}
              className={`px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
                activeTab === "solutions"
                  ? "bg-primary text-primary-foreground font-bold shadow-sm"
                  : "bg-card border border-border text-muted-foreground hover:text-foreground"
              }`}
            >
              Solutions Feed ({solutions.length})
            </button>

            <button
              onClick={() => setActiveTab("reports")}
              className={`px-3.5 py-2 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 ${
                activeTab === "reports"
                  ? "bg-primary text-primary-foreground font-bold shadow-sm"
                  : "bg-card border border-border text-muted-foreground hover:text-foreground"
              }`}
            >
              <MessageSquareWarning size={14} className="text-amber-500" />
              <span>User Reports ({reports.filter((r) => r.status === "PENDING").length} Pending)</span>
            </button>
          </div>
        </div>

        {/* Tab 1: AI Solutions Stream */}
        {activeTab === "solutions" && (
          <div className="space-y-4">
            {/* Search Input */}
            <div className="p-4 rounded-2xl border border-border bg-card flex items-center gap-3">
              <Search size={16} className="text-muted-foreground" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search mathematical question or answer (e.g. 2x + 5, integral, quadratic)..."
                className="flex-1 text-xs bg-transparent text-foreground placeholder:text-muted-foreground focus:outline-none"
              />
            </div>

            {/* Solutions Table */}
            <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                    <tr>
                      <th className="py-3 px-4">User</th>
                      <th className="py-3 px-4">Problem Question</th>
                      <th className="py-3 px-4">Category</th>
                      <th className="py-3 px-4">Final Answer</th>
                      <th className="py-3 px-4">Verification</th>
                      <th className="py-3 px-4">Provider / Model</th>
                      <th className="py-3 px-4">Latency</th>
                      <th className="py-3 px-4 text-right">Inspect</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {solutions.map((s) => (
                      <tr key={s.id} className="hover:bg-accent/30 transition-colors">
                        <td className="py-3.5 px-4 font-bold text-foreground">{s.userName}</td>
                        <td className="py-3.5 px-4 font-mono font-bold text-purple-500 max-w-xs truncate">
                          {s.question}
                        </td>
                        <td className="py-3.5 px-4 font-semibold text-muted-foreground">
                          {s.questionType}
                        </td>
                        <td className="py-3.5 px-4 font-mono font-bold text-foreground">
                          {s.finalAnswer}
                        </td>
                        <td className="py-3.5 px-4">
                          <span
                            className={`px-2 py-0.5 rounded-full font-bold text-[10px] flex items-center gap-1 w-fit ${
                              s.verificationStatus === "VERIFIED"
                                ? "bg-emerald-500/10 text-emerald-500 border border-emerald-500/20"
                                : "bg-amber-500/10 text-amber-500 border border-amber-500/20"
                            }`}
                          >
                            <CheckCircle2 size={11} />
                            {s.verificationStatus}
                          </span>
                        </td>
                        <td className="py-3.5 px-4 text-[11px] text-muted-foreground">
                          {s.provider} ({s.model.split("-")[0]})
                        </td>
                        <td className="py-3.5 px-4 text-muted-foreground">{s.latencyMs} ms</td>
                        <td className="py-3.5 px-4 text-right">
                          <button
                            onClick={() => setActiveSolution(s)}
                            className="px-2.5 py-1 rounded-lg border border-border bg-background hover:bg-accent text-[11px] font-semibold text-foreground"
                          >
                            Steps
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* Tab 2: User Reported Issues */}
        {activeTab === "reports" && (
          <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                  <tr>
                    <th className="py-3 px-4">Report ID</th>
                    <th className="py-3 px-4">Reporter</th>
                    <th className="py-3 px-4">Question</th>
                    <th className="py-3 px-4">Report Reason</th>
                    <th className="py-3 px-4">User Comment</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {reports.map((r) => (
                    <tr key={r.id} className="hover:bg-accent/30 transition-colors">
                      <td className="py-3.5 px-4 font-mono font-bold text-muted-foreground">{r.id}</td>
                      <td className="py-3.5 px-4 font-bold text-foreground">{r.userName}</td>
                      <td className="py-3.5 px-4 font-mono font-bold text-blue-500">{r.question}</td>
                      <td className="py-3.5 px-4 font-bold text-amber-500">{r.reason.replace("_", " ")}</td>
                      <td className="py-3.5 px-4 text-muted-foreground max-w-sm">{r.userComment || "None"}</td>
                      <td className="py-3.5 px-4">
                        <span
                          className={`px-2 py-0.5 rounded-full font-bold text-[10px] ${
                            r.status === "RESOLVED"
                              ? "bg-emerald-500/10 text-emerald-500 border border-emerald-500/20"
                              : "bg-amber-500/10 text-amber-500 border border-amber-500/20"
                          }`}
                        >
                          {r.status}
                        </span>
                      </td>
                      <td className="py-3.5 px-4 text-right space-x-1">
                        {r.status !== "RESOLVED" && (
                          <button
                            onClick={() => handleResolveReport(r.id, "RESOLVED")}
                            className="px-2 py-1 rounded-lg bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 text-[11px] font-bold"
                          >
                            Resolve
                          </button>
                        )}
                        {r.status !== "DISMISSED" && (
                          <button
                            onClick={() => handleResolveReport(r.id, "DISMISSED")}
                            className="px-2 py-1 rounded-lg bg-muted text-muted-foreground hover:bg-accent text-[11px] font-semibold"
                          >
                            Dismiss
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Step-by-Step AI Solution Inspector Modal */}
        {activeSolution && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-2xl rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-6 max-h-[85vh] overflow-y-auto animate-in zoom-in-95">
              <div className="flex items-center justify-between border-b border-border pb-4">
                <div>
                  <span className="text-[10px] font-bold uppercase tracking-wider text-purple-500">
                    {activeSolution.questionType} Solution
                  </span>
                  <h3 className="font-mono font-bold text-lg text-foreground mt-0.5">
                    {activeSolution.question}
                  </h3>
                </div>
                <button onClick={() => setActiveSolution(null)} className="text-muted-foreground hover:text-foreground">
                  <X size={20} />
                </button>
              </div>

              {/* Final Answer Banner */}
              <div className="p-4 rounded-xl bg-gradient-to-r from-purple-500/10 to-blue-500/10 border border-purple-500/20 flex items-center justify-between">
                <div>
                  <div className="text-[10px] font-bold text-muted-foreground uppercase">Calculated Result</div>
                  <div className="text-xl font-mono font-black text-foreground">{activeSolution.finalAnswer}</div>
                </div>
                <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-500 border border-emerald-500/20 text-xs font-bold">
                  <CheckCircle2 size={14} /> Mathematically Verified
                </div>
              </div>

              {/* Step List */}
              <div className="space-y-4">
                <div className="text-xs font-bold uppercase text-muted-foreground tracking-wider">
                  Generated Step-by-Step Proof
                </div>
                {activeSolution.steps.map((step) => (
                  <div key={step.stepNumber} className="p-4 rounded-xl bg-muted/30 border border-border space-y-2">
                    <div className="flex items-center gap-2">
                      <span className="h-5 w-5 rounded-full bg-primary text-primary-foreground font-bold text-xs flex items-center justify-center">
                        {step.stepNumber}
                      </span>
                      <span className="font-bold text-xs text-foreground">{step.title}</span>
                    </div>
                    {step.equation && (
                      <div className="font-mono text-xs font-bold text-blue-500 bg-background p-2 rounded-lg border border-border">
                        {step.equation}
                      </div>
                    )}
                    <div className="text-xs text-muted-foreground">{step.explanation}</div>
                    {step.whyExplanation && (
                      <div className="text-[11px] text-amber-500/90 font-medium bg-amber-500/10 p-2 rounded-lg border border-amber-500/20">
                        💡 <strong>Why:</strong> {step.whyExplanation}
                      </div>
                    )}
                  </div>
                ))}
              </div>

              <div className="flex justify-end pt-2 border-t border-border">
                <button
                  onClick={() => setActiveSolution(null)}
                  className="px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold"
                >
                  Done
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
