import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_role.dart';

/// Currently logged-in user's role. Drives which dashboard variant renders.
final currentRoleProvider = StateProvider<UserRole>((ref) => UserRole.agent);

/// Dark mode toggle, controlled from SettingsScreen.
final darkModeProvider = StateProvider<bool>((ref) => false);

/// Network connectivity flag, used to show the offline banner site-wide.
final isOnlineProvider = StateProvider<bool>((ref) => true);

/// Whether the first-time welcome tour has been dismissed.
final tourDismissedProvider = StateProvider<bool>((ref) => false);

/// Simple display name for the logged-in user (replace with real auth state).
final currentUserNameProvider = Provider<String>((ref) => 'Kwame Asante');
