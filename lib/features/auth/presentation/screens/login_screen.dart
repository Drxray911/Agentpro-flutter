import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Port of the prototype's LoginScreen.
/// Phone + password fields, demo role selector, biometric shortcut,
/// and a link to business registration (onboarding flow).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '0244 000 000');
  final _passwordController = TextEditingController(text: 'password');
  UserRole _selectedRole = UserRole.agent;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    ref.read(currentRoleProvider.notifier).state = _selectedRole;
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.greenDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 44),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.greenDark, c.green, c.gold.withOpacity(0.6)],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: c.gold,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: c.goldDark.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '₵',
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: c.greenDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agent Pro Ghana',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'One App. Every Mobile Money Business.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // ── Form sheet ───────────────────────────────────────────
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -18, 0),
              decoration: BoxDecoration(
                color: c.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 30, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: c.charcoal)),
                  const SizedBox(height: 4),
                  Text('Sign in to your account', style: TextStyle(fontSize: 13, color: c.muted)),
                  const SizedBox(height: 24),

                  AppTextField(label: 'PHONE NUMBER', controller: _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  AppTextField(label: 'PASSWORD', controller: _passwordController, obscureText: true),
                  const SizedBox(height: 22),

                  Text('DEMO ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: c.border, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: _selectedRole,
                        isExpanded: true,
                        items: UserRole.values
                            .map((r) => DropdownMenuItem(value: r, child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(r.label, style: const TextStyle(fontSize: 14)),
                                )))
                            .toList(),
                        onChanged: (r) => setState(() => _selectedRole = r ?? UserRole.agent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  AppButton(label: 'Sign In →', onPressed: _signIn, width: double.infinity),

                  const SizedBox(height: 14),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.fingerprint, size: 18),
                      label: const Text('Use Biometric Login'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      children: [
                        Text('New business? ', style: TextStyle(fontSize: 13, color: c.muted)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.onboarding),
                          child: Text(
                            'Register here →',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.goldLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.gold.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔒 Security Notice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.goldDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Agent Pro Ghana never asks for your Mobile Money PIN. Keep it private always.',
                          style: TextStyle(fontSize: 11, color: c.slate, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
