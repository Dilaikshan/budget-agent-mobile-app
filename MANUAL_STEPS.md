# Budget Agent — manual setup, step by step

What is already done for you (2026-09-29):

- **Backend deployed** to Vercel project `dilax/budget-agent-backend` → **https://budget-agent-backend.vercel.app**
  - `GET /api/health` returns `{"status":"ok","version":"1"}`.
  - Data/AI routes intentionally return `503 SYNC_UNAVAILABLE` until you add the Firebase secrets below.
  - Already set in Vercel (Production): `APP_ENV=production`, `AI_ENABLED=false`, `FALLBACK_ENABLED=false`, and randomly generated `CRON_SECRET` and `CURSOR_SIGNING_KEY` (view them in Vercel → Project → Settings → Environment Variables).
  - Daily cron `/api/jobs/daily-agent` is scheduled at `0 1 * * *` UTC (~06:30 Sri Lanka).
- **Flutter Android app** in `mobile/` (package id `com.dilaxdigit.budget_agent`). Flutter SDK was installed at `C:\Users\digit\flutter-sdk`.

Everything below needs your accounts or decisions. Do the steps in order. Values you collect are marked **➜ SAVE**.

---

## 1. Create the Firebase project

1. Open https://console.firebase.google.com → **Add project** → name e.g. `budget-agent-prod` (Google Analytics optional). Stay on the free **Spark** plan.
2. **Build → Firestore Database → Create database** → *Production mode* → choose a region once (e.g. `asia-south1` Mumbai, closest to Sri Lanka).
3. **Project settings → General**: **➜ SAVE** the *Project ID* and *Project number*.

## 2. Enable sign-in providers

1. **Build → Authentication → Get started → Sign-in method**.
2. Enable **Email/Password**.
3. Enable **Google**, choose a support email, save. Open the Google provider again → *Web SDK configuration* → **➜ SAVE the Web client ID** (ends with `.apps.googleusercontent.com`).

## 3. Register the Android app

1. Get your debug keystore fingerprints (PowerShell):
   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   (If the keystore does not exist yet, run the app once in step 9 and come back.)
2. Firebase **Project settings → Your apps → Add app → Android**:
   - Package name: `com.dilaxdigit.budget_agent`
   - Paste the **SHA-1**; after creating, also **Add fingerprint** → the **SHA-256**.
   - You do **not** need to download `google-services.json` (the app is configured with build defines).
3. From the app card **➜ SAVE**: *App ID* (`1:…:android:…`) and the *Web API key* (Project settings → General).

## 4. Deploy Firestore rules and indexes (deny-all client access)

```powershell
npm install -g firebase-tools
firebase login
cd C:\Users\digit\Documents\dilaxdigit\Projects\budgent-agent-system
firebase use --add            # pick your project, alias "prod"
firebase deploy --only firestore:rules,firestore:indexes
```
Wait until **Firestore → Indexes** shows all composite indexes as *Enabled*.

## 5. Create a least-privilege service account for the backend

1. Open https://console.cloud.google.com/iam-admin/serviceaccounts (select the same project) → **Create service account** `budget-agent-backend`.
2. Grant roles: **Cloud Datastore User** and **Firebase Authentication Viewer**. (Do not grant Owner/Editor.)
3. Open it → **Keys → Add key → JSON** → download. **Keep this file private; never commit it.**
4. From the JSON **➜ SAVE** `client_email` and `private_key`.

## 6. App Check

1. Firebase **Build → App Check → Apps** → your Android app → **Play Integrity** → register (uses the SHA-256 from step 3).
2. Debug builds use the debug provider: after the first run in step 9, find the line `Enter this debug secret into the allow list …` in the run/logcat output, then **App Check → Apps → ⋮ → Manage debug tokens → Add** that token.
3. Do **not** turn on App Check "enforcement" for Firestore — clients are already denied; the backend verifies App Check itself.

## 7. Add the backend secrets to Vercel

From `backend/` (or in the Vercel dashboard → Settings → Environment Variables → Production):

```powershell
cd C:\Users\digit\Documents\dilaxdigit\Projects\budgent-agent-system\backend
vercel env add FIREBASE_PROJECT_ID production      # your Project ID
vercel env add FIREBASE_CLIENT_EMAIL production    # client_email from the JSON
vercel env add FIREBASE_PRIVATE_KEY production     # the whole private_key value (with \n's is fine)
vercel env add ALLOWED_APP_IDS production          # the Android App ID from step 3
vercel env add OWNER_UID production                # set in step 10 — you can add it later
vercel deploy --prod                               # env changes need a redeploy
```

`OWNER_UID` is required: until it is set, data routes stay 503. Only this one Firebase user can ever use the backend.

## 8. Prepare the mobile build config

```powershell
cd C:\Users\digit\Documents\dilaxdigit\Projects\budgent-agent-system\mobile
copy env\dev.example.json env\dev.json
```
Edit `env\dev.json` (it is git-ignored):

| Key | Value |
|---|---|
| `APP_ENV` | `development` |
| `API_BASE_URL` | `https://budget-agent-backend.vercel.app` |
| `FIREBASE_API_KEY` | Web API key (step 3) |
| `FIREBASE_APP_ID` | Android App ID (step 3) |
| `FIREBASE_MESSAGING_SENDER_ID` | Project number (step 1) |
| `FIREBASE_PROJECT_ID` | Project ID |
| `GOOGLE_SERVER_CLIENT_ID` | Web client ID (step 2) |
| `APP_CHECK_DEBUG` | `true` for debug builds only |

