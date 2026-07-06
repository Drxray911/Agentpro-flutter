import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/float_providers.dart';
import '../../domain/float_models.dart';

/// Port of the prototype's FloatTopUpScreen.
/// Select provider → funding source (MoMo/Bank/Cash) → amount → confirm.
class FloatTopUpScreen extends ConsumerStatefulWidget {
  final MomoProviderId? preselected;
  const FloatTopUpScreen({super.key, this.preselected});

  @override
  ConsumerState<FloatTopUpScreen> createState() => _FloatTopUpScreenState();
}

class _FloatTopUpScreenState extends ConsumerState<FloatTopUpScreen> {
  late MomoProviderId _provider;
  FloatTopUpSource _source = FloatTopUpSource.momo;
  final _amountController = TextEditingController();
  bool _done = false;
  late final String _reference;

  @override
  void initState() {
    super.initState();
    _provider = widget.preselected ?? MomoProviderId.mtn;
    _reference = 'FLT-${Random().nextInt(900000) + 100000}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  void _confirm() {
    // TODO: replace with POST /float/topup (spec §5.3).
    final balances = ref.read(floatBalancesProvider);
    ref.read(floatBalancesProvider.notifier).state = balances.map((b) {
      if (b.provider == _provider) return b.copyWith(balance: b.balance + _amount);
      return b;
    }).toList();
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildSuccess(context);

    final c = context.colors;
    final balances = ref.watch(floatBalancesProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Float Top-Up', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Text('SELECT PROVIDER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate)),
                ),
                ...balances.map((b) {
                  final selected = b.provider == _provider;
                  return InkWell(
                    onTap: () => setState(() => _provider = b.provider),
                    child: Container(
                      color: selected ? c.greenLight : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Text(b.provider.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.provider.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text('Current: GH₵ ${b.balance.toStringAsFixed(0)} / ${b.limit.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: c.muted)),
                              ],
                            ),
                          ),
                          if (b.isLow) AppBadge(label: 'Low', color: c.red),
                          if (selected) ...[const SizedBox(width: 6), Icon(Icons.check_circle, color: c.green, size: 18)],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FUNDING SOURCE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SourceButton(label: 'MoMo Wallet', icon: '📱', value: FloatTopUpSource.momo, group: _source, onSelect: (v) => setState(() => _source = v)),
                    const SizedBox(width: 8),
                    _SourceButton(label: 'Bank Transfer', icon: '🏦', value: FloatTopUpSource.bank, group: _source, onSelect: (v) => setState(() => _source = v)),
                    const SizedBox(width: 8),
                    _SourceButton(label: 'Cash Deposit', icon: '💵', value: FloatTopUpSource.cash, group: _source, onSelect: (v) => setState(() => _source = v)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(label: 'TOP-UP AMOUNT (GH₵)', controller: _amountController, placeholder: '0.00', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: [500, 1000, 2000, 5000].map((v) {
                    return ActionChip(label: Text('+$v'), onPressed: () => setState(() => _amountController.text = v.toString()));
                  }).toList(),
                ),
              ],
            ),
          ),
          if (_amount > 0) ...[
            const SizedBox(height: 12),
            AppCard(
              backgroundColor: c.greenLight,
              borderColor: c.green.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top-Up Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.greenDark)),
                  const SizedBox(height: 6),
                  _summaryRow('Provider', _provider.label, c),
                  _summaryRow('Amount', 'GH₵ ${_amount.toStringAsFixed(2)}', c),
                  _summaryRow('Method', _sourceLabel(_source), c),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(label: 'Confirm Top-Up →', width: double.infinity, onPressed: _amount > 0 ? _confirm : null),
        ],
      ),
    );
  }

  String _sourceLabel(FloatTopUpSource s) {
    switch (s) {
      case FloatTopUpSource.momo:
        return 'MoMo Wallet';
      case FloatTopUpSource.bank:
        return 'Bank Transfer';
      case FloatTopUpSource.cash:
        return 'Cash Deposit';
    }
  }

  Widget _summaryRow(String label, String value, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: c.muted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📈', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text('Float Topped Up!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
              const SizedBox(height: 8),
              Text('GH₵ ${_amount.toStringAsFixed(2)} added to ${_provider.shortLabel}', style: TextStyle(fontSize: 14, color: c.muted)),
              const SizedBox(height: 4),
              Text('Ref: $_reference', style: TextStyle(fontSize: 12, color: c.muted)),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(label: 'View Float', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 10),
                  AppButton(
                    label: 'Top Up Again',
                    onPressed: () => setState(() {
                      _done = false;
                      _amountController.clear();
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final String label;
  final String icon;
  final FloatTopUpSource value;
  final FloatTopUpSource group;
  final ValueChanged<FloatTopUpSource> onSelect;

  const _SourceButton({required this.label, required this.icon, required this.value, required this.group, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = value == group;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? c.greenLight : c.white,
            border: Border.all(color: selected ? c.green : c.border, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? c.green : c.slate)),
            ],
          ),
        ),
      ),
    );
  }
}
