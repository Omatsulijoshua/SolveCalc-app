"use client";

import React, { useState } from "react";
import { usePathname } from "next/navigation";
import { Sidebar } from "./Sidebar";
import { TopBar } from "./TopBar";
import { GlobalSearchModal } from "../dialogs/GlobalSearchModal";
import { useAuth } from "@/lib/authContext";
import { ShieldAlert } from "lucide-react";

export function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { canAccess, role } = useAuth();
  const [isSearchOpen, setIsSearchOpen] = useState(false);

  const isAllowed = canAccess(pathname);

  return (
    <div className="flex min-h-screen bg-background text-foreground">
      {/* Collapsible Navigation Sidebar */}
      <Sidebar />

      {/* Main Content Viewport */}
      <div className="flex-1 flex flex-col min-w-0">
        <TopBar onOpenSearch={() => setIsSearchOpen(true)} />

        <main className="flex-1 p-6 md:p-8 overflow-y-auto max-w-7xl w-full mx-auto">
          {isAllowed ? (
            children
          ) : (
            <div className="flex flex-col items-center justify-center py-24 text-center max-w-md mx-auto space-y-4">
              <div className="p-4 rounded-2xl bg-destructive/10 text-destructive">
                <ShieldAlert size={48} />
              </div>
              <h2 className="text-xl font-bold text-foreground">Access Restricted (403)</h2>
              <p className="text-xs text-muted-foreground leading-relaxed">
                Your current administrator role <span className="font-bold text-foreground">({role})</span> does not have sufficient permission to view <span className="font-mono text-foreground">{pathname}</span>.
              </p>
              <div className="text-[11px] text-muted-foreground">
                Tip: You can use the Role switcher in the top bar to test as <strong>SUPER_ADMIN</strong> or <strong>ADMIN</strong>.
              </div>
            </div>
          )}
        </main>
      </div>

      {/* Global Cmd+K Search Modal */}
      <GlobalSearchModal isOpen={isSearchOpen} onClose={() => setIsSearchOpen(false)} />
    </div>
  );
}