These are public client values, not secrets. **Never** put Gemini/OpenRouter keys, the service account or the cron secret in the app.

## 9. Run the app on your phone

1. Add Flutter to PATH once: `setx PATH "$env:PATH;C:\Users\digit\flutter-sdk\bin"` (open a new terminal afterwards).
2. Accept Android licences: `flutter doctor --android-licenses`. Install *Android SDK Command-line Tools* from Android Studio → SDK Manager if `flutter doctor` asks.
3. Enable **Developer options → USB debugging** on the phone and connect it (`flutter devices` should list it).
4. Run:
   ```powershell
   cd C:\Users\digit\Documents\dilaxdigit\Projects\budgent-agent-system\mobile
   flutter pub get
   flutter run --dart-define-from-file=env/dev.json
   ```
5. Register the App Check debug token printed on first run (step 6.2).

## 10. Set your owner UID

1. In the app, sign in (Google or email). Email users must click the verification link, then tap **I've verified**.
2. Firebase **Authentication → Users** → copy your **User UID**.
3. `vercel env add OWNER_UID production` → paste it → `vercel deploy --prod`.
4. In the app finish onboarding (currency LKR, time zone Asia/Colombo, accounts with opening balances, default categories, income source). Then **More → Sync & conflicts → Sync now**. Pending badges should clear; Firestore now shows `users/<your uid>/…`.

## 11. Turn on Gemini (optional, after the privacy review)

AI is off by default and the app is fully usable without it (offline rules still suggest fields).

1. Read the Gemini API terms for your account type (https://ai.google.dev/gemini-api/terms). **Unpaid tier data may be used to improve Google products** — for private financial text you should use a **paid (billing-enabled) Gemini project** or keep AI off. This is the privacy gate in docs/07.
2. Create a key at https://aistudio.google.com/app/apikey (preferably in a billing-enabled Google Cloud project with a spend cap). Pick an explicit model ID shown in AI Studio (no `latest` aliases), e.g. `gemini-3.5-flash-lite`.
3. Set in Vercel, then redeploy:
   ```powershell
   vercel env add GEMINI_API_KEY production
   vercel env add GEMINI_MODEL production               # e.g. gemini-3.5-flash-lite
   vercel env add AI_PRIVACY_POLICY_VERSION production  # exactly: pp-2026-09  (must match the app)
   vercel env add AI_PRIVACY_ELIGIBLE production        # true  (only after step 11.1)
   vercel env rm AI_ENABLED production; vercel env add AI_ENABLED production   # true
   vercel deploy --prod
   ```
4. In the app: **Settings → AI suggestions → On** (accept the disclosure). Try quick entry: `lunch kfc 2500 cash`.
5. Optional OpenRouter fallback: set `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `OPENROUTER_ALLOWED_PROVIDERS` (comma-separated upstream provider slugs you reviewed; required, otherwise fallback stays off) and `FALLBACK_ENABLED=true`, redeploy, then enable *Fallback* in app Settings.

Budget defaults: 100 provider attempts, 100k input / 20k output tokens per day (override with `AI_DAILY_*` vars). Also set a spend cap in the Google/OpenRouter dashboards.

## 12. Check the daily agent

- Vercel runs it automatically at 01:00 UTC on production. Enable *Daily review* in app Settings.
- Manual run (same-day recovery): copy `CRON_SECRET` from Vercel env settings, then
  ```powershell
  curl.exe -H "Authorization: Bearer <CRON_SECRET>" https://budget-agent-backend.vercel.app/api/jobs/daily-agent
  ```
  Expect `{"data":{"businessDate":…,"status":"succeeded"|"partial"|"skipped",…}}`. Never put the secret in a URL.

## 13. Before a real release (not done yet)

- Create an upload keystore and signing config (`android/key.properties`, git-ignored), add the **release** SHA-256 to Firebase, build with `env/prod.json` (`APP_ENV=production`, `APP_CHECK_DEBUG=false`): `flutter build appbundle --dart-define-from-file=env/prod.json`. Play Integrity needs the app distributed via Play (internal testing track is fine).
- Remaining spec work: export/restore (task 017), CI with secret scanning and Firestore emulator tests (task 018), release checklist and human review (task 019).
- Decide what to do with the root-level Vite/Express web app (`server.ts`, `src/`, `index.html`, `metadata.json`, root `package.json`): it is outside the spec and is **not** deployed.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `503 SYNC_UNAVAILABLE` | Firebase env vars missing/invalid or `OWNER_UID` not set → step 7/10, redeploy |
| `403 FORBIDDEN` | Signed-in UID ≠ `OWNER_UID` |
| `403 EMAIL_UNVERIFIED` | Click the verification email, then *I've verified* |
| `403 APP_CHECK_FAILED` | Debug token not registered, wrong `ALLOWED_APP_IDS`, or release build without Play Integrity |
| `403 AI_DISABLED` / `PRIVACY_NOT_ELIGIBLE` | Server `AI_ENABLED`/`AI_PRIVACY_ELIGIBLE` false, or app Settings consent off / policy version mismatch |
| `503 AI_UNAVAILABLE` | Gemini (and fallback) failed; manual entry keeps working |
| App shows "Configuration error" | A value is missing in `env/*.json` |
| Google sign-in fails | SHA-1 not added in Firebase or wrong `GOOGLE_SERVER_CLIENT_ID` (must be the *Web* client ID) |

Rotate any secret that leaks (Vercel env + Firebase key), and enable MFA on Vercel/Firebase/Google accounts.
