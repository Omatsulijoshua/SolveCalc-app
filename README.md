# 📱 SolveCalc — AI Scientific Calculator & Enterprise Admin Suite

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Next.js](https://img.shields.io/badge/Next.js-14.2-black?logo=next.js&logoColor=white)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-38B2AC?logo=tailwind-css&logoColor=white)](https://tailwindcss.com)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)](#)

**SolveCalc** is an advanced mathematical intelligence platform combining a **Flutter iOS & Android Mobile Application** with a full-scale **Next.js 14 Enterprise Administration & Monetization Console**.

---

## 🏛️ Monorepo Architecture

```
solvecalc/
├── apk/                              # Production Android Release Build
│   └── app-release.apk               # Pre-compiled optimized production APK (51.6MB)
│
├── app/                              # SolveCalc Flutter Mobile Application (iOS / Android)
│   ├── lib/
│   │   ├── core/                     # Math token constants, theme presets, haptics
│   │   ├── domain/
│   │   │   ├── calculator/           # Lexer, Parser, AST Expression Evaluator (DEG/RAD)
│   │   │   ├── solver/               # Deterministic Solver & Step-by-Step Verifier
│   │   │   ├── ai/                   # Groq Cloud Vision & Llama-3.3-70b Math Engine
│   │   │   ├── ads/                  # Multi-Network AdManager, Fallback Waterfall, Remote Config
│   │   │   │   └── providers/        # AdMob, Network B (AppLovin), Network C (Unity), House Ads
│   │   │   └── monetization/         # PremiumEntitlement Lifetime Model ($10 USD)
│   │   ├── data/                     # Secure Storage & In-App Purchase Receipt Verification
│   │   ├── presentation/             # Riverpod Providers & Responsive Widgets
│   │   └── features/                 # Calculator, OCR Scanner, Solver, Paywall, Settings
│   ├── test/                         # 46 Passing Unit, Widget, & Solver Test Suites
│   └── pubspec.yaml
│
├── admin/                            # SolveCalc Enterprise Next.js 14 Admin Dashboard
│   ├── src/
│   │   ├── app/                      # 25 App Router Pages (100% Fully Responsive)
│   │   │   ├── dashboard/            # Real-Time Operational KPI Command Center
│   │   │   ├── monetization/         # Combined Revenue Hub, Ads, Providers, House Ads, Rollback
│   │   │   ├── users/                # User Management & Drawer Profiles
│   │   │   ├── calculator/           # Arithmetic Stream & Function Popularity
│   │   │   ├── scanner/              # OCR Side-by-Side Quality Review Inspector
│   │   │   ├── ai/solutions/         # Step-by-Step Mathematical Proof Inspector & Reports
│   │   │   ├── themes/               # 9 Theme Presets Manager + Live Interactive Mobile Simulator
│   │   │   ├── notifications/        # Push Broadcast Composer & Segment Targeting
│   │   │   ├── analytics/ & reports/ # Cohort Retention Curves & One-Click CSV Exports
│   │   │   ├── admins/ & audit-logs/ # RBAC Directory, 2FA, & Immutable Activity Logs
│   │   │   └── settings/             # System Health, Live Feature Flags, & Version Enforcement
│   │   ├── components/               # Mobile Drawer Layout, Charts, Global Search Modal
│   │   ├── services/                 # Async API Service Layer & Relational Seed Data
│   │   ├── lib/                      # 5-Role RBAC Permissions & Dark/Light Theme Engine
│   │   └── types/                    # Strict TypeScript Interfaces
│   ├── package.json
│   └── tailwind.config.ts
│
└── README.md                         # Project Master Documentation
```

---

## 📱 1. Flutter Mobile Application Features

### 🧮 1. Mathematical Engine & Scientific Calculator
* **Custom Lexer & Recursive-Descent Parser**: Evaluates nested parentheses, implicit multiplication ($2(3+4)$, $2\sin(30)$), unary negatives, factorial ($5! = 120$), exponentiation, and root extraction.
* **Trigonometry & Calculus Modes**: Supports `DEG` (Degrees), `RAD` (Radians), and `GRAD` with high-precision trigonometric, hyperbolic ($\sinh$, $\cosh$), logarithmic ($\log_{10}$, $\ln$), and constants ($\pi$, $e$).

### 📸 2. Camera Math Scanner & Multi-Stage Math OCR
* **Real-time Camera Crop & OCR**: Optical character recognition translating handwritten equations and textbook math into structured mathematical notation.
* **Multi-Stage MathOcrService**: Features intelligent pre-processing and pipeline selection (replacing deprecated direct vision models) to provide extremely precise text/image formula parsing.
* **Dual-Engine Solving**:
  1. **Deterministic Local Solver**: Linear algebra ($ax+b=c$), quadratic equations ($ax^2+bx+c=0$), and simultaneous systems.
  2. **Groq Cloud LLM Solver**: `llama-3.3-70b-versatile` delivering step-by-step proofs with pedagogical *"Why This Step"* explanations.
* **Deterministic Verifier**: Cross-checks AI outputs against algebraic rules before presenting solutions to users.

### 🎨 3. 9 Premium Themes Engine
1. **Pure White**: Minimalist aesthetic with high-contrast slate typography.
2. **Casio Scientific**: Retro vintage Casio fx-991EX calculator casing with green LCD matrix styling.
3. **Midnight Blue**: Deep navy blue with electric sapphire accents.
4. **Classic Dark**: Charcoal black OLED palette.
5. **Ocean Cyan**: Vibrant seafoam and cyan contrasts.
6. **Emerald Forest**: Rich dark emerald and mint highlights.
7. **Cyber Purple**: Neon cyberpunk violet palette.
8. **Sunset Orange**: Amber, tangerine, and warm dark hues.
9. **Minimal Light**: Soft off-white design with charcoal keys.

---

## 💰 2. Monetization & Multi-Network Advertising System

### 💎 $10 USD Lifetime In-App Purchase Entitlement
* **One-Time Non-Consumable**: Available on **Apple StoreKit** and **Google Play Billing** under product ID `solvecalc_premium_lifetime`.
* **Zero Ads Invariant**: Pro users permanently receive zero advertisements across all placements with **zero blank layout space**.
* **Restore Purchases**: One-tap restore flow on reinstall or device change.
* **Unlimited Features**: Unlocks all 9 themes, unlimited AI camera snapping, and step-by-step Learn Mode.

### 📡 Multi-Network Ad Waterfall Architecture
The mobile application contains integrated SDK adapters configured remotely by the Admin Dashboard:

```
                      [ Ad Request Initiated ]
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │  Check User Tier ==   │──( Yes )──► [ NO ADS SHOWN ]
                     │       PREMIUM?        │
                     └───────────┬───────────┘
                                 │ ( No )
                                 ▼
                     ┌───────────────────────┐
                     │ Emergency Kill Switch │──( Active )► [ NO ADS SHOWN ]
                     │       Enabled?        │
                     └───────────┬───────────┘
                                 │ ( Normal )
                                 ▼
                     ┌───────────────────────┐
                     │ 1. Google AdMob       │──( Filled )──► [ Render Ad ]
                     │    (Primary Network)  │
                     └───────────┬───────────┘
                                 │ ( Error / No-Fill )
                                 ▼
                     ┌───────────────────────┐
                     │ 2. Network B Adapter  │──( Filled )──► [ Render Ad ]
                     │    (AppLovin MAX)     │
                     └───────────┬───────────┘
                                 │ ( Error / No-Fill )
                                 ▼
                     ┌───────────────────────┐
                     │ 3. Network C Adapter  │──( Filled )──► [ Render Ad ]
                     │    (Unity Ads)        │
                     └───────────┬───────────┘
                                 │ ( Error / No-Fill )
                                 ▼
                     ┌───────────────────────┐
                     │ 4. SolveCalc House    │──────────────► [ Render House Ad ]
                     │    Promotions Engine  │
                     └───────────────────────┘
```

* **App-Open Frequency Controls**: Configurable cooldown interval (default 15 minutes) and max 1 ad per session.
* **Top Banner Placement**: Automatically resizes without blank layout space.
* **House Ads Fallback**: Promotes SolveCalc Pro lifetime and new theme updates.

---

## 💻 3. Enterprise Next.js Admin Dashboard

### 🛡️ 1. Role-Based Access Control (RBAC)
Supports 5 distinct administrative roles with instant context switching in the navigation bar:
* **`SUPER_ADMIN`**: Full platform control, remote ad config publishing, kill switch activation, administrator management.
* **`ADMIN`**: User management, content moderation, theme configuration, push notifications.
* **`MODERATOR`**: OCR quality review, user solution issue reports resolution.
* **`SUPPORT`**: User status management and user lookup.
* **`ANALYST`**: Read-only financial analytics, retention curves, and CSV report downloads.

### 📱 2. Mobile-First Responsive Design
* **Mobile Drawer Navigation**: Responsive slide-out sheet on mobile devices (`< 1024px`) with backdrop blur.
* **Touch-Optimized Data Tables**: Horizontal smooth scrolling (`overflow-x-auto`) for data grids on smartphones and tablets.
* **Adaptive Chart Viewports**: Recharts responsive containers automatically adjusting to portrait and landscape viewports.

### 📈 3. Monetization Suite Pages
* `/monetization`: Overview KPI summary, combined revenue curves, emergency mode selector (`NORMAL`, `ADS DISABLED`, `PREMIUM ONLY`, `HOUSE ADS ONLY`).
* `/monetization/premium`: Lifetime purchase ledger with StoreKit/Play receipt validation modal.
* `/monetization/ad-providers`: Multi-network priority waterfall hierarchy and health telemetry.
* `/monetization/house-ads`: Self-hosted campaign builder with impressions, clicks, and CTR metrics.
* `/monetization/remote-config`: Dynamic ad cooldown adjustments with versioning (`Config v43`) and 1-click **Rollback to v42**.
* `/monetization/alerts`: Health telemetry detecting fill-rate drops ($<10\%$) and latency spikes.

---

## 🚀 Getting Started

### Prerequisites
* **Flutter SDK** $\ge 3.12.0$ & Dart $\ge 3.11.0$ (Supports local environments running Dart 3.11.4+)
* **Node.js** $\ge 18.17.0$ & **npm** $\ge 9.0.0$

---

### 📱 Running the Mobile App (`app/`)

#### 📲 Pre-compiled Release Android Package (APK)
If you just want to run/install the application on your Android device without compiling the source code, you can download the pre-built optimized production APK directly:
* **Release Artifact File**: [apk/app-release.apk](file:///c:/Users/SirBill's/Desktop/SolveCalc-app-main/SolveCalc-app-main/apk/app-release.apk)
* **Optimizations**: Built with release mode optimization, including resource/icon tree-shaking (51.6MB size).

#### 🛠️ Building & Running from Source
```bash
# 1. Navigate to the mobile directory
cd app

# 2. Install dependencies
flutter pub get

# 3. Run unit and widget tests
flutter test

# 4. Launch the application
flutter run
```

---

### 💻 Running the Admin Dashboard (`admin/`)

```bash
# 1. Navigate to the admin directory
cd admin

# 2. Install dependencies
npm install

# 3. Run development server (configured on port 3001)
npm run dev
```

Open [http://localhost:3001](http://localhost:3001) in your browser.

#### Demo Administrator Logins:
* **Super Admin**: `sarah.admin@solvecalc.com`
* **Operations Admin**: `alex.r@solvecalc.com`
* **Moderator**: `mia.mod@solvecalc.com`
* **Data Analyst**: `andy.analyst@solvecalc.com`

---

## 🧪 Testing & Verification

```bash
# Run Mobile Test Suite (46 Tests)
cd app
flutter test

# Verify Mobile Static Analysis
flutter analyze

# Build Admin Dashboard Production Bundle (25 Pages)
cd admin
npm run build
```

---

## 🔒 Security & Privacy

* **Zero Client Secrets**: No private API keys or payment verification secrets are exposed in client builds.
* **Immutable Audit Trail**: All administrative actions (user suspensions, config rollbacks, ad toggles) are cryptographically logged with timestamp and operator identity.
* **Safe Offline Fallbacks**: If the device loses internet connectivity, the calculator engine operates 100% offline with cached premium entitlements.

---

## 📄 License

Proprietary software. All rights reserved by SolveCalc Team.
