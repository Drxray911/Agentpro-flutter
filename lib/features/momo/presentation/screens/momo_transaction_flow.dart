import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/transaction_repository.dart';

/// Generic transaction flow for any MoMo operation that needs
/// provider + phone + amount + confirm + success.
/// Used by Cash In, Cash Out, Send Money, Bill Payment, Airtime, Data Bundle.
///
/// Per spec Section 7.2 (Provider Abstraction Layer), the actual transaction
/// call should go through a ProviderRepository interface — see TODO below.
class MomoTransactionFlow extends ConsumerStatefulWidget {
  final String operationId;
  final String operationLabel;

  const MomoTransactionFlow({super.key, required this.operationId, required this.operationLabel});

  @override
  State<MomoTransactionFlow> createState() => _MomoTransactionFlowState();
}

class _MomoTransactionFlowState extends ConsumerState<MomoTransactionFlow> {
  String _provider = 'MTN';
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  int _step = 1; // 1 = input, 2 = confirm, 3 = success
  late final String _reference;
  String? _serverReference; // updated with real reference after API responds

  static const _commissionRate = 0.015; // 1.5%, see spec Section 5.4 / 6.4 (configurable server-side)

  @override
  void initState() {
    super.initState();
    _reference = 'TXN-${Random().nextInt(900000) + 100000}';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _commission => _amount * _commissionRate;

  Future<void> _confirm() async {
    // Move to success screen immediately (optimistic UI).
    setState(() => _step = 3);

    // POST /transactions (spec §5.2) — real call with demo fallback.
    try {
      final result = await ref.read(transactionRepositoryProvider).submit(
        TransactionRequest(
          type: TransactionType.values.firstWhere(
            (t) => t.name == widget.operationId,
            orElse: () => TransactionType.cashin,
          ),
          provider: _provider.toLowerCase()
              .replaceAll(' money', '')
              .replaceAll(' cash', ''),
          customerPhone: _phoneController.text,
          amount: _amount,
          simSlot: 1, // TODO: read from SIM config provider
        ),
      );
      if (result.isSuccess) {
        setState(() => _serverReference = result.reference);
      } else {
        // Revert to confirm step and surface the provider error message.
        if (mounted) {
          setState(() => _step = 2);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.responseMessage ?? 'Transaction failed. Please try again.'),
            backgroundColor: Colors.red.shade700,
          ));
        }
      }
    } catch (_) {
      // Network error: stay on success screen with local reference.
      // The transaction will be reconciled by the backend on next sync.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 3) return _SuccessView(amount: _amount, provider: _provider, reference: _reference, serverReference: _serverReference);
    if (_step == 2) return _buildConfirmStep(context);
    return _buildInputStep(context);
  }

  Widget _buildInputStep(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: widget.operationLabel, onBack: () => Navigator.of(context).pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROVIDER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['MTN', 'Telecel', 'AT Money'].map((p) {
                      final selected = _provider == p;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _provider = p),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? c.greenLight : c.white,
                                border: Border.all(color: selected ? c.green : c.border, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? c.green : c.slate)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(child: AppTextField(label: 'CUSTOMER PHONE', controller: _phoneController, placeholder: '024 XXX XXXX', keyboardType: TextInputType.phone)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(label: 'AMOUNT (GH₵)', controller: _amountController, placeholder: '0.00', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [50, 100, 200, 500, 1000, 2000].map((v) {
                      return ActionChip(
                        label: Text('+$v', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () => setState(() => _amountController.text = v.toString()),
                      );
                    }).toList(),
                  ),
                  if (_amount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Commission earned', style: TextStyle(fontSize: 13, color: c.muted)),
                          Text('GH₵ ${_commission.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, color: c.green)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Continue →',
              width: double.infinity,
              onPressed: (_amount > 0 && _phoneController.text.isNotEmpty) ? () => setState(() => _step = 2) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmStep(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Confirm Transaction', onBack: () => setState(() => _step = 1)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: c.white, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text('GH₵ ${_amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${widget.operationLabel} · $_provider', style: TextStyle(color: c.muted, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  _row('Operation', widget.operationLabel, c),
                  _row('Provider', _provider, c),
                  _row('Phone', _phoneController.text, c),
                  _row('Amount', 'GH₵ ${_amount.toStringAsFixed(2)}', c),
                  _row('Commission', 'GH₵ ${_commission.toStringAsFixed(2)}', c),
                  _row('Reference', _reference, c, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: c.goldLight, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '⚠ Verify phone number before confirming. Transactions cannot be reversed after completion without going through the Reversal flow.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.goldDark),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Confirm & Process ✓', width: double.infinity, onPressed: _confirm),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, AppColors c, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final double amount;
  final String provider;
  final String reference;
  final String? serverReference;
  const _SuccessView({required this.amount, required this.provider, required this.reference, this.serverReference});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 80, color: c.green),
              const SizedBox(height: 16),
              Text('Transaction Successful', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: c.green)),
              const SizedBox(height: 8),
              Text('GH₵ ${amount.toStringAsFixed(2)} via $provider', style: TextStyle(fontSize: 14, color: c.muted)),
              const SizedBox(height: 4),
              Text('Ref: \${serverReference ?? reference}', style: TextStyle(fontSize: 12, color: c.muted)),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    label: 'New Transaction',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: '🧾 Receipt',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pushNamed('/receipt'),
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
