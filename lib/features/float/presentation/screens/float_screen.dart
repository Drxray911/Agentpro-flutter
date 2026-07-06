import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/float_providers.dart';
import '../../domain/float_models.dart';
import 'float_topup_screen.dart';
import 'float_comparison_screen.dart';
import 'float_threshold_screen.dart';

/// Port of the prototype's FloatScreen: Overview / History / Alerts / Reports tabs.
class FloatScreen extends ConsumerStatefulWidget {
  const FloatScreen({super.key});

  @override
  ConsumerState<FloatScreen> createState() => _FloatScreenState();
}

class _FloatScreenState extends ConsumerState<FloatScreen> {
  String _tab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'Float Management'),
      body: Column(
        children: [
          AppTabs(
            tabs: const ['Overview', 'History', 'Alerts', 'Reports'],
            active: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          Expanded(
            child: switch (_tab) {
              'History' => const _HistoryTab(),
              'Alerts' => const _AlertsTab(),
              'Reports' => const _ReportsTab(),
              _ => const _OverviewTab(),
            },
          ),
        ],
      ),
    );
  }
}

// ── Overview tab ─────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final balances = ref.watch(floatBalancesProvider);
    final total = balances.fold<double>(0, (a, b) => a + b.balance);

    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.green, c.greenDark]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL FLOAT BALANCE', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text('GH₵ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 4),
              Text('${balances.length} providers · Updated ${DateFormat('h:mm a').format(DateTime.now())}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MiniStat(label: 'TODAY IN', value: 'GH₵ 12,400'),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'TODAY OUT', value: 'GH₵ 7,580'),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'TRANSACTIONS', value: '18'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: '📊 Compare All Branches →',
          variant: AppButtonVariant.outline,
          width: double.infinity,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FloatComparisonScreen())),
        ),
        const SizedBox(height: 12),
        ...balances.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProviderFloatCard(balance: b),
            )),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}

class _ProviderFloatCard extends StatelessWidget {
  final FloatBalance balance;
  const _ProviderFloatCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = balance.provider;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(p.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(p.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('GH₵ ${balance.balance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                  if (balance.isLow) AppBadge(label: '⚠ Low Float', color: c.red),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: balance.ratio.toDouble(),
              minHeight: 8,
              backgroundColor: c.border,
              color: balance.isLow ? c.red : c.green,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(balance.ratio * 100).round()}% of GH₵${balance.limit.toStringAsFixed(0)} limit', style: TextStyle(fontSize: 11, color: c.muted)),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FloatTopUpScreen(preselected: p))),
                child: const Text('Top Up →'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── History tab ──────────────────────────────────────────────────────
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final movements = ref.watch(floatMovementsProvider);
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Float Movements', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              ...movements.asMap().entries.map((entry) {
                final m = entry.value;
                final isLast = entry.key == movements.length - 1;
                final isCredit = m.amount > 0;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '${isCredit ? '+' : ''}GH₵ ${m.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isCredit ? c.green : c.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d, h:mm a').format(m.time), style: TextStyle(fontSize: 11, color: c.muted)),
                          Text('Balance: GH₵ ${m.balanceAfter.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: c.muted)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Alerts tab ───────────────────────────────────────────────────────
class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final balances = ref.watch(floatBalancesProvider);
    final lowBalances = balances.where((b) => b.isLow).toList();

    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Text('ACTIVE ALERTS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        if (lowBalances.isEmpty)
          AppCard(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: c.green, size: 32),
                const SizedBox(height: 8),
                const Text('All providers healthy', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ...lowBalances.map((b) {
          final critical = b.balance < (b.alertThreshold * 0.5);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AccentCard(
              accentColor: critical ? c.red : c.gold,
              backgroundColor: critical ? c.redLight : c.goldLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    critical ? '${b.provider.label} Critical' : '${b.provider.label} Float Low',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: critical ? c.red : c.goldDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance GH₵ ${b.balance.toStringAsFixed(0)} is below your threshold of GH₵ ${b.alertThreshold.toStringAsFixed(0)}.',
                    style: TextStyle(fontSize: 12, color: c.slate),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Top Up Now',
                    variant: critical ? AppButtonVariant.primary : AppButtonVariant.gold,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FloatTopUpScreen(preselected: b.provider))),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        AppCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FloatThresholdScreen())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Alert Thresholds', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Icon(Icons.chevron_right, color: c.muted),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reports tab ──────────────────────────────────────────────────────
class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.charcoal, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('JUNE 2026 · FLOAT TURNOVER', style: TextStyle(fontSize: 11, color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('GH₵ 248,600', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AppButton(label: '📄 PDF', variant: AppButtonVariant.outline, onPressed: () {})),
            const SizedBox(width: 10),
            Expanded(child: AppButton(label: '📊 Excel', variant: AppButtonVariant.ghost, onPressed: () {})),
          ],
        ),
      ],
    );
  }
}
