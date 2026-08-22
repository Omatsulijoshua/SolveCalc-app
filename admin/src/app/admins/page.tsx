"use client";

import React, { useState, useEffect } from "react";
import {
  ShieldCheck,
  UserPlus,
  Lock,
  Key,
  Smartphone,
  CheckCircle2,
  X,
  ShieldAlert,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { AdminUser, AdminRole } from "@/types";
import { formatDate } from "@/lib/utils";
import { useAuth } from "@/lib/authContext";

export default function AdminsPage() {
  const { role: currentAdminRole } = useAuth();
  const [admins, setAdmins] = useState<AdminUser[]>([]);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState<AdminRole>("ADMIN");
  const [twoFactor, setTwoFactor] = useState(true);

  const isSuperAdmin = currentAdminRole === "SUPER_ADMIN";

  const loadAdmins = async () => {
    const list = await adminService.getAdmins();
    setAdmins([...list]);
  };

  useEffect(() => {
    loadAdmins();
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !email.trim()) return;

    await adminService.createAdmin({
      name,
      email,
      role,
      status: "ACTIVE",
      twoFactorEnabled: twoFactor,
    });

    setName("");
    setEmail("");
    setShowCreateModal(false);
    await loadAdmins();
  };

  const handleRoleChange = async (id: string, newRole: AdminRole) => {
    await adminService.updateAdminRole(id, newRole);
    await loadAdmins();
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <ShieldCheck className="text-blue-500" /> Administrator Directory & RBAC
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Manage authorized administrative operators, security roles, and 2-factor authentication.
            </p>
          </div>

          {isSuperAdmin && (
            <button
              onClick={() => setShowCreateModal(true)}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold shadow-md shadow-primary/20 hover:bg-primary/90"
            >
              <UserPlus size={14} />
              <span>Add Administrator</span>
            </button>
          )}
        </div>

        {/* Admins Table */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">Administrator</th>
                  <th className="py-3 px-4">Security Role</th>
                  <th className="py-3 px-4">2FA Enforced</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Last Login</th>
                  <th className="py-3 px-4">Created Date</th>
                  {isSuperAdmin && <th className="py-3 px-4 text-right">Role Assignment</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {admins.map((adm) => (
                  <tr key={adm.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4">
                      <div className="font-bold text-foreground">{adm.name}</div>
                      <div className="text-[11px] text-muted-foreground">{adm.email}</div>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-black bg-blue-500/10 text-blue-500 border border-blue-500/20">
                        {adm.role}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      {adm.twoFactorEnabled ? (
                        <span className="flex items-center gap-1 text-[11px] font-bold text-emerald-500">
                          <CheckCircle2 size={12} /> Active
                        </span>
                      ) : (
                        <span className="text-[11px] text-muted-foreground">Disabled</span>
                      )}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="px-2 py-0.5 rounded-full font-bold text-[10px] bg-emerald-500/10 text-emerald-500">
                        {adm.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">
                      {adm.lastLoginAt ? formatDate(adm.lastLoginAt) : "Never"}
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{formatDate(adm.createdAt)}</td>
                    {isSuperAdmin && (
                      <td className="py-3.5 px-4 text-right">
                        <select
                          value={adm.role}
                          onChange={(e: any) => handleRoleChange(adm.id, e.target.value)}
                          className="px-2 py-1 rounded-lg border border-border bg-background text-[11px] font-semibold text-foreground focus:outline-none"
                        >
                          <option value="SUPER_ADMIN">SUPER_ADMIN</option>
                          <option value="ADMIN">ADMIN</option>
                          <option value="MODERATOR">MODERATOR</option>
                          <option value="SUPPORT">SUPPORT</option>
                          <option value="ANALYST">ANALYST</option>
                        </select>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Create Admin Modal */}
        {showCreateModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
            <div className="w-full max-w-md rounded-2xl border border-border bg-card shadow-2xl p-6 space-y-4 animate-in zoom-in-95">
              <div className="flex items-center justify-between border-b border-border pb-3">
                <div className="flex items-center gap-2">
                  <UserPlus className="text-primary" size={18} />
                  <h3 className="font-bold text-sm text-foreground">Add Administrator</h3>
                </div>
                <button onClick={() => setShowCreateModal(false)} className="text-muted-foreground hover:text-foreground">
                  <X size={18} />
                </button>
              </div>

              <form onSubmit={handleCreate} className="space-y-3 text-xs">
                <div>
                  <label className="block font-bold mb-1">Full Name</label>
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. Jordan Miller"
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none focus:border-primary"
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Corporate Email</label>
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="jordan.m@solvecalc.com"
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none focus:border-primary"
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Security Role</label>
                  <select
                    value={role}
                    onChange={(e: any) => setRole(e.target.value)}
                    className="w-full p-2.5 rounded-xl border border-border bg-background text-foreground focus:outline-none"
                  >
                    <option value="ADMIN">ADMIN (Operations & Content)</option>
                    <option value="MODERATOR">MODERATOR (OCR & Reports)</option>
                    <option value="SUPPORT">SUPPORT (User Inquiries)</option>
                    <option value="ANALYST">ANALYST (Read-Only Analytics)</option>
                    <option value="SUPER_ADMIN">SUPER_ADMIN (Full Access)</option>
                  </select>
                </div>

                <div className="flex items-center gap-2 pt-1">
                  <input
                    type="checkbox"
                    checked={twoFactor}
                    onChange={(e) => setTwoFactor(e.target.checked)}
                    className="rounded text-primary"
                  />
                  <span>Enforce Two-Factor Authentication (2FA)</span>
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t border-border">
                  <button
                    type="button"
                    onClick={() => setShowCreateModal(false)}
                    className="px-4 py-2 rounded-xl border border-border font-semibold hover:bg-accent"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 rounded-xl bg-primary text-primary-foreground font-bold hover:bg-primary/90"
                  >
                    Create Account
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
