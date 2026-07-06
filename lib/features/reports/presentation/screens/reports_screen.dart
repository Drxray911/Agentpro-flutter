import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../momo/data/transaction_repository.dart';
import '../../../commission/data/commission_providers.dart';
import '../../../commission/domain/commission_models.dart';
import '../../../float/domain/float_models.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _tab = 'Overview';
  CommissionPeriod _period = CommissionPeriod.month;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'Reports'),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            color: c.white,
            child: Row(
              children: CommissionPeriod.values.map((p) {
                final sel = p == _period;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => _period = p),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? c.greenLight : Colors.transparent,
                          border: Border.all(color: sel ? c.green : c.border, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(p.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? c.green : c.muted)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          AppTabs(
            tabs: const ['Overview', 'Transactions', 'By Branch', 'Export'],
            active: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          Expanded(
            child: switch (_tab) {
              'Transactions' => _TransactionsTab(period: _period),
              'By Branch' => _ByBranchTab(),
              'Export' => const _ExportTab(),
              _ => _OverviewTab(period: _period),
            },
          ),
        ],
      ),
    );
  }
}

// ── Overview tab ─────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  final CommissionPeriod period;
  const _OverviewTab({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final summary = ref.watch(commissionSummaryProvider(period));

    // Mock daily volume for bar chart (12 data points)
    final barData = [42, 58, 52, 71, 64, 88, 76, 92, 68, 84, 79, 95];
    final maxBar = barData.reduce((a, b) => a > b ? a : b).toDouble();

    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        // Hero summary
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.charcoal, c.slate]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${period.label.toUpperCase()} OVERVIEW', style: const TextStyle(fontSize: 11, color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('GH₵ 248,600', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 12),
              Row(children: [
                _HStat('TRANSACTIONS', '${summary.transactionCount}'),
                _HStat('COMMISSION', 'GH₵ ${summary.total.toStringAsFixed(0)}', gold: true),
                _HStat('AVG TXN', 'GH₵ ${summary.transactionCount == 0 ? 0 : (summary.total / summary.transactionCount * 66.7).toStringAsFixed(0)}'),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Daily bar chart
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Transaction Volume', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 14),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: barData.asMap().entries.map((e) {
                    final isToday = e.key == barData.length - 1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          height: ((e.value / maxBar) * 70).clamp(4, 70),
                          decoration: BoxDecoration(
                            color: isToday ? c.gold : c.green.withOpacity(0.6),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Jun 14', style: TextStyle(fontSize: 10, color: c.muted)),
                Text('Today', style: TextStyle(fontSize: 10, color: c.gold, fontWeight: FontWeight.w700)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Provider breakdown
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Volume by Provider', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 12),
              ...[
                (MomoProviderId.mtn, 'GH₵ 144,200', 58.0),
                (MomoProviderId.telecel, 'GH₵ 67,000', 27.0),
                (MomoProviderId.at, 'GH₵ 37,400', 15.0),
              ].map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [Text(p.$1.icon, style: const TextStyle(fontSize: 16)), const SizedBox(width: 6), Text(p.$1.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
                        Text(p.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(value: p.$3 / 100, minHeight: 6, backgroundColor: c.border, color: Color(p.$1.colorValue)),
                      ),
                    ]),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _HStat extends StatelessWidget {
  final String label;
  final String value;
  final bool gold;
  const _HStat(this.label, this.value, {this.gold = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: gold ? const Color(0xFFFDE68A) : Colors.white)),
        ]),
      );
}

// ── Transactions tab ──────────────────────────────────────────────────
class _TransactionsTab extends ConsumerStatefulWidget {
  final CommissionPeriod period;
  const _TransactionsTab({required this.period});

  @override
  ConsumerState<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<_TransactionsTab> {
  String _typeFilter = 'All';

  static const _types = ['All', 'Cash In', 'Cash Out', 'Send', 'Bill', 'Airtime'];

  String _label(String type) => switch (type) {
        'cashin' => 'Cash In',
        'cashout' => 'Cash Out',
        'send' => 'Send Money',
        'bill' => 'Bill Payment',
        'airtime' => 'Airtime',
        'bundle' => 'Bundle',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final txns = ref.watch(recentTransactionsProvider);
    final filtered = _typeFilter == 'All'
        ? txns
        : txns.where((t) => _label(t.type) == _typeFilter).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Row(
            children: _types.map((f) {
              final sel = _typeFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: sel,
                  onSelected: (_) => setState(() => _typeFilter = f),
                  selectedColor: c.greenLight,
                  checkmarkColor: c.green,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700, color: sel ? c.green : c.slate, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No transactions', style: TextStyle(color: c.muted)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(13, 0, 13, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final t = filtered[i];
                    final isCredit = ['cashin'].contains(t.type);
                    return AppCard(
                      onTap: () => Navigator.of(context).pushNamed('/txndetail'),
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: t.isSuccess ? c.greenLight : c.redLight, borderRadius: BorderRadius.circular(11)),
                          alignment: Alignment.center,
                          child: Icon(isCredit ? Icons.south_west_rounded : Icons.north_east_rounded, size: 18, color: t.isSuccess ? c.green : c.red),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_label(t.type), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${t.customerPhone} · ${t.provider.toUpperCase()} · ${DateFormat('MMM d, h:mm a').format(t.processedAt)}', style: TextStyle(fontSize: 11, color: c.muted)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('GH₵ ${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          AppBadge(label: t.isSuccess ? 'Done' : 'Failed', color: t.isSuccess ? c.green : c.red),
                        ]),
                      ]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── By Branch tab ─────────────────────────────────────────────────────
class _ByBranchTab extends StatelessWidget {
  static const _branches = [
    ('Accra Central', 'GH₵ 119,800', 48, 'GH₵ 1,797'),
    ('Kumasi Kejetia', 'GH₵ 76,900', 31, 'GH₵ 1,154'),
    ('Tema Station', 'GH₵ 32,300', 13, 'GH₵ 485'),
    ('Takoradi Market', 'GH₵ 19,600', 8, 'GH₵ 294'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Branch Performance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 12),
            // Mini chart
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _branches.asMap().entries.map((e) {
                  final pct = e.value.$3 / 100.0;
                  final colors = [c.green, c.blue, c.gold, c.muted];
                  return Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${e.value.$3}%', style: TextStyle(fontSize: 9, color: c.muted, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Container(height: (pct * 70).clamp(4, 70), decoration: BoxDecoration(color: colors[e.key], borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
                      const SizedBox(height: 4),
                      Text(e.value.$1.split(' ').first, style: TextStyle(fontSize: 9, color: c.muted), textAlign: TextAlign.center),
                    ]),
                  ));
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            ..._branches.asMap().entries.map((e) {
              final b = e.value;
              final isLast = e.key == _branches.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${b.$3}% of total · Commission: ${b.$4}', style: TextStyle(fontSize: 11, color: c.muted)),
                  ]),
                  Text(b.$2, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: c.green)),
                ]),
              );
            }),
          ]),
        ),
      ],
    );
  }
}

