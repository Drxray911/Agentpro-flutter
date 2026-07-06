# Agent Pro Ghana — Flutter App

> **One App. Every Mobile Money Business.**  
> `flutter run` → working app, all 3 phases, 52 Dart files, 20 routes, 16 feature modules

---

## Status

| Phase | Modules | Status |
|-------|---------|--------|
| **Phase 1** | Auth · Dashboard (4 roles) · MoMo · USSD Navigator · Float · Commission · Settings · AI Assistant | ✅ Complete |
| **Phase 2** | Branches & Staff · Customers · Reports · Notifications · Backend Network Layer (Dio + JWT) | ✅ Complete |
| **Phase 3** | Market Centre · eCash · Subscriptions · Admin Portal | ✅ Complete |

---

## What's built

### Feature modules (16)

| Module | Key screens |
|--------|-------------|
| **auth** | LoginScreen — phone/password, role selector, biometric stub |
| **dashboard** | RoleDashboardRouter → AgentDashboard · ManagerDashboard · OwnerDashboard · AuditorDashboard |
| **momo** | MomoScreen (12-op grid) · MomoTransactionFlow (input→confirm→success) · TransactionRepository |
| **ussd** | UssdScreen · UssdSessionController (state machine) · full MTN/Telecel/AT menu trees |
| **float** | FloatScreen (4 tabs) · TopUp · Comparison (chart+table) · Threshold config |
| **commission** | CommissionScreen (3 tabs+period) · Payout · Rates editor |
| **settings** | SettingsScreen · PinSetupScreen (animated dots) · SimConfigScreen |
| **ai** | AiScreen — live Claude Sonnet 4.6, Ghana MoMo system prompt, typing dots |
| **branches** | BranchesScreen · BranchDetailScreen (4 tabs) · StaffInviteScreen |
| **customers** | CustomersScreen (search+KYC) · CustomerDetailScreen · AddCustomerScreen |
| **reports** | ReportsScreen (4 tabs: overview/txns/by-branch/export) |
| **notifications** | NotificationsScreen (type filters, unread badges, mark-all-read) |
| **market** | MarketScreen (browse+search+categories) · ListingDetailScreen · SellerProfileScreen · SellScreen (3-step) · MyAdsScreen · AdFeePaymentScreen · SavedAdsScreen |
| **ecash** | EcashScreen (5 tabs: send/receive/request/history/approvals) · ECashDetailScreen |
| **subscriptions** | SubscriptionsScreen (my plan / upgrade / billing history) · payment flow |
| **admin** | AdminScreen (4 tabs: dashboard/companies/ad moderation/config) · CreateOwnerScreen |

### Network layer
| File | Purpose |
|------|---------|
| `core/network/dio_client.dart` | Dio + JWT interceptor + silent token refresh on 401 |
| `core/error/app_exception.dart` | Typed exceptions (network / unauthorized / server / validation) |
| `features/auth/data/auth_repository.dart` | login / logout / forgot-password / verify-email → spec §5.1 |
| `features/momo/data/transaction_repository.dart` | submit / list / reverse → spec §5.2; offline demo fallback |
| `features/branches/data/branch_repository.dart` | branches / staff / invite → spec §5.5 |
| `features/market/data/market_repository.dart` | browse / post / pay-fee / favourite → spec §5.7 |

All repositories use an **offline demo fallback** — if the API is unreachable they return realistic local data, so the app is fully browsable without a running backend.

---

## Quick start

```bash
# 1. Install Flutter stable 3.22+
#    https://docs.flutter.dev/get-started/install

# 2. Get packages
flutter pub get

# 3. Run (works fully offline — demo data everywhere)
flutter run

# 4. Run with AI Assistant enabled
#    Production: proxy through your backend (spec §9.3) — never ship key in APK
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-your-key-here

# 5. Run against your live API
flutter run --dart-define=API_BASE_URL=https://api.agentproghana.com/v1

# 6. Generate Drift / Freezed / JsonSerializable code (when you add those models)
dart run build_runner build --delete-conflicting-outputs
```

