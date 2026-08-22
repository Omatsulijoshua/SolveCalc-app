"use client";

import React, { useState, useEffect } from "react";
import {
  Bell,
  Send,
  Users,
  Smartphone,
  CheckCircle2,
  Clock,
  Sparkles,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { NotificationItem } from "@/types";
import { formatDate, formatNumber } from "@/lib/utils";

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [targetAudience, setTargetAudience] = useState<"ALL" | "ANDROID" | "IOS">("ALL");
  const [notifType, setNotifType] = useState<"SYSTEM" | "FEATURE" | "MAINTENANCE">("FEATURE");
  const [isSending, setIsSending] = useState(false);
  const [sentToast, setSentToast] = useState(false);

  const loadNotifications = async () => {
    const list = await adminService.getNotifications();
    setNotifications([...list]);
  };

  useEffect(() => {
    loadNotifications();
  }, []);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !message.trim()) return;

    setIsSending(true);
    try {
      await adminService.sendNotification({
        title,
        message,
        type: notifType,
        targetAudience,
      });
      setTitle("");
      setMessage("");
      setSentToast(true);
      setTimeout(() => setSentToast(false), 3000);
      await loadNotifications();
    } finally {
      setIsSending(false);
    }
  };

  return (
    <AdminLayout>
      <div className="space-y-8 animate-in fade-in">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <Bell className="text-indigo-500" /> Push Notification Center & Campaigns
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Broadcast platform updates, feature announcements, and maintenance alerts to mobile users.
          </p>
        </div>

        {sentToast && (
          <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-xs font-bold flex items-center gap-2">
            <CheckCircle2 size={16} />
            Push notification broadcast dispatched successfully!
          </div>
        )}

        {/* Composer Form */}
        <div className="p-6 rounded-2xl border border-border bg-card shadow-sm space-y-4">
          <div className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
            <Send size={14} className="text-indigo-500" /> Compose Push Broadcast
          </div>

          <form onSubmit={handleSend} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold mb-1">Target Audience</label>
                <select
                  value={targetAudience}
                  onChange={(e: any) => setTargetAudience(e.target.value)}
                  className="w-full p-2.5 rounded-xl border border-border bg-background text-xs text-foreground focus:outline-none"
                >
                  <option value="ALL">All Active Users (14,850)</option>
                  <option value="ANDROID">Android Users Only (6,237)</option>
                  <option value="IOS">iOS Users Only (8,613)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold mb-1">Notification Category</label>
                <select
                  value={notifType}
                  onChange={(e: any) => setNotifType(e.target.value)}
                  className="w-full p-2.5 rounded-xl border border-border bg-background text-xs text-foreground focus:outline-none"
                >
                  <option value="FEATURE">✨ Feature Announcement</option>
                  <option value="SYSTEM">⚡ System Alert</option>
                  <option value="MAINTENANCE">🔧 Maintenance Notice</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold mb-1">Notification Title</label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. Try our new Casio Scientific Theme!"
                className="w-full p-2.5 rounded-xl border border-border bg-background text-xs text-foreground focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-xs font-bold mb-1">Message Body</label>
              <textarea
                required
                rows={2}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="e.g. Customize your calculator with classic retro styling in Settings."
                className="w-full p-2.5 rounded-xl border border-border bg-background text-xs text-foreground focus:outline-none focus:border-primary"
              />
            </div>

            <div className="flex justify-end">
              <button
                type="submit"
                disabled={isSending}
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-primary text-primary-foreground text-xs font-bold shadow-md shadow-primary/20 hover:bg-primary/90 transition-all disabled:opacity-50"
              >
                <Send size={14} />
                <span>{isSending ? "Dispatching..." : "Send Broadcast Now"}</span>
              </button>
            </div>
          </form>
        </div>

        {/* Notification History */}
        <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-sm">
          <div className="p-4 border-b border-border bg-muted/20 text-xs font-bold text-foreground">
            Broadcast Delivery History ({notifications.length})
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-muted/40 border-b border-border text-muted-foreground font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="py-3 px-4">Title & Message</th>
                  <th className="py-3 px-4">Target Audience</th>
                  <th className="py-3 px-4">Delivered</th>
                  <th className="py-3 px-4">Opened</th>
                  <th className="py-3 px-4">Open Rate</th>
                  <th className="py-3 px-4">Dispatched Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {notifications.map((n) => (
                  <tr key={n.id} className="hover:bg-accent/30 transition-colors">
                    <td className="py-3.5 px-4 max-w-sm">
                      <div className="font-bold text-foreground">{n.title}</div>
                      <div className="text-[11px] text-muted-foreground truncate">{n.message}</div>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-muted text-foreground">
                        {n.targetAudience}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-mono font-bold text-foreground">
                      {formatNumber(n.deliveredCount)}
                    </td>
                    <td className="py-3.5 px-4 font-mono font-bold text-blue-500">
                      {formatNumber(n.openedCount)}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-emerald-500">
                      {n.deliveredCount > 0
                        ? `${((n.openedCount / n.deliveredCount) * 100).toFixed(1)}%`
                        : "0%"}
                    </td>
                    <td className="py-3.5 px-4 text-muted-foreground">{n.sentAt ? formatDate(n.sentAt) : "Pending"}</td>
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
