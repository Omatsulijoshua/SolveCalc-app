"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Lock, Mail, Eye, EyeOff, ShieldCheck, ArrowRight, Sparkles } from "lucide-react";
import { useAuth } from "@/lib/authContext";
import { INITIAL_ADMINS } from "@/services/mockDataStore";

export default function LoginPage() {
  const router = useRouter();
  const { login, switchRole } = useAuth();
  const [email, setEmail] = useState("sarah.admin@solvecalc.com");
  const [password, setPassword] = useState("password123");
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);
    setIsLoading(true);

    try {
      await login(email, password);
      router.push("/dashboard");
    } catch (err: any) {
      setErrorMessage(err.message || "Failed to authenticate administrator.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuickDemoLogin = (adminUser: (typeof INITIAL_ADMINS)[0]) => {
    setEmail(adminUser.email);
    setPassword("password123");
    switchRole(adminUser.role);
    router.push("/dashboard");
  };

  return (
    <div className="min-h-screen bg-background flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background glowing gradients */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-96 h-96 bg-primary/20 rounded-full blur-3xl pointer-events-none" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        <div className="flex justify-center mb-4">
          <div className="h-12 w-12 rounded-2xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-white font-black text-2xl shadow-xl shadow-blue-500/25">
            S
          </div>
        </div>
        <h2 className="text-center text-2xl font-black tracking-tight text-foreground">
          SolveCalc Admin Portal
        </h2>
        <p className="mt-1 text-center text-xs text-muted-foreground">
          Sign in with authorized administrator credentials
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md relative z-10 px-4">
        <div className="bg-card border border-border py-8 px-6 sm:px-10 rounded-2xl shadow-2xl space-y-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            {errorMessage && (
              <div className="p-3 rounded-xl bg-destructive/10 border border-destructive/20 text-destructive text-xs font-semibold">
                {errorMessage}
              </div>
            )}

            <div>
              <label className="block text-xs font-bold text-foreground mb-1.5">
                Admin Email
              </label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@solvecalc.com"
                  className="w-full rounded-xl border border-border bg-background pl-10 pr-4 py-2.5 text-xs text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary transition-colors"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-foreground mb-1.5">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
                <input
                  type={showPassword ? "text" : "password"}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full rounded-xl border border-border bg-background pl-10 pr-10 py-2.5 text-xs text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary transition-colors"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="rounded border-border text-primary focus:ring-primary h-3.5 w-3.5"
                />
                <span className="text-xs text-muted-foreground">Remember session</span>
              </label>

              <button
                type="button"
                onClick={() => alert("Password reset link has been dispatched if this address is registered.")}
                className="text-xs font-semibold text-primary hover:underline"
              >
                Forgot password?
              </button>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-xl bg-primary text-primary-foreground font-bold text-xs shadow-lg shadow-primary/25 hover:bg-primary/90 transition-all disabled:opacity-50"
            >
              {isLoading ? (
                <div className="h-4 w-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <span>Sign In to Dashboard</span>
                  <ArrowRight size={14} />
                </>
              )}
            </button>
          </form>

          {/* Quick Demo Login Credentials Selector */}
          <div className="border-t border-border pt-5">
            <div className="text-[11px] font-bold text-muted-foreground uppercase tracking-wider mb-2.5 flex items-center gap-1.5">
              <Sparkles size={12} className="text-amber-500" /> Quick Demo Role Logins
            </div>
            <div className="grid grid-cols-2 gap-2">
              {INITIAL_ADMINS.map((adm) => (
                <button
                  key={adm.id}
                  type="button"
                  onClick={() => handleQuickDemoLogin(adm)}
                  className="p-2 rounded-lg border border-border bg-muted/40 hover:bg-accent hover:border-primary/40 text-left transition-all group"
                >
                  <div className="text-xs font-bold text-foreground group-hover:text-primary truncate">
                    {adm.name.split(" ")[0]}
                  </div>
                  <div className="text-[10px] text-muted-foreground">{adm.role}</div>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
