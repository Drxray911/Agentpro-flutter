/// Centralised route path constants.
/// Mirrors the `screen` keys used in the React prototype's switch statement.
class AppRoutes {
  AppRoutes._();

  // Auth
  static const login          = '/login';
  static const onboarding     = '/onboarding';
  static const emailVerify    = '/emailverify';

  // Main tabs (rendered inside AppShell)
  static const dashboard      = '/dashboard';

  // Feature screens (pushed full-screen above shell)
  static const momo           = '/momo';
  static const ussd           = '/ussd';
  static const float          = '/float';
  static const commission     = '/commission';
  static const settings       = '/settings';
  static const ai             = '/ai';
  static const market         = '/market';
  static const reports        = '/reports';
  static const notifications  = '/notifications';
  static const branches       = '/branches';
  static const customers      = '/customers';
  static const ecash          = '/ecash';
  static const subscriptions  = '/subscriptions';
  static const admin          = '/admin';

  // Sub-screens (deep-linked from feature screens)
  static const profile        = '/profile';
  static const support        = '/support';
  static const audit          = '/audit';
  static const fraud          = '/fraud';
  static const myAds          = '/myads';
  static const sell           = '/sell';
  static const savedAds       = '/savedads';
  static const createOwner    = '/createowner';
  static const bizProfile     = '/bizprofile';
  static const floatComparison = '/floatcomparison';
  static const scheduledReports = '/scheduledreports';
}
