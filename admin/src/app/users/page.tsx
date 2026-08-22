"use client";

import React, { useState, useEffect } from "react";
import {
  Users,
  Search,
  Filter,
  Download,
  MoreVertical,
  ShieldAlert,
  CheckCircle,
  Ban,
  RotateCcw,
  Smartphone,
  Calendar,
  Calculator,
  Brain,
  Camera,
  X,
  UserCheck,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { User, AccountStatus } from "@/types";
import { formatDate, formatNumber } from "@/lib/utils";
import { useAuth } from "@/lib/authContext";

export default function UsersPage() {
  const { hasPermission } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [accountTypeFilter, setAccountTypeFilter] = useState("ALL");
  const [page, setPage] = useState(1);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [actionModal, setActionModal] = useState<{
    user: User;
    action: "SUSPEND" | "BAN" | "RESTORE" | "DELETE";
  } | null>(null);
  const [actionReason, setActionReason] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);

  const canEditUsers = hasPermission("users.edit");
  const canSuspendUsers = hasPermission("users.suspend");

  const loadUsers = async () => {
    const res = await adminService.getUsers({
      search,
      status: statusFilter,
      accountType: accountTypeFilter,
      page,
      limit: 10,
    });
    setUsers(res.users);
    setTotal(res.total);
  };

  useEffect(() => {
    loadUsers();
  }, [search, statusFilter, accountTypeFilter, page]);

  const handleStatusUpdate = async () => {
    if (!actionModal) return;
    setIsProcessing(true);
    try {
      let newStatus: AccountStatus = "ACTIVE";
      if (actionModal.action === "SUSPEND") newStatus = "SUSPENDED";
      if (actionModal.action === "BAN") newStatus = "BANNED";
      if (actionModal.action === "RESTORE") newStatus = "ACTIVE";
      if (actionModal.action === "DELETE") newStatus = "DELETED";

      await adminService.updateUserStatus(actionModal.user.id, newStatus, actionReason);
      await loadUsers();
      if (selectedUser?.id === actionModal.user.id) {
        setSelectedUser({ ...selectedUser, status: newStatus });
      }
      setActionModal(null);
      setActionReason("");
    } finally {
      setIsProcessing(false);
    }
  };

  const exportCSV = () => {
    const headers = ["ID,Name,Email,Status,AccountType,Calculations,AISolves,Scans,Platform,Version,RegisteredAt\n"];
    const rows = users.map(
      (u) =>
        `"${u.id}","${u.name}","${u.email}","${u.status}","${u.accountType}",${u.calculationsCount},${u.aiSolvesCount},${u.scansCount},"${u.devicePlatform}","${u.appVersion}","${u.registeredAt}"\n`
    );
    const blob = new Blob([...headers, ...rows], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `solvecalc_users_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground">User Management</h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Total {formatNumber(total)} registered accounts across iOS and Android
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={exportCSV}
              className="flex items-center gap-2 px-3.5 py-2 rounded-xl border border-border bg-card hover:bg-accent text-xs font-semibold transition-all shadow-sm"
            >
              <Download size={14} />
              <span>Export CSV</span>
            </button>
          </div>
        </div>

        {/* Filters Bar */}
        <div className="p-4 rounded-2xl border border-border bg-card flex flex-col md:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
            <input
              type="text"
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              placeholder="Search user by name, email, or ID..."
              className="w-full pl-10 pr-4 py-2 text-xs rounded-xl border border-border bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary"
            />
          </div>

          <div className="flex items-center gap-2 w-full md:w-auto">
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setPage(1);
              }}
              className="px-3 py-2 text-xs rounded-xl border border-border bg-background text-foreground focus:outline-none"
            >
              <option value="ALL">All Statuses</option>
              <option value="ACTIVE">Active</option>
              <option value="SUSPENDED">Suspended</option>
              <option value="BANNED">Banned</option>
            </select>

            <select
              value={accountTypeFilter}
              onChange={(e) => {
                setAccountTypeFilter(e.target.value);
                setPage(1);
              }}
              className="px-3 py-2 text-xs rounded-xl border border-border bg-background text-foreground focus:outline-none"
            >
              <option value="ALL">All Account Types</option>
              <option value="PRO_LIFETIME">Pro Lifetime ($10 Tier)</option>
              <option value="FREE">Free Tier</option>
            </select>
          </div>
        </div>

        {/* Users Data Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">User</th>
                  <th className="py-3 px-4">Tier</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-center">Calculations</th>
                  <th className="py-3 px-4 text-center">AI Solves</th>
                  <th className="py-3 px-4 text-center">Scans</th>
                  <th className="py-3 px-4">Platform</th>
                  <th className="py-3 px-4">Last Active</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {users.map((u) => (
                  <tr key={u.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4">
                      <div className="font-bold text-foreground">{u.name}</div>
                      <div className="text-[11px] text-muted-foreground">{u.email}</div>
                    </td>
                    <td className="py-3.5 px-4">
                      {u.accountType === "PRO_LIFETIME" ? (
                        <span className="px-2 py-0.5 rounded-full font-bold text-[10px] bg-amber-500/10 text-amber-500 border border-amber-500/20">
                          PRO LIFETIME
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full font-semibold text-[10px] bg-muted text-muted-foreground">
                          Free
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4">
                      <span
                        className={`px-2 py-0.5 rounded-full font-bold text-[10px] ${
                          u.status === "ACTIVE"
                            ? "bg-emerald-500/10 text-emerald-500 border border-emerald-500/20"
                            : u.status === "SUSPENDED"
                            ? "bg-amber-500/10 text-amber-500 border border-amber-500/20"
                            : "bg-destructive/10 text-destructive border border-destructive/20"
                        }`}
                      >
                        {u.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-center font-mono font-bold text-foreground">
                      {formatNumber(u.calculationsCount)}
                    </td>
                    <td className="py-3.5 px-4 text-center font-mono font-bold text-purple-500">
                      {formatNumber(u.aiSolvesCount)}
                    </td>
                    <td className="py-3.5 px-4 text-center font-mono font-bold text-emerald-500">
                      {formatNumber(u.scansCount)}
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">
                      {u.devicePlatform} (v{u.appVersion})
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">
                      {formatDate(u.lastActiveAt)}
                    </td>
                    <td className="py-3.5 px-4 text-right space-x-1">
                      <button
                        onClick={() => setSelectedUser(u)}
                        className="px-2.5 py-1 rounded-lg border border-border bg-background hover:bg-accent text-[11px] font-semibold text-foreground transition-colors"
                      >
                        Profile
                      </button>

                      {canSuspendUsers && u.status === "ACTIVE" && (
                        <button
                          onClick={() => setActionModal({ user: u, action: "SUSPEND" })}
                          className="px-2 py-1 rounded-lg bg-amber-500/10 text-amber-500 hover:bg-amber-500/20 text-[11px] font-bold transition-colors"
                          title="Suspend User"
                        >
                          Suspend
                        </button>
                      )}

                      {canSuspendUsers && u.status !== "ACTIVE" && (
                        <button
                          onClick={() => setActionModal({ user: u, action: "RESTORE" })}
                          className="px-2 py-1 rounded-lg bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 text-[11px] font-bold transition-colors"
                          title="Restore User"
                        >
                          Restore
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* User Profile Detail Modal */}
        {selectedUser && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-6 animate-in zoom-in-95">
              <div className="flex items-center justify-between border-b border-border pb-4">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 text-white font-bold text-lg flex items-center justify-center">
                    {selectedUser.name[0]}
                  </div>
                  <div>
                    <h3 className="text-base font-bold text-foreground">{selectedUser.name}</h3>
                    <div className="text-xs text-muted-foreground">{selectedUser.email}</div>
                  </div>
                </div>
                <button onClick={() => setSelectedUser(null)} className="text-muted-foreground hover:text-foreground">
                  <X size={18} />
                </button>
              </div>

              {/* Stats Grid */}
              <div className="grid grid-cols-3 gap-3 text-center">
                <div className="p-3 rounded-xl bg-accent/40 border border-border">
                  <Calculator size={18} className="mx-auto text-blue-500 mb-1" />
                  <div className="font-bold text-foreground text-sm">{selectedUser.calculationsCount}</div>
                  <div className="text-[10px] text-muted-foreground">Calculations</div>
                </div>
                <div className="p-3 rounded-xl bg-accent/40 border border-border">
                  <Brain size={18} className="mx-auto text-purple-500 mb-1" />
                  <div className="font-bold text-foreground text-sm">{selectedUser.aiSolvesCount}</div>
                  <div className="text-[10px] text-muted-foreground">AI Solves</div>
                </div>
                <div className="p-3 rounded-xl bg-accent/40 border border-border">
                  <Camera size={18} className="mx-auto text-emerald-500 mb-1" />
                  <div className="font-bold text-foreground text-sm">{selectedUser.scansCount}</div>
                  <div className="text-[10px] text-muted-foreground">OCR Scans</div>
                </div>
              </div>

              {/* Account Meta */}
              <div className="space-y-2 text-xs">
                <div className="flex justify-between py-1.5 border-b border-border">
                  <span className="text-muted-foreground">Account Tier</span>
                  <span className="font-bold text-foreground">{selectedUser.accountType}</span>
                </div>
                <div className="flex justify-between py-1.5 border-b border-border">
                  <span className="text-muted-foreground">Registered</span>
                  <span className="font-bold text-foreground">{formatDate(selectedUser.registeredAt)}</span>
                </div>
                <div className="flex justify-between py-1.5 border-b border-border">
                  <span className="text-muted-foreground">Primary Device</span>
                  <span className="font-bold text-foreground">{selectedUser.devicePlatform} (App v{selectedUser.appVersion})</span>
                </div>
              </div>

              {/* Modal Actions */}
              <div className="flex justify-end gap-2 pt-2">
                <button
                  onClick={() => setSelectedUser(null)}
                  className="px-4 py-2 rounded-xl border border-border text-xs font-semibold hover:bg-accent"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Suspend / Ban / Restore Confirmation Modal */}
        {actionModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-md rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-4 animate-in zoom-in-95">
              <div className="flex items-center gap-3 text-amber-500">
                <ShieldAlert size={24} />
                <h3 className="font-bold text-base text-foreground">
                  Confirm {actionModal.action} Action
                </h3>
              </div>
              <p className="text-xs text-muted-foreground">
                Are you sure you want to {actionModal.action.toLowerCase()} user{" "}
                <strong>{actionModal.user.name}</strong> ({actionModal.user.email})?
              </p>

              <div>
                <label className="block text-xs font-bold mb-1">Administrative Reason</label>
                <textarea
                  rows={2}
                  value={actionReason}
                  onChange={(e) => setActionReason(e.target.value)}
                  placeholder="e.g. Terms violation, spam bot, or customer request..."
                  className="w-full p-2.5 text-xs rounded-xl border border-border bg-background focus:outline-none focus:border-primary"
                />
              </div>

              <div className="flex justify-end gap-2">
                <button
                  onClick={() => setActionModal(null)}
                  className="px-4 py-2 rounded-xl border border-border text-xs font-semibold hover:bg-accent"
                >
                  Cancel
                </button>
                <button
                  disabled={isProcessing}
                  onClick={handleStatusUpdate}
                  className="px-4 py-2 rounded-xl bg-destructive text-destructive-foreground text-xs font-bold hover:bg-destructive/90"
                >
                  {isProcessing ? "Processing..." : `Confirm ${actionModal.action}`}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
