import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/float_providers.dart';
import '../../domain/float_models.dart';
import 'float_topup_screen.dart';

/// Port of the prototype's FloatComparisonScreen.
/// Stacked-bar chart view + a tabular breakdown, both driven by
/// [branchFloatComparisonProvider].
class FloatComparisonScreen extends ConsumerStatefulWidget {
  const FloatComparisonScreen({super.key});

  @override
  ConsumerState<FloatComparisonScreen> createState() => _FloatComparisonScreenState();
}

class _FloatComparisonScreenState extends ConsumerState<FloatComparisonScreen> {
  String _view = 'chart';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final branches = ref.watch(branchFloatComparisonProvider);
    final grandTotal = branches.fold<double>(0, (a, b) => a + b.total);
    final maxTotal = branches.map((b) => b.total).fold<double>(0, (a, b) => b > a ? b : a);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Float Comparison', onBack: () => Navigator.of(context).pop()),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(color: c.white, border: Border(bottom: BorderSide(color: c.border))),
            child: Row(
              children: [
                Expanded(child: _ViewToggle(label: '📊 Chart', value: 'chart', group: _view, onTap: () => setState(() => _view = 'chart'))),
                const SizedBox(width: 8),
                Expanded(child: _ViewToggle(label: '📋 Table', value: 'table', group: _view, onTap: () => setState(() => _view = 'table'))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(13),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.charcoal, c.slate]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL FLOAT · ALL BRANCHES', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('GH₵ ${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('${branches.length} branches · 3 providers', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_view == 'chart') _buildChart(c, branches, maxTotal) else _buildTable(c, branches, grandTotal),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: AppButton(label: '📄 Export', variant: AppButtonVariant.outline, onPressed: () {})),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: '📈 Top Up Float',
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FloatTopUpScreen())),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(AppColors c, List<BranchFloatSnapshot> branches, double maxTotal) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stacked Float by Branch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 14),
          ...branches.map((b) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.branchName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text('GH₵ ${b.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height: 14,
                      child: Row(
                        children: MomoProviderId.values.map((p) {
                          final value = b.byProvider[p] ?? 0;
                          final flex = (value / maxTotal * 1000).round().clamp(1, 100000);
                          return Expanded(flex: flex, child: Container(color: Color(p.colorValue)));
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Wrap(
            spacing: 14,
            children: MomoProviderId.values.map((p) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(p.colorValue), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text(p.shortLabel, style: TextStyle(fontSize: 11, color: c.muted)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(AppColors c, List<BranchFloatSnapshot> branches, double grandTotal) {
    final mtnTotal = branches.fold<double>(0, (a, b) => a + (b.byProvider[MomoProviderId.mtn] ?? 0));
    final telecelTotal = branches.fold<double>(0, (a, b) => a + (b.byProvider[MomoProviderId.telecel] ?? 0));
    final atTotal = branches.fold<double>(0, (a, b) => a + (b.byProvider[MomoProviderId.at] ?? 0));

    TableRow headerRow() => TableRow(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border, width: 2))),
          children: ['Branch', 'MTN', 'Telecel', 'AT', 'Total']
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(h, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
                  ))
              .toList(),
        );

    TableRow dataRow(String name, double mtn, double telecel, double at, double total, {bool isTotal = false}) {
      return TableRow(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.border)),
          color: isTotal ? c.surface : null,
        ),
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Text(name, style: TextStyle(fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700, fontSize: 12))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Text('${(mtn / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 12, color: Color(0xFFAA8800)))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Text('${(telecel / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 12, color: Color(0xFFDC143C)))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Text('${(at / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 12, color: Color(0xFF0047AB)))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Text('${(total / 1000).toStringAsFixed(1)}k', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: c.green))),
        ],
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detailed Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 10),
          Table(
            columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1)},
            children: [
              headerRow(),
              ...branches.map((b) => dataRow(
                    b.branchName.split(' ').first,
                    b.byProvider[MomoProviderId.mtn] ?? 0,
                    b.byProvider[MomoProviderId.telecel] ?? 0,
                    b.byProvider[MomoProviderId.at] ?? 0,
                    b.total,
                  )),
              dataRow('TOTAL', mtnTotal, telecelTotal, atTotal, grandTotal, isTotal: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final String label;
  final String value;
  final String group;
  final VoidCallback onTap;
  const _ViewToggle({required this.label, required this.value, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = value == group;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.greenLight : c.white,
          border: Border.all(color: selected ? c.green : c.border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? c.green : c.slate)),
      ),
    );
  }
}
