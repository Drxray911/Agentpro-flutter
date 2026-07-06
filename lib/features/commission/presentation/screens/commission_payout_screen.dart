import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/commission_providers.dart';
import '../../domain/commission_models.dart';

/// Port of the prototype's CommissionPayoutScreen.
/// Method selection (MoMo / Bank) → account + amount → confirm.
class CommissionPayoutScreen extends ConsumerStatefulWidget {
  const CommissionPayoutScreen({super.key});

  @override
  ConsumerState<CommissionPayoutScreen> createState() => _CommissionPayoutScreenState();
}

class _CommissionPayoutScreenState extends ConsumerState<CommissionPayoutScreen> {
  PayoutMethod _method = PayoutMethod.momo;
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  int _step = 1; // 1 = input, 2 = confirm, 3 = done
  late final String _reference;

  @override
  void initState() {
    super.initState();
    _reference = 'PAY-${Random().nextInt(900000) + 100000}';
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;
  bool get _canProceed => _accountController.text.isNotEmpty && _amount > 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final period = ref.watch(commissionPeriodProvider);
    final summary = ref.watch(commissionSummaryProvider(period));

    if (_step == 3) return _buildDone(context, c);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Request Payout',
        onBack: _step == 2 ? () => setState(() => _step = 1) : () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Available balance card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.gold, c.goldDark]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AVAILABLE TO WITHDRAW', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 4),
                Text('GH₵ ${summary.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                Text('${summary.transactionCount} transactions this ${period.label.toLowerCase()}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_step == 1) ...[
            // Method selector
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PAYOUT METHOD', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MethodTile(icon: '📱', label: 'MoMo Wallet', value: PayoutMethod.momo, group: _method, onTap: () => setState(() => _method = PayoutMethod.momo)),
                      const SizedBox(width: 10),
                      _MethodTile(icon: '🏦', label: 'Bank Transfer', value: PayoutMethod.bank, group: _method, onTap: () => setState(() => _method = PayoutMethod.bank)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Account + amount
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    label: _method == PayoutMethod.momo ? 'MOBILE MONEY NUMBER' : 'BANK ACCOUNT NUMBER',
                    controller: _accountController,
                    placeholder: _method == PayoutMethod.momo ? '024 XXX XXXX' : 'Account number',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'PAYOUT AMOUNT (GH₵)',
                    controller: _amountController,
                    placeholder: '0.00',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _amountController.text = summary.total.toStringAsFixed(2)),
                        child: const Text('All available'),
                      ),
                      const SizedBox(width: 8),
                      ...['500', '1000', '2000'].map((v) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(label: Text(v), onPressed: () => setState(() => _amountController.text = v)),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Continue →', width: double.infinity, onPressed: _canProceed ? () => setState(() => _step = 2) : null),
          ],

          if (_step == 2) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Confirm Payout Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 12),
                  ...[
                    ['Method', _method == PayoutMethod.momo ? 'MoMo Wallet' : 'Bank Transfer'],
                    ['Account', _accountController.text],
                    ['Amount', 'GH₵ ${_amount.toStringAsFixed(2)}'],
                    ['Reference', _reference],
                    ['Processing Time', _method == PayoutMethod.momo ? 'Instant' : '1–2 business days'],
                  ].map((row) {
                    final isLast = row[0] == 'Processing Time';
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(row[0], style: TextStyle(color: c.muted, fontSize: 13)),
                          Text(row[1], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppButton(label: '← Back', variant: AppButtonVariant.ghost, onPressed: () => setState(() => _step = 1))),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: AppButton(label: 'Submit Payout →', onPressed: () => setState(() => _step = 3))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDone(BuildContext context, AppColors c) {
    return Scaffold(
      backgroundColor: c.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💰', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text('Payout Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
              const SizedBox(height: 8),
              Text('GH₵ ${_amount.toStringAsFixed(2)} requested via ${_method == PayoutMethod.momo ? 'MoMo' : 'Bank'}', style: TextStyle(fontSize: 14, color: c.muted)),
              const SizedBox(height: 4),
              Text('Ref: $_reference', style: TextStyle(fontSize: 12, color: c.muted)),
              const SizedBox(height: 4),
              Text(
                _method == PayoutMethod.momo ? '⚡ Instant transfer' : '🕐 1–2 business days',
                style: TextStyle(fontSize: 12, color: c.gold, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 28),
              AppButton(label: 'Back to Commission', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String icon;
  final String label;
  final PayoutMethod value;
  final PayoutMethod group;
  final VoidCallback onTap;
  const _MethodTile({required this.icon, required this.label, required this.value, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = value == group;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.greenLight : c.white,
            border: Border.all(color: selected ? c.green : c.border, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? c.green : c.slate)),
            ],
          ),
        ),
      ),
    );
  }
}