// ── Export tab ────────────────────────────────────────────────────────
class _ExportTab extends StatefulWidget {
  const _ExportTab();

  @override
  State<_ExportTab> createState() => _ExportTabState();
}

class _ExportTabState extends State<_ExportTab> {
  String _from = '2026-06-01';
  String _to = '2026-06-26';

  static const _reports = [
    (icon: '💸', name: 'Transaction Report', desc: 'Full list with all details', formats: ['PDF', 'Excel', 'CSV']),
    (icon: '📊', name: 'Float Report', desc: 'Daily float movements', formats: ['PDF', 'Excel', 'CSV']),
    (icon: '💰', name: 'Commission Report', desc: 'Commission by agent & provider', formats: ['PDF', 'Excel']),
    (icon: '👥', name: 'Agent Performance', desc: 'Comparative agent stats', formats: ['PDF', 'Excel']),
    (icon: '🌿', name: 'Branch Summary', desc: 'Branch-level overview', formats: ['PDF', 'Excel']),
    (icon: '📋', name: 'Audit Log', desc: 'Full activity trail', formats: ['CSV', 'Excel']),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        // Date range
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FROM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate)),
                const SizedBox(height: 5),
                TextField(controller: TextEditingController(text: _from), onChanged: (v) => setState(() => _from = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate)),
                const SizedBox(height: 5),
                TextField(controller: TextEditingController(text: _to), onChanged: (v) => setState(() => _to = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
              ])),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Text('AVAILABLE REPORTS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        ..._reports.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Text(r.icon, style: const TextStyle(fontSize: 20))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      Text(r.desc, style: TextStyle(fontSize: 12, color: c.muted)),
                    ])),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: r.formats.map((fmt) {
                    final icon = fmt == 'PDF' ? '📄' : fmt == 'Excel' ? '📊' : '📋';
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AppButton(label: '$icon $fmt', variant: AppButtonVariant.outline, onPressed: () {}, padding: const EdgeInsets.symmetric(vertical: 8)),
                    ));
                  }).toList()),
                ]),
              ),
            )),
        const SizedBox(height: 8),
        AppCard(
          onTap: () => Navigator.of(context).pushNamed('/scheduledreports'),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('🕐 Scheduled Reports', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            Icon(Icons.chevron_right, color: context.colors.muted),
          ]),
        ),
      ],
    );
  }
}
