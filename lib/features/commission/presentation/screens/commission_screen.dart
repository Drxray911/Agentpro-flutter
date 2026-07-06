import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/commission_providers.dart';
import '../../domain/commission_models.dart';
import 'commission_payout_screen.dart';
import 'commission_rates_screen.dart';

class CommissionScreen extends ConsumerStatefulWidget {
  const CommissionScreen({super.key});

  @override
  ConsumerState<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends ConsumerState<CommissionScreen> {
  String _tab = 'Summary';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final period = ref.watch(commissionPeriodProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'Commission'),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            color: c.white,
            child: Row(
              children: CommissionPeriod.values.map((p) {
                final selected = p == period;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => ref.read(commissionPeriodProvider.notifier).state = p,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? c.greenLight : Colors.transparent,
                          border: Border.all(color: selected ? c.green : c.border, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p.label,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? c.green : c.muted),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          AppTabs(
            tabs: const ['Summary', 'By Agent', 'By Provider'],
            active: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          Expanded(
            child: switch (_tab) {
              'By Agent' => const _ByAgentTab(),
              'By Provider' => const _ByProviderTab(),
              _ => const _SummaryTab(),
            },
          ),
        ],
      ),
    );
  }
}

// ── Summary tab ──────────────────────────────────────────────────────
class _SummaryTab extends ConsumerWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final period = ref.watch(commissionPeriodProvider);
    final summary = ref.watch(commissionSummaryProvider(period));

    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.gold, c.goldDark]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${period.label.toUpperCase()} COMMISSION', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text('GH₵ ${summary.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    summary.isPositiveChange ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${summary.changePercent.abs().toStringAsFixed(1)}% vs last ${period.label.toLowerCase()}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text('${summary.transactionCount} transactions', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // By operation type breakdown
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('By Operation Type', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 12),
              ...summary.byType.entries.map((e) {
                final pct = summary.total == 0 ? 0.0 : (e.value / summary.total);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('GH₵ ${e.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: c.border,
                                color: c.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 36,
                            child: Text('${(pct * 100).round()}%', style: TextStyle(fontSize: 11, color: c.muted)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Actions
        Row(
          children: [
            Expanded(child: AppButton(label: '📄 PDF', variant: AppButtonVariant.outline, onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: AppButton(label: '📊 Excel', variant: AppButtonVariant.ghost, onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: '💰 Payout',
                variant: AppButtonVariant.gold,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CommissionPayoutScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppButton(
          label: '⚙️ Configure Commission Rates →',
          variant: AppButtonVariant.ghost,
          width: double.infinity,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CommissionRatesScreen())),
        ),
      ],
    );
  }
}

// ── By Agent tab ─────────────────────────────────────────────────────
class _ByAgentTab extends ConsumerWidget {
  const _ByAgentTab();

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final agents = ref.watch(agentLeaderboardProvider);
    final maxCommission = agents.isEmpty ? 1.0 : agents.first.total;

    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Agent Leaderboard', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.charcoal)),
            TextButton(
              onPressed: () {},
              child: const Text('Full View →'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...agents.map((agent) {
          final isTopThree = agent.rank <= 3;
          final barWidth = maxCommission == 0 ? 0.0 : agent.total / maxCommission;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Rank / medal
                      SizedBox(
                        width: 36,
                        child: isTopThree
                            ? Text(_medals[agent.rank - 1], style: const TextStyle(fontSize: 22))
                            : Center(
                                child: Text(
                                  '#${agent.rank}',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: c.muted),
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      // Agent avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(11)),
                        alignment: Alignment.center,
                        child: Text(
                          agent.agentName[0],
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c.green),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(agent.agentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text('${agent.branch} · ${agent.transactionCount} txns', style: TextStyle(fontSize: 11, color: c.muted)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('GH₵ ${agent.total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: c.gold)),
                          Row(
                            children: [
                              Icon(
                                agent.isRankUp ? Icons.arrow_upward : agent.isRankDown ? Icons.arrow_downward : Icons.remove,
                                size: 12,
                                color: agent.isRankUp ? c.green : agent.isRankDown ? c.red : c.muted,
                              ),
                              Text(
                                agent.isRankUp ? '${agent.previousRank - agent.rank}' : agent.isRankDown ? '${agent.rank - agent.previousRank}' : '—',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: agent.isRankUp ? c.green : agent.isRankDown ? c.red : c.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: barWidth,
                      minHeight: 5,
                      backgroundColor: c.border,
                      color: isTopThree ? c.gold : c.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── By Provider tab ───────────────────────────────────────────────────
class _ByProviderTab extends ConsumerWidget {
  const _ByProviderTab();

  static const _providerColors = {
    MomoProviderId.mtn: Color(0xFFFFCC00),
    MomoProviderId.telecel: Color(0xFFDC143C),
    MomoProviderId.at: Color(0xFF0047AB),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final period = ref.watch(commissionPeriodProvider);
    final summary = ref.watch(commissionSummaryProvider(period));
    final maxValue = summary.byProvider.values.isEmpty ? 1.0 : summary.byProvider.values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Commission by Provider', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 14),
              ...summary.byProvider.entries.map((e) {
                final pct = summary.total == 0 ? 0.0 : e.value / summary.total;
                final barRatio = maxValue == 0 ? 0.0 : e.value / maxValue;
                final color = _providerColors[e.key] ?? c.green;
                final label = e.key.label;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(e.key.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('GH₵ ${e.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text('${(pct * 100).round()}% of total', style: TextStyle(fontSize: 11, color: c.muted)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: barRatio,
                          minHeight: 10,
                          backgroundColor: c.border,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Mini bar chart — visual only
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Visual Comparison', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 14),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: summary.byProvider.entries.map((e) {
                    final ratio = maxValue == 0 ? 0.0 : e.value / maxValue;
                    final color = _providerColors[e.key] ?? c.green;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('GH₵${(e.value / 1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 10, color: c.muted, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Container(
                              height: (ratio * 70).clamp(4, 70),
                              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                            ),
                            const SizedBox(height: 4),
                            Text(e.key.shortLabel, style: TextStyle(fontSize: 10, color: c.muted, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
