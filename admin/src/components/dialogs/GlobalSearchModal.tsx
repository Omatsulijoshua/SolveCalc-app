"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { Search, Users, Calculator, Brain, Camera, X, ChevronRight } from "lucide-react";
import { adminService } from "@/services/adminService";
import { User, Calculation, AISolution, ScanRecord } from "@/types";

interface GlobalSearchModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function GlobalSearchModal({ isOpen, onClose }: GlobalSearchModalProps) {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [users, setUsers] = useState<User[]>([]);
  const [calcs, setCalcs] = useState<Calculation[]>([]);
  const [solutions, setSolutions] = useState<AISolution[]>([]);
  const [scans, setScans] = useState<ScanRecord[]>([]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        if (isOpen) onClose();
      }
      if (e.key === "Escape" && isOpen) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  useEffect(() => {
    if (!query.trim()) {
      setUsers([]);
      setCalcs([]);
      setSolutions([]);
      setScans([]);
      return;
    }

    const run = async () => {
      const uRes = await adminService.getUsers({ search: query, limit: 3 });
      const cRes = await adminService.getCalculations(query);
      const sRes = await adminService.getAISolutions(query);
      const scRes = await adminService.getScans();

      setUsers(uRes.users);
      setCalcs(cRes.slice(0, 3));
      setSolutions(sRes.slice(0, 3));
      setScans(scRes.filter((s) => s.finalQuestion.toLowerCase().includes(query.toLowerCase())).slice(0, 3));
    };

    const timer = setTimeout(run, 150);
    return () => clearTimeout(timer);
  }, [query]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-20 px-4 bg-black/60 backdrop-blur-sm animate-in fade-in">
      <div className="w-full max-w-2xl rounded-2xl border border-border bg-card shadow-2xl overflow-hidden animate-in zoom-in-95">
        {/* Search Input Bar */}
        <div className="flex items-center gap-3 px-4 border-b border-border bg-muted/20">
          <Search size={18} className="text-muted-foreground shrink-0" />
          <input
            autoFocus
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Type equation, email, solution ID, or user name..."
            className="flex-1 py-4 bg-transparent text-sm text-foreground placeholder:text-muted-foreground focus:outline-none"
          />
          {query && (
            <button onClick={() => setQuery("")} className="text-muted-foreground hover:text-foreground">
              <X size={16} />
            </button>
          )}
          <button
            onClick={onClose}
            className="text-[11px] font-semibold px-2 py-1 rounded bg-muted text-muted-foreground border border-border"
          >
            ESC
          </button>
        </div>

        {/* Results Body */}
        <div className="max-h-[60vh] overflow-y-auto p-4 space-y-4">
          {!query && (
            <div className="py-8 text-center text-xs text-muted-foreground">
              Search across users, calculations, AI step-by-step solutions, and OCR scanned questions.
            </div>
          )}

          {query && users.length === 0 && calcs.length === 0 && solutions.length === 0 && scans.length === 0 && (
            <div className="py-8 text-center text-xs text-muted-foreground">
              No results found for &ldquo;{query}&rdquo;.
            </div>
          )}

          {/* User Results */}
          {users.length > 0 && (
            <div>
              <div className="text-[10px] font-bold uppercase text-muted-foreground px-2 mb-1 flex items-center gap-1.5">
                <Users size={12} /> Users ({users.length})
              </div>
              <div className="space-y-1">
                {users.map((u) => (
                  <div
                    key={u.id}
                    onClick={() => {
                      router.push(`/users`);
                      onClose();
                    }}
                    className="flex items-center justify-between p-2.5 rounded-xl hover:bg-accent cursor-pointer transition-colors"
                  >
                    <div>
                      <div className="text-xs font-bold text-foreground">{u.name}</div>
                      <div className="text-[11px] text-muted-foreground">{u.email} • {u.accountType}</div>
                    </div>
                    <ChevronRight size={14} className="text-muted-foreground" />
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* AI Solutions Results */}
          {solutions.length > 0 && (
            <div>
              <div className="text-[10px] font-bold uppercase text-muted-foreground px-2 mb-1 flex items-center gap-1.5">
                <Brain size={12} /> AI Solutions ({solutions.length})
              </div>
              <div className="space-y-1">
                {solutions.map((s) => (
                  <div
                    key={s.id}
                    onClick={() => {
                      router.push(`/ai/solutions`);
                      onClose();
                    }}
                    className="flex items-center justify-between p-2.5 rounded-xl hover:bg-accent cursor-pointer transition-colors"
                  >
                    <div>
                      <div className="text-xs font-mono font-bold text-blue-500">{s.question}</div>
                      <div className="text-[11px] text-muted-foreground">Answer: {s.finalAnswer} • by {s.userName}</div>
                    </div>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-500">
                      {s.verificationStatus}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Calculator Log Results */}
          {calcs.length > 0 && (
            <div>
              <div className="text-[10px] font-bold uppercase text-muted-foreground px-2 mb-1 flex items-center gap-1.5">
                <Calculator size={12} /> Calculator Logs ({calcs.length})
              </div>
              <div className="space-y-1">
                {calcs.map((c) => (
                  <div
                    key={c.id}
                    onClick={() => {
                      router.push(`/calculator`);
                      onClose();
                    }}
                    className="flex items-center justify-between p-2.5 rounded-xl hover:bg-accent cursor-pointer transition-colors"
                  >
                    <div>
                      <div className="text-xs font-mono font-bold text-foreground">{c.expression} = {c.result}</div>
                      <div className="text-[11px] text-muted-foreground">{c.mode} • {c.angleMode} • {c.userName}</div>
                    </div>
                    <ChevronRight size={14} className="text-muted-foreground" />
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
