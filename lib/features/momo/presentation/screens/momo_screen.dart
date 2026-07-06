import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import 'momo_transaction_flow.dart';

/// Port of the prototype's MoMoScreen.
/// 12-operation grid (Cash In, Cash Out, Send Money, Merchant Pay, Bill
/// Payment, Airtime, Data Bundle, Balance, Mini Statement, History,
/// Reversal, Search) plus provider float status summary.
class MomoScreen extends StatelessWidget {
  const MomoScreen({super.key});

  static const _ops = [
    (id: 'cashin', icon: Icons.south_west_rounded, label: 'Cash In'),
    (id: 'cashout', icon: Icons.north_east_rounded, label: 'Cash Out'),
    (id: 'send', icon: Icons.send_rounded, label: 'Send Money'),
    (id: 'merchant', icon: Icons.storefront_rounded, label: 'Merchant Pay'),
    (id: 'bill', icon: Icons.receipt_long_rounded, label: 'Bill Payment'),
    (id: 'airtime', icon: Icons.smartphone_rounded, label: 'Airtime'),
    (id: 'bundle', icon: Icons.wifi_rounded, label: 'Data Bundle'),
    (id: 'balance', icon: Icons.account_balance_wallet_rounded, label: 'Balance'),
    (id: 'statement', icon: Icons.receipt_rounded, label: 'Mini Statement'),
    (id: 'history', icon: Icons.history_rounded, label: 'History'),
    (id: 'reversal', icon: Icons.undo_rounded, label: 'Reversal'),
    (id: 'search', icon: Icons.search_rounded, label: 'Search'),
  ];

  void _openOp(BuildContext context, String opId, String label) {
    if (['balance', 'statement', 'history', 'reversal', 'search'].contains(opId)) {
      // These route to dedicated screens in the full app (see app_routes.dart).
      Navigator.of(context).pushNamed('/$opId');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MomoTransactionFlow(operationId: opId, operationLabel: label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'Mobile Money'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
              children: _ops.map((op) {
                return InkWell(
                  onTap: () => _openOp(context, op.id, op.label),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.white,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: c.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Icon(op.icon, size: 20, color: c.green),
                        ),
                        const SizedBox(height: 6),
                        Text(op.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.slate)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const _ProviderFloatStatusCard(),
          ],
        ),
      ),
    );
  }
}

class _ProviderFloatStatusCard extends StatelessWidget {
  const _ProviderFloatStatusCard();

  static const _providers = [
    (name: 'MTN MoMo', float: 2400.0, max: 5000.0, low: true),
    (name: 'Telecel Cash', float: 1620.0, max: 3000.0, low: false),
    (name: 'AT Money', float: 800.0, max: 2000.0, low: false),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Provider Float Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 10),
          ..._providers.map((p) {
            final ratio = (p.float / p.max).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Row(
                        children: [
                          Text('GH₵ ${p.float.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          if (p.low) ...[
                            const SizedBox(width: 6),
                            AppBadge(label: '⚠ Low', color: c.red),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: c.border,
                      color: p.low ? c.red : c.green,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
