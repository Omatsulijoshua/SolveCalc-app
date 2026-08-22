"use client";

import React from "react";
import {
  FileText,
  Download,
  Users,
  Calculator,
  Brain,
  Camera,
  ShieldCheck,
} from "lucide-react";
import { AdminLayout } from "@/components/layout/AdminLayout";
import { adminService } from "@/services/adminService";

export default function ReportsPage() {
  const downloadReport = async (type: "users" | "calculations" | "ai" | "scans") => {
    let content = "";
    let filename = "";

    if (type === "users") {
      const res = await adminService.getUsers({ limit: 100 });
      content = "ID,Name,Email,Status,AccountType,Calculations,AISolves,Scans,Platform,Version\n" +
        res.users.map((u) => `"${u.id}","${u.name}","${u.email}","${u.status}","${u.accountType}",${u.calculationsCount},${u.aiSolvesCount},${u.scansCount},"${u.devicePlatform}","${u.appVersion}"`).join("\n");
      filename = `solvecalc_users_report_${Date.now()}.csv`;
    } else if (type === "calculations") {
      const calcs = await adminService.getCalculations();
      content = "ID,User,Expression,Result,Mode,AngleMode,IsError,Timestamp\n" +
        calcs.map((c) => `"${c.id}","${c.userName}","${c.expression}","${c.result}","${c.mode}","${c.angleMode}",${c.isError},"${c.timestamp}"`).join("\n");
      filename = `solvecalc_calculations_report_${Date.now()}.csv`;
    } else if (type === "ai") {
      const sols = await adminService.getAISolutions();
      content = "ID,User,Question,QuestionType,FinalAnswer,Provider,Model,Tokens,LatencyMs,Verification,Status\n" +
        sols.map((s) => `"${s.id}","${s.userName}","${s.question}","${s.questionType}","${s.finalAnswer}","${s.provider}","${s.model}",${s.tokensUsed},${s.latencyMs},"${s.verificationStatus}","${s.status}"`).join("\n");
      filename = `solvecalc_ai_solutions_report_${Date.now()}.csv`;
    } else if (type === "scans") {
      const scans = await adminService.getScans();
      content = "ID,User,RawOCR,CorrectedText,FinalQuestion,Confidence,LatencyMs,Status\n" +
        scans.map((s) => `"${s.id}","${s.userName}","${s.rawOcrText}","${s.correctedText || ''}","${s.finalQuestion}",${s.confidence},${s.latencyMs},"${s.status}"`).join("\n");
      filename = `solvecalc_scanner_report_${Date.now()}.csv`;
    }

    const blob = new Blob([content], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = filename;
    a.click();
  };

  const reportItems = [
    {
      title: "Complete User Database Report",
      description: "All registered user records, lifetime calculation counts, subscription tiers, and app versions.",
      icon: Users,
      color: "text-blue-500",
      type: "users" as const,
    },
    {
      title: "Calculation Activity & History Report",
      description: "Evaluated arithmetic & scientific expressions, angle modes (DEG/RAD), and error rates.",
      icon: Calculator,
      color: "text-emerald-500",
      type: "calculations" as const,
    },
    {
      title: "AI Mathematics Solutions & Accuracy",
      description: "Mathematical question logs, final answers, Groq LLM telemetry, and deterministic verification results.",
      icon: Brain,
      color: "text-purple-500",
      type: "ai" as const,
    },
    {
      title: "Camera Math Scanner & OCR Logs",
      description: "Vision recognition raw outputs, user correction differences, and confidence ratings.",
      icon: Camera,
      color: "text-amber-500",
      type: "scans" as const,
    },
  ];

  return (
    <AdminLayout>
      <div className="space-y-6 animate-in fade-in">
        <div>
          <h1 className="text-2xl font-black text-foreground flex items-center gap-2">
            <FileText className="text-blue-500" /> Exportable Data Reports & Compliance
          </h1>
          <p className="text-xs text-muted-foreground mt-0.5">
            Download standard CSV & JSON compliance exports with audit trail tracking.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {reportItems.map((rep, idx) => {
            const Icon = rep.icon;
            return (
              <div key={idx} className="p-6 rounded-2xl border border-border bg-card shadow-sm flex flex-col justify-between space-y-4">
                <div className="flex items-start gap-4">
                  <div className="p-3 rounded-xl bg-accent border border-border shrink-0">
                    <Icon size={24} className={rep.color} />
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-foreground">{rep.title}</h3>
                    <p className="text-xs text-muted-foreground mt-1 leading-relaxed">{rep.description}</p>
                  </div>
                </div>

                <div className="flex justify-end pt-2 border-t border-border">
                  <button
                    onClick={() => downloadReport(rep.type)}
                    className="flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-primary-foreground text-xs font-bold hover:bg-primary/90 transition-all"
                  >
                    <Download size={14} />
                    <span>Download CSV</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </AdminLayout>
  );
}
