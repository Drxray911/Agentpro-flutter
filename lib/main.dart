import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/app_providers.dart';
import 'core/constants/app_routes.dart';
import 'core/navigation/app_shell.dart';

// Auth
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/data/auth_repository.dart' show resolvedRoleProvider;

// Dashboard
import 'features/dashboard/presentation/screens/role_dashboard_router.dart';

// Phase 1 features
import 'features/momo/presentation/screens/momo_screen.dart';
import 'features/ussd/presentation/screens/ussd_screen.dart';
import 'features/float/presentation/screens/float_screen.dart';
import 'features/commission/presentation/screens/commission_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/ai/presentation/screens/ai_screen.dart';

// Phase 2 features
import 'features/branches/presentation/screens/branches_screen.dart';
import 'features/customers/presentation/screens/customers_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';

// Phase 3 features
import 'features/market/presentation/screens/market_screen.dart';
import 'features/ecash/presentation/screens/ecash_screen.dart';
import 'features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'features/admin/presentation/screens/admin_screen.dart';

void main() {
  // TODO: uncomment for production
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const ProviderScope(child: AgentProGhanaApp()));
}

class AgentProGhanaApp extends ConsumerWidget {
  const AgentProGhanaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    return MaterialApp(
      title: 'Agent Pro Ghana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // ── Auth ──────────────────────────────────────────────────────
      case AppRoutes.login:
        return _fade(const LoginScreen());

      // ── Main tabbed shell ─────────────────────────────────────────
      case AppRoutes.dashboard:
        return _fade(const _HomeShell());

      // ── Phase 1 ───────────────────────────────────────────────────
      case AppRoutes.momo:
        return _slide(const MomoScreen());
      case AppRoutes.ussd:
        return _slide(const UssdScreen());
      case AppRoutes.float:
        return _slide(const FloatScreen());
      case AppRoutes.commission:
        return _slide(const CommissionScreen());
      case AppRoutes.settings:
        return _slide(const SettingsScreen());
      case AppRoutes.ai:
        return _slide(const AiScreen());

      // ── Phase 2 ───────────────────────────────────────────────────
      case AppRoutes.branches:
        return _slide(const BranchesScreen());
      case AppRoutes.customers:
        return _slide(const CustomersScreen());
      case AppRoutes.reports:
        return _slide(const ReportsScreen());
      case AppRoutes.notifications:
        return _slide(const NotificationsScreen());

      // ── Phase 3 ───────────────────────────────────────────────────
      case AppRoutes.market:
        return _slide(const MarketScreen());
      case AppRoutes.ecash:
        return _slide(const EcashScreen());
      case AppRoutes.subscriptions:
        return _slide(const SubscriptionsScreen());
      case AppRoutes.admin:
        return _slide(const AdminScreen());

      // ── Sub-screens ───────────────────────────────────────────────
      case AppRoutes.myAds:
        return _slide(const MyAdsScreen());
      case AppRoutes.sell:
        return _slide(const SellScreen());
      case AppRoutes.savedAds:
        return _slide(const SavedAdsScreen());
      case AppRoutes.createOwner:
        return _slide(const CreateOwnerScreen());

      // ── Catch-all ─────────────────────────────────────────────────
      default:
        return MaterialPageRoute(
          builder: (_) => _NotImplemented(routeName: settings.name ?? '?'),
        );
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );

  static PageRoute _slide(Widget page) => MaterialPageRoute(builder: (_) => page);
}

/// Bottom-nav shell. 5 tabs keyed to user role.
///
/// Tab 0 → RoleDashboard   (agent / manager / owner / auditor)
/// Tab 1 → MoMo            (agents only; others see permission notice)
/// Tab 2 → Float
/// Tab 3 → Market
/// Tab 4 → Settings
class _HomeShell extends ConsumerWidget {
  const _HomeShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(resolvedRoleProvider);
    return AppShell(
      screenBuilder: (index) => switch (index) {
        0 => const RoleDashboard(),
        1 => role.canTransact
            ? const MomoScreen()
            : const _PermissionScreen(
                icon: '💸',
                message: 'MoMo operations are only\navailable to Agents.',
              ),
        2 => const FloatScreen(),
        3 => const MarketScreen(),
        _ => const SettingsScreen(),
      },
    );
  }
}

class _PermissionScreen extends StatelessWidget {
  final String icon;
  final String message;
  const _PermissionScreen({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: c.muted, height: 1.6)),
          ]),
        ),
      ),
    );
  }
}

class _NotImplemented extends StatelessWidget {
  final String routeName;
  const _NotImplemented({required this.routeName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🏗', style: TextStyle(fontSize: 56, color: c.muted)),
            const SizedBox(height: 12),
            Text('"$routeName" not yet wired.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.charcoal),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('See Developer Specification §3 for the full 77-screen inventory.',
                style: TextStyle(fontSize: 13, color: c.muted, height: 1.6),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
