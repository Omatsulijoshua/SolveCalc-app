"use client";

import React, { useState, useEffect } from "react";
import {
  Calculator,
  Search,
  CheckCircle2,
  AlertTriangle,
  Flame,
  Activity,
  Filter,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { Calculation } from "@/types";
import { formatDate, formatNumber } from "@/lib/utils";

export default function CalculatorPage() {
  const [calcs, setCalcs] = useState<Calculation[]>([]);
  const [search, setSearch] = useState("");
  const [modeFilter, setModeFilter] = useState("ALL");
  const functionStats = adminService.getFunctionPopularity();

  useEffect(() => {
    adminService.getCalculations(search, modeFilter).then(setCalcs);
  }, [search, modeFilter]);

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <Calculator className="text-blue-500" /> Calculator Operations & Telemetry
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Real-time equation evaluations, function frequency distribution, and arithmetic error logs.
          </p>
        </div>

        {/* Function Popularity Highlights */}
        <div>
          <div className="text-xs font-bold uppercase text-muted-foreground tracking-wider mb-3 flex items-center gap-1.5">
            <Flame size={14} className="text-amber-500" /> Most Utilized Calculator Functions
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {functionStats.map((f, idx) => (
              <div key={idx} className="p-3.5 rounded-2xl border border-border bg-card shadow-sm space-y-2">
                <div className="flex justify-between items-center text-xs">
                  <span className="font-mono font-bold text-foreground">{f.name}</span>
                  <span className="font-bold text-blue-500">{f.percentage}%</span>
                </div>
                <div className="w-full h-1.5 rounded-full bg-muted overflow-hidden">
                  <div
                    className="h-full rounded-full bg-gradient-to-r from-blue-500 to-indigo-500"
                    style={{ width: `${f.percentage * 2.5}%` }}
                  />
                </div>
                <div className="text-[10px] text-muted-foreground">{formatNumber(f.count)} evaluations</div>
              </div>
            ))}
          </div>
        </div>

        {/* Filters Bar */}
        <div className="p-4 rounded-2xl border border-border bg-card flex flex-col md:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search expression (e.g. sin, sqrt, 1500) or user..."
              className="w-full pl-10 pr-4 py-2 text-xs rounded-xl border border-border bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary"
            />
          </div>

          <div className="flex items-center gap-2 w-full md:w-auto">
            <select
              value={modeFilter}
              onChange={(e) => setModeFilter(e.target.value)}
              className="px-3 py-2 text-xs rounded-xl border border-border bg-background text-foreground focus:outline-none"
            >
              <option value="ALL">All Modes</option>
              <option value="scientific">Scientific Only</option>
              <option value="basic">Basic Only</option>
            </select>
          </div>
        </div>

        {/* Live Calculation Log Feed */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="p-4 border-b border-border bg-muted/20 flex items-center justify-between">
            <div className="text-xs font-bold text-foreground flex items-center gap-2">
              <Activity size={15} className="text-emerald-500 animate-pulse" />
              Live Evaluation Stream ({calcs.length} records)
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">User</th>
                  <th className="py-3 px-4">Expression</th>
                  <th className="py-3 px-4">Result</th>
                  <th className="py-3 px-4">Layout Mode</th>
                  <th className="py-3 px-4">Angle Mode</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Evaluated At</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {calcs.map((c) => (
                  <tr key={c.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-foreground">{c.userName}</td>
                    <td className="py-3.5 px-4 font-mono font-bold text-blue-500">{c.expression}</td>
                    <td className="py-3.5 px-4 font-mono font-bold text-foreground">{c.result}</td>
                    <td className="py-3.5 px-4 uppercase text-[10px] font-bold text-muted-foreground">
                      {c.mode}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-muted text-foreground">
                        {c.angleMode}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      {c.isError ? (
                        <span className="flex items-center gap-1 text-[10px] font-bold text-destructive">
                          <AlertTriangle size={12} /> Error
                        </span>
                      ) : (
                        <span className="flex items-center gap-1 text-[10px] font-bold text-emerald-500">
                          <CheckCircle2 size={12} /> Success
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{formatDate(c.timestamp)}</td>
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
