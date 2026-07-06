import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Port of the prototype's SettingsScreen.
/// Wired to: darkModeProvider, profile, PIN setup, SIM config,
/// language, backup, support, app info, sign out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isDark = ref.watch(darkModeProvider);
    final userName = ref.watch(currentUserNameProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(13),
        children: [
          // Profile card
          AppCard(
            onTap: () => Navigator.of(context).pushNamed('/profile'),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: c.gold, borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Text(userName[0], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: c.greenDark)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const Text('Agent · Accra Central Branch', style: TextStyle(fontSize: 13)),
                      const Text('ID: APG-KA-00421', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.muted),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Preferences toggles
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('PREFERENCES'),
                _ToggleRow(
                  icon: '🌙',
                  label: 'Dark Mode',
                  sub: 'Switch to dark theme',
                  value: isDark,
                  onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
                ),
                _ToggleRow(
                  icon: '🔔',
                  label: 'Push Notifications',
                  sub: 'Transaction alerts & updates',
                  value: true,
                  onChanged: (_) {},
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Security
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('ACCOUNT & SECURITY'),
                _NavRow(icon: '🔑', label: 'Change Password', onTap: () => Navigator.of(context).pushNamed('/changepassword')),
                _NavRow(icon: '🔐', label: 'PIN & Biometric', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PinSetupScreen()))),
                _NavRow(icon: '📱', label: 'SIM Configuration', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SimConfigScreen()))),
                _NavRow(icon: '🔒', label: 'Active Sessions', onTap: () => Navigator.of(context).pushNamed('/sessions')),
                _NavRow(icon: '💾', label: 'Backup & Restore', onTap: () => Navigator.of(context).pushNamed('/backup'), isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Support
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('SUPPORT'),
                _NavRow(icon: '🤖', label: 'AI Assistant', onTap: () => Navigator.of(context).pushNamed(AppRoutes.ai)),
                _NavRow(icon: '❓', label: 'FAQ & Help', onTap: () => Navigator.of(context).pushNamed(AppRoutes.support)),
                _NavRow(icon: '💬', label: 'Live Chat Support', onTap: () => Navigator.of(context).pushNamed('/supportchat')),
                _NavRow(icon: '🎫', label: 'Submit Ticket', onTap: () => Navigator.of(context).pushNamed(AppRoutes.support), isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // App
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('APP'),
                _NavRow(icon: '📱', label: 'App Info & Version', onTap: () => Navigator.of(context).pushNamed('/appinfo')),
                _NavRow(icon: '🌐', label: 'Language', onTap: () => Navigator.of(context).pushNamed('/language'), isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sign out
          AppButton(
            label: 'Sign Out',
            variant: AppButtonVariant.danger,
            width: double.infinity,
            onPressed: () {
              ref.read(currentRoleProvider.notifier).state = UserRole.values.first;
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/appinfo'),
              child: Text('Agent Pro Ghana v1.0.0 · © 2026 · Tap for info', style: TextStyle(fontSize: 11, color: c.muted)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted, letterSpacing: 0.5)),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String icon;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({required this.icon, required this.label, required this.sub, required this.value, required this.onChanged, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(sub, style: TextStyle(fontSize: 11, color: c.muted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: c.green),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _NavRow({required this.icon, required this.label, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            Icon(Icons.chevron_right, color: c.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── PIN Setup sub-screen ─────────────────────────────────────────────
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _tab = 'PIN';
  List<String> _pin = [];
  List<String> _confirmPin = [];
  String _stage = 'enter'; // enter | confirm | done
  bool _bioEnabled = true;

  void _addDigit(String d) {
    setState(() {
      if (_stage == 'enter' && _pin.length < 4) {
        _pin = [..._pin, d];
        if (_pin.length == 4) Future.delayed(const Duration(milliseconds: 300), () => setState(() => _stage = 'confirm'));
      } else if (_stage == 'confirm' && _confirmPin.length < 4) {
        _confirmPin = [..._confirmPin, d];
        if (_confirmPin.length == 4) Future.delayed(const Duration(milliseconds: 300), () => setState(() => _stage = 'done'));
      }
    });
  }

  void _del() {
    setState(() {
      if (_stage == 'enter' && _pin.isNotEmpty) _pin = _pin.sublist(0, _pin.length - 1);
      if (_stage == 'confirm' && _confirmPin.isNotEmpty) _confirmPin = _confirmPin.sublist(0, _confirmPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Security Setup', onBack: () => Navigator.of(context).pop()),
      body: Column(
        children: [
          AppTabs(tabs: const ['PIN', 'Biometric'], active: _tab, onChanged: (t) => setState(() => _tab = t)),
          Expanded(
            child: _tab == 'Biometric' ? _buildBio(context, c) : _buildPin(context, c),
          ),
        ],
      ),
    );
  }

  Widget _buildPin(BuildContext context, AppColors c) {
    if (_stage == 'done') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔐', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text('PIN Set Successfully!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
              const SizedBox(height: 8),
              Text('Your app is now protected with a 4-digit PIN.', style: TextStyle(fontSize: 13, color: c.muted), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              AppButton(label: 'Done', width: double.infinity, onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      );
    }

    final active = _stage == 'enter' ? _pin : _confirmPin;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('🔐', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(_stage == 'enter' ? 'Set Your App PIN' : 'Confirm Your PIN', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 4),
          Text(_stage == 'enter' ? 'Choose a 4-digit PIN for quick access' : 'Re-enter your PIN to confirm', style: TextStyle(fontSize: 13, color: c.muted)),
          const SizedBox(height: 24),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < active.length;
              return Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? c.green : c.border,
                  border: Border.all(color: filled ? c.green : c.border, width: 2),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [...List.generate(9, (i) => '${i + 1}'), '', '0', '⌫'].map((k) {
              if (k.isEmpty) return const SizedBox.shrink();
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: k == '⌫' ? c.redLight : null,
                  side: BorderSide(color: k == '⌫' ? c.red.withOpacity(0.3) : c.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: k == '⌫' ? _del : () => _addDigit(k),
                child: Text(k, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: k == '⌫' ? c.red : c.charcoal)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Text('🖐', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                const Text('Fingerprint Login', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Use your fingerprint for fast, secure access to Agent Pro Ghana. Your fingerprint data never leaves your device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: c.muted, height: 1.6),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enable Fingerprint Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Switch(value: _bioEnabled, onChanged: (v) => setState(() => _bioEnabled = v), activeColor: c.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_bioEnabled) ...[
            const SizedBox(height: 12),
            AppCard(
              backgroundColor: c.greenLight,
              borderColor: c.green.withOpacity(0.3),
              child: Center(child: Text('✅ Fingerprint login is active', style: TextStyle(fontWeight: FontWeight.w700, color: c.green))),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(label: 'Save Settings', width: double.infinity, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

// ── SIM Config sub-screen ─────────────────────────────────────────────
class SimConfigScreen extends StatefulWidget {
  const SimConfigScreen({super.key});

  @override
  State<SimConfigScreen> createState() => _SimConfigScreenState();
}

class _SimConfigScreenState extends State<SimConfigScreen> {
  String _sim1 = 'MTN';
  String _sim2 = 'Telecel';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final providers = ['MTN', 'Telecel', 'AT Money'];

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'SIM Configuration', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Map SIM slots to MoMo providers.\nTransactions use the SIM matched to the selected provider.', style: TextStyle(fontSize: 13, color: c.muted, height: 1.6)),
                const SizedBox(height: 16),
                Text('SIM 1', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate, letterSpacing: 0.5)),
                const SizedBox(height: 5),
                _SimDropdown(value: _sim1, options: providers, onChanged: (v) => setState(() => _sim1 = v)),
                const SizedBox(height: 14),
                Text('SIM 2', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate, letterSpacing: 0.5)),
                const SizedBox(height: 5),
                _SimDropdown(value: _sim2, options: providers, onChanged: (v) => setState(() => _sim2 = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Mapping', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                _MappingRow(sim: 'SIM 1', provider: _sim1, phone: '0244 000 000'),
                _MappingRow(sim: 'SIM 2', provider: _sim2, phone: '0551 000 000', isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Save SIM Configuration', width: double.infinity, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _SimDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SimDropdown({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: c.border, width: 1.5)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _MappingRow extends StatelessWidget {
  final String sim;
  final String provider;
  final String phone;
  final bool isLast;
  const _MappingRow({required this.sim, required this.provider, required this.phone, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sim, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(phone, style: TextStyle(fontSize: 11, color: c.muted)),
            ],
          ),
          AppBadge(label: provider, color: c.green),
        ],
      ),
    );
  }
}
