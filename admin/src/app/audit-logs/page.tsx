"use client";

import React, { useState, useEffect } from "react";
import {
  History,
  Search,
  Download,
  Filter,
  ShieldCheck,
  CheckCircle2,
  AlertTriangle,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { AuditLog } from "@/types";
import { formatDate } from "@/lib/utils";

export default function AuditLogsPage() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [search, setSearch] = useState("");
  const [actionFilter, setActionFilter] = useState("ALL");

  useEffect(() => {
    adminService.getAuditLogs(search, actionFilter).then(setLogs);
  }, [search, actionFilter]);

  const exportAuditCSV = () => {
    const header = "ID,Admin,Role,Action,Resource,ResourceID,Details,IP,Status,Timestamp\n";
    const rows = logs.map(
      (l) =>
        `"${l.id}","${l.adminName}","${l.adminRole}","${l.action}","${l.resource}","${l.resourceId || ''}","${l.details.replace(/"/g, '""')}","${l.ipAddress}","${l.status}","${l.timestamp}"`
    ).join("\n");

    const blob = new Blob([header + rows], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `solvecalc_audit_trail_${Date.now()}.csv`;
    a.click();
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <History className="text-blue-500" /> Administrative Audit Trail
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Cryptographically verified, immutable record of all administrative actions and security mutations.
            </p>
          </div>

          <button
            onClick={exportAuditCSV}
            className="flex items-center gap-2 px-3.5 py-2 rounded-xl border border-border bg-card hover:bg-accent text-xs font-semibold"
          >
            <Download size={14} />
            <span>Export Audit Log (CSV)</span>
          </button>
        </div>

        {/* Filters */}
        <div className="p-4 rounded-2xl border border-border bg-card flex flex-col sm:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search action, administrator name, or resource..."
              className="w-full pl-10 pr-4 py-2 text-xs rounded-xl border border-border bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary"
            />
          </div>

          <select
            value={actionFilter}
            onChange={(e) => setActionFilter(e.target.value)}
            className="px-3 py-2 text-xs rounded-xl border border-border bg-background text-foreground focus:outline-none w-full sm:w-auto"
          >
            <option value="ALL">All Actions</option>
            <option value="UPDATE_AI_PROVIDER">AI Configuration</option>
            <option value="CREATE_THEME">Theme Management</option>
            <option value="SUSPEND_USER">User Suspension</option>
            <option value="RESOLVE_SOLUTION_REPORT">Report Resolution</option>
            <option value="ADMIN_LOGIN">Admin Login</option>
          </select>
        </div>

        {/* Audit Log Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">Admin Operator</th>
                  <th className="py-3 px-4">Action</th>
                  <th className="py-3 px-4">Resource</th>
                  <th className="py-3 px-4">Activity Description</th>
                  <th className="py-3 px-4">IP Address</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Timestamp</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {logs.map((l) => (
                  <tr key={l.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4">
                      <div className="font-bold text-foreground">{l.adminName}</div>
                      <div className="text-[10px] text-blue-500 font-semibold">{l.adminRole}</div>
                    </td>
                    <td className="py-3.5 px-4 font-mono font-bold text-foreground">{l.action}</td>
                    <td className="py-3.5 px-4 font-mono text-muted-foreground">{l.resource}</td>
                    <td className="py-3.5 px-4 text-foreground max-w-sm">{l.details}</td>
                    <td className="py-3.5 px-4 font-mono text-[11px] text-muted-foreground">{l.ipAddress}</td>
                    <td className="py-3.5 px-4">
                      <span className="flex items-center gap-1 text-[10px] font-bold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full w-fit">
                        <CheckCircle2 size={11} /> {l.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{formatDate(l.timestamp)}</td>
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
