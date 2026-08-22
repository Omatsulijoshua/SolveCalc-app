"use client";

import React, { useState, useEffect } from "react";
import {
  Palette,
  CheckCircle2,
  Plus,
  Eye,
  Sliders,
  Sparkles,
  Smartphone,
  Star,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";
import { ThemeItem } from "@/types";

export default function ThemesPage() {
  const [themes, setThemes] = useState<ThemeItem[]>([]);
  const [selectedTheme, setSelectedTheme] = useState<ThemeItem | null>(null);

  useEffect(() => {
    adminService.getThemes().then((t) => {
      setThemes(t);
      setSelectedTheme(t[0]);
    });
  }, []);

  const handleSetDefault = async (id: string) => {
    await adminService.setDefaultTheme(id);
    const updated = await adminService.getThemes();
    setThemes([...updated]);
    const current = updated.find((t) => t.id === id);
    if (current) setSelectedTheme(current);
  };

  const handleToggleActive = async (id: string) => {
    await adminService.toggleThemeActive(id);
    const updated = await adminService.getThemes();
    setThemes([...updated]);
  };

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
              <Palette className="text-pink-500" /> Calculator Themes & Mobile Simulator
            </h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Manage 9 available theme presets, default palettes, Pro tier exclusives, and live mobile preview.
            </p>
          </div>
        </div>

        {/* Layout: Themes List on Left, Live Mobile Simulator on Right */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          {/* Themes Grid (8 Cols) */}
          <div className="lg:col-span-7 space-y-3">
            <div className="text-xs font-bold uppercase text-muted-foreground tracking-wider mb-2">
              Preset Themes ({themes.length})
            </div>

            <div className="space-y-2.5">
              {themes.map((t) => (
                <div
                  key={t.id}
                  onClick={() => setSelectedTheme(t)}
                  className={`p-4 rounded-2xl border bg-card transition-all cursor-pointer flex items-center justify-between gap-4 ${
                    selectedTheme?.id === t.id
                      ? "border-primary ring-2 ring-primary/20 shadow-md"
                      : "border-border hover:border-primary/40"
                  }`}
                >
                  <div className="flex items-center gap-3.5 min-w-0">
                    {/* Color Swatch Circle */}
                    <div
                      className="h-10 w-10 rounded-xl border border-white/20 shadow-inner shrink-0 flex items-center justify-center font-bold text-xs"
                      style={{ backgroundColor: t.backgroundColor, color: t.primaryColor }}
                    >
                      <div
                        className="w-4 h-4 rounded-full border border-white/40 shadow-sm"
                        style={{ backgroundColor: t.primaryColor }}
                      />
                    </div>

                    <div className="min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-sm text-foreground truncate">{t.name}</span>
                        {t.isDefault && (
                          <span className="px-2 py-0.5 rounded-full text-[9px] font-black bg-blue-500/10 text-blue-500 border border-blue-500/20">
                            DEFAULT
                          </span>
                        )}
                        {t.isPremium && (
                          <span className="px-2 py-0.5 rounded-full text-[9px] font-black bg-amber-500/10 text-amber-500 border border-amber-500/20 flex items-center gap-0.5">
                            <Star size={9} fill="currentColor" /> PRO
                          </span>
                        )}
                      </div>
                      <div className="text-xs text-muted-foreground truncate mt-0.5">{t.description}</div>
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-2 shrink-0">
                    {!t.isDefault && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleSetDefault(t.id);
                        }}
                        className="px-2.5 py-1 rounded-lg border border-border text-[11px] font-semibold hover:bg-accent"
                      >
                        Make Default
                      </button>
                    )}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleToggleActive(t.id);
                      }}
                      className={`px-2.5 py-1 rounded-lg text-[11px] font-bold ${
                        t.isActive
                          ? "bg-emerald-500/10 text-emerald-500"
                          : "bg-muted text-muted-foreground"
                      }`}
                    >
                      {t.isActive ? "Active" : "Archived"}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Live Interactive Mobile Simulator (5 Cols) */}
          {selectedTheme && (
            <div className="lg:col-span-5 sticky top-24">
              <div className="p-5 rounded-3xl border border-border bg-card shadow-2xl space-y-4">
                <div className="flex items-center justify-between border-b border-border pb-3">
                  <div className="flex items-center gap-2">
                    <Smartphone size={16} className="text-blue-500" />
                    <span className="font-bold text-xs text-foreground">
                      Mobile Preview: {selectedTheme.name}
                    </span>
                  </div>
                  <span className="text-[10px] font-mono text-muted-foreground">iPhone 15 Pro</span>
                </div>

                {/* Simulated Mobile Device Screen */}
                <div
                  className="rounded-2xl p-5 shadow-2xl space-y-4 transition-all duration-300 select-none border border-white/10"
                  style={{ backgroundColor: selectedTheme.backgroundColor }}
                >
                  {/* Status Bar */}
                  <div className="flex justify-between items-center text-[10px] font-semibold opacity-75" style={{ color: selectedTheme.primaryColor }}>
                    <span>9:41</span>
                    <span>100% ⚡</span>
                  </div>

                  {/* Calculator LCD Display */}
                  <div
                    className="p-4 rounded-xl border border-white/10 text-right space-y-1 shadow-inner"
                    style={{ backgroundColor: selectedTheme.surfaceColor }}
                  >
                    <div className="text-xs font-mono opacity-70" style={{ color: selectedTheme.isDark ? "#E2E8F0" : "#475569" }}>
                      sin(30) + cos(60)
                    </div>
                    <div className="text-2xl font-mono font-black" style={{ color: selectedTheme.isDark ? "#FFFFFF" : "#0F172A" }}>
                      1.0
                    </div>
                  </div>

                  {/* Simulated Keypad Grid */}
                  <div className="grid grid-cols-4 gap-2">
                    {["C", "sin", "cos", "÷", "7", "8", "9", "×", "4", "5", "6", "-", "1", "2", "3", "+", "0", ".", "π", "="].map((btn, idx) => {
                      const isOperator = ["÷", "×", "-", "+"].includes(btn);
                      const isEquals = btn === "=";
                      const isScientific = ["sin", "cos", "π", "C"].includes(btn);

                      let btnBg = selectedTheme.numberButtonColor;
                      let btnText = selectedTheme.isDark ? "#FFFFFF" : "#0F172A";

                      if (isEquals) {
                        btnBg = selectedTheme.primaryColor;
                        btnText = "#FFFFFF";
                      } else if (isOperator) {
                        btnBg = selectedTheme.operatorButtonColor;
                        btnText = selectedTheme.primaryColor;
                      } else if (isScientific) {
                        btnBg = selectedTheme.secondaryColor;
                        btnText = selectedTheme.primaryColor;
                      }

                      return (
                        <div
                          key={idx}
                          className="h-10 rounded-xl flex items-center justify-center font-bold text-xs shadow-sm transition-transform active:scale-95 cursor-pointer border border-white/5"
                          style={{ backgroundColor: btnBg, color: btnText }}
                        >
                          {btn}
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