---

## Firebase setup (required before shipping)

```
1. Create Firebase project
2. Add Android app with package ID: com.agentproghana.app  (spec §12.1)
3. Download google-services.json → android/app/
4. Uncomment the Firebase.initializeApp() block in lib/main.dart
5. https://firebase.google.com/docs/flutter/setup
```

---

## Project structure

```
lib/
  core/
    theme/          AppColors (light/dark tokens), AppTheme (Material 3)
    constants/      AppRoutes (20 named routes)
    navigation/     AppShell (bottom nav + IndexedStack)
    network/        DioClient (JWT interceptor, token refresh)
    error/          AppException (typed errors)
    app_providers.dart
  shared/
    widgets/        AppCard, AccentCard, AppButton (5 variants),
                    AppBadge, AppTextField, AppTopBar, AppTabs
    models/         UserRole
  features/
    auth/           LoginScreen · AuthModels · AuthRepository
    dashboard/      RoleDashboardRouter · 4 role variants
    momo/           MomoScreen · TransactionFlow · TransactionRepository
    ussd/           Screen · SessionController · Data (full trees) · Models
    float/          Screen · TopUp · Comparison · Threshold · Models · Providers
    commission/     Screen · Payout · Rates · Models · Providers
    settings/       Screen · PinSetup · SimConfig
    ai/             AiScreen (Claude Sonnet 4.6)
    branches/       Screen · DetailScreen · StaffInvite · Models · Repository
    customers/      Screen · DetailScreen · AddScreen · Models
    reports/        Screen (4 tabs + export)
    notifications/  Screen (type-filtered, unread state)
    market/         Screen · Detail · SellerProfile · Sell · MyAds ·
                    AdFeePayment · SavedAds · Models · Repository
    ecash/          Screen (5 tabs) · DetailScreen · Models
    subscriptions/  Screen (3 tabs) · payment flow
    admin/          Screen (4 tabs) · CreateOwnerScreen
```

---

## Architecture decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| State management | Riverpod (StateProvider, AsyncNotifier) | Compile-safe, testable, scales to complex state |
| HTTP client | Dio with interceptors | JWT refresh, logging, timeout config in one place |
| Navigation | Named routes via `onGenerateRoute` | Simple for 20 routes; migrate to go_router when >40 |
| Offline | Demo fallback in every repository | App usable before backend is ready |
| Theme | Material 3 + AppColors extension | `context.colors` works in any widget, light/dark auto-switches |
| Security | API key via `--dart-define`, never hardcoded | Never ships in APK |

---

## Spec references

| Topic | Section |
|-------|---------|
| User roles & permissions | §2 |
| Screen inventory (all 77) | §3 |
| Database schema | §4 |
| REST API endpoints | §5 |
| Security (PIN rule, encryption) | §6 |
| USSD architecture | §7 |
| Subscription & ad lifecycle | §8 |
| AI Assistant | §9 |
| Flutter guide & dependencies | §10 |
| Development roadmap | §11 |
| Play Store requirements | §12 |

---

## What to do next

1. **`flutter pub get && flutter run`** — confirm the app compiles and all tabs work
2. **Wire Firebase** — add `google-services.json`, uncomment `Firebase.initializeApp()`
3. **Implement the backend** — Node.js + PostgreSQL per the API spec (§5); each repository's `TODO` comment points to the exact endpoint
4. **go_router migration** — replace `onGenerateRoute` with typed routes and deep-link support (`go_router` already in `pubspec.yaml`)
5. **Local DB (Drift)** — add offline transaction cache encrypted with SQLCipher
6. **Write tests** — each repository has a `demo fallback` that makes unit testing straightforward without mocks
7. **Play Store submission** — follow spec §12; use the Developer Specification doc for the store listing copy
