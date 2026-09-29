# Budget AI Agent — Manual Setup & Deployment Guide

This repository contains the complete implementation of the **Budget AI Agent** based on the architectural and technical specifications in `/docs`:
- **`/mobile`**: Flutter mobile application (Riverpod, go_router, Drift/SQLite local persistence, Firebase Auth & App Check, and Dio API client).
- **`/backend`**: Native Vercel Node.js TypeScript backend (`/api/v1/sync`, `/api/v1/agent`, `/api/jobs/daily-agent`) with Firebase Admin, CAS revision checking, and Gemini/OpenRouter AI routing.

Follow this step-by-step checklist to configure external cloud services, generate local code bindings, and run the system.

---

## 1. Firebase Project Setup

### 1.1 Create Firebase Project
1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project named e.g. `budget-agent-app` (or select an existing project).

### 1.2 Enable Authentication
1. Go to **Build** > **Authentication** > **Sign-in method**.
2. Enable **Email/Password**.
3. Enable **Google** sign-in provider.
4. Copy your user UID after signing up (this will be used in the `OWNER_UID_ALLOWLIST`).

### 1.3 Provision Cloud Firestore (Spark Tier)
1. Go to **Build** > **Firestore Database** > **Create database**.
2. Select a region near your primary location (e.g. `asia-southeast1` or `us-central1`).
3. Start in **Production mode**.
4. In the **Rules** tab, deploy the following strict security rule to enforce that all mutations route through the authenticated Vercel backend:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Deny all direct client mobile writes.
    // The Vercel backend uses Firebase Admin SDK (which bypasses rules) to enforce
    // atomic CAS revisions, idempotency receipts, and change sequencing.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 1.4 Generate Firebase Admin Service Account JSON
1. In Firebase Console, click the **Gear Icon** (Project Settings) > **Service accounts** tab.
2. Select **Firebase Admin SDK** (Node.js).
3. Click **Generate new private key** and download the JSON file.
4. Keep this file confidential. You will paste its contents into Vercel environment variables.

### 1.5 Configure Firebase App Check (Optional for Local Dev, Required for Production)
1. Go to **Build** > **App Check**.
2. Register your Android app (using Play Integrity or Debug provider) or iOS app (using DeviceCheck / App Attest).

---

## 2. Vercel Backend Deployment

### 2.1 Deploy Backend via Vercel CLI or GitHub
You can deploy the `/backend` directory directly to Vercel:
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Test local build & contracts
npm run test
npm run build

# Deploy to Vercel
vercel
```

### 2.2 Configure Vercel Environment Variables
In your Vercel Project Settings > **Environment Variables**, add the following:

| Variable | Description | Example / Note |
|---|---|---|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Minified raw JSON string of the Firebase service account downloaded in step 1.4 | `{"type":"service_account","project_id":"..."}` |
| `CRON_SECRET` | A secure random 32+ character secret for protecting `/api/jobs/daily-agent` | e.g. generate with `openssl rand -hex 32` |
| `GEMINI_API_KEY` | Your Google AI Studio Gemini API key | Get from [Google AI Studio](https://aistudio.google.com/app/apikey) |
| `OPENROUTER_API_KEY` | (Optional) Fallback LLM provider key | Get from [OpenRouter](https://openrouter.ai/) |
| `OPENROUTER_MODEL` | (Optional) OpenRouter fallback model | e.g. `meta-llama/llama-3.3-70b-instruct` |
| `OWNER_UID_ALLOWLIST` | Comma-separated Firebase UIDs allowed to access the instance | Your Firebase Auth UID from Step 1.2 |
| `ENFORCE_APP_CHECK` | Set to `true` in production or `false` in development | `false` (during initial setup) |

### 2.3 Verify Backend Deployment
1. Visit `https://your-vercel-domain.vercel.app/api/health`
2. You should receive:
```json
{
  "status": "ok",
  "version": "1"
}
```

---

## 3. Flutter Mobile App Local Setup

### 3.1 Prerequisites
- **Flutter SDK**: `>= 3.16.0` (Dart `>= 3.2.0`)
- **Android Studio / Xcode** with configured emulator or connected physical device

### 3.2 Add Firebase Platform Configuration Files
1. In Firebase Console > **Project Settings** > **General**:
   - For **Android**: Add an Android app with package name `com.example.budget_agent`. Download `google-services.json` and place it in:
     `mobile/android/app/google-services.json`
   - For **iOS**: Add an iOS app with bundle ID `com.example.budgetAgent`. Download `GoogleService-Info.plist` and place it in:
     `mobile/ios/Runner/GoogleService-Info.plist`

### 3.3 Install Flutter Dependencies & Generate Drift SQLite Code
Run the following commands inside `/mobile`:
```bash
cd mobile

# 1. Fetch dependencies
flutter pub get

# 2. Run Drift SQLite code generator (generates app_database.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 3. Run Flutter unit tests (verifies ledger arithmetic & invariants)
flutter test
```

### 3.4 Run the Flutter App
Launch the app with your deployed Vercel backend URL:
```bash
flutter run --dart-define=BACKEND_BASE_URL=https://your-vercel-domain.vercel.app \
            --dart-define=DEFAULT_CURRENCY=LKR \
            --dart-define=CURRENCY_EXPONENT=2 \
            --dart-define=DEFAULT_TIMEZONE=Asia/Colombo
```

---

## 4. Key Architectural Invariants To Keep in Mind

1. **Integer Minor Units**: All monetary amounts are handled as integer minor units (`amountMinor`). Never use floating-point numbers for financial calculations.
2. **Deterministic Ledger**: Account balances and net worth are strictly derived from confirmed transactions (`balance(a) = sum(effect(t,a))`).
3. **Explicit Mutation Confirmation**: AI models never execute mutations or create transactions automatically. AI generates structured proposals; the user must explicitly inspect and confirm the payload before it enters the ledger.
4. **Offline-First Synchronization**: Local Drift writes are atomic with outbox enqueue. The Vercel gateway validates CAS revisions and assigns monotonic change sequences.

---

## 5. Summary of Files Created

```text
/backend
  ├── api/
  │    ├── health.ts
  │    ├── jobs/daily-agent.ts
  │    └── v1/
  │         ├── agent/parse-transaction.ts
  │         ├── agent/classify-transaction.ts
  │         ├── agent/insights.ts
  │         └── sync/
  │              ├── push.ts
  │              └── changes.ts
  ├── src/
  │    ├── auth/guards.ts
  │    ├── contracts/schemas.ts
  │    ├── firestore/repositories.ts
  │    └── ai/router.ts
  ├── test/contracts.test.ts
  ├── package.json
  ├── tsconfig.json
  └── vercel.json

/mobile
  ├── lib/
  │    ├── core/
  │    │    ├── config/app_config.dart
  │    │    ├── database/
  │    │    │    ├── tables.dart
  │    │    │    └── app_database.dart
  │    │    ├── ledger/ledger_calculator.dart
  │    │    ├── network/api_client.dart
  │    │    └── theme/app_theme.dart
  │    ├── features/
  │    │    ├── dashboard/presentation/dashboard_screen.dart
  │    │    ├── transactions/presentation/
  │    │    │    ├── ledger_screen.dart
  │    │    │    └── transaction_entry_sheet.dart
  │    │    ├── accounts/presentation/accounts_screen.dart
  │    │    ├── budgets/presentation/budgets_screen.dart
  │    │    └── settings/presentation/settings_screen.dart
  │    └── main.dart
  ├── test/ledger_test.dart
  ├── pubspec.yaml
  └── analysis_options.yaml

/MANUAL_STEPS.md
```
