import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/commission_providers.dart';
import '../../domain/commission_models.dart';
import '../../../float/domain/float_models.dart';

/// Port of the prototype's CommissionRatesScreen.
/// Per-operation, per-provider rate editor (spec §5.4 PUT /commission/rates).
class CommissionRatesScreen extends ConsumerStatefulWidget {
  const CommissionRatesScreen({super.key});

  @override
  ConsumerState<CommissionRatesScreen> createState() => _CommissionRatesScreenState();
}

class _CommissionRatesScreenState extends ConsumerState<CommissionRatesScreen> {
  // Local controllers keyed by operationType_providerId
  final Map<String, TextEditingController> _controllers = {};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final rates = ref.read(commissionRatesProvider);
    for (final rate in rates) {
      for (final provider in MomoProviderId.values) {
        final key = '${rate.operationType}_${provider.name}';
        _controllers[key] = TextEditingController(
          text: (rate.rateByProvider[provider] ?? 0).toStringAsFixed(2),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    // TODO: replace with PUT /commission/rates (spec §5.4, Owner only).
    final current = ref.read(commissionRatesProvider);
    ref.read(commissionRatesProvider.notifier).state = current.map((rate) {
      var updated = rate;
      for (final provider in MomoProviderId.values) {
        final key = '${rate.operationType}_${provider.name}';
        final value = double.tryParse(_controllers[key]?.text ?? '') ?? (rate.rateByProvider[provider] ?? 0);
        updated = updated.copyWithProvider(provider, value);
      }
      return updated;
    }).toList();

    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rates = ref.watch(commissionRatesProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Commission Rates', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.goldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.gold.withOpacity(0.4)),
            ),
            child: Text(
              '⚠ Changes apply to all new transactions. Existing transactions keep their original rates.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.goldDark),
            ),
          ),
          const SizedBox(height: 12),

          // Rate cards per operation
          ...rates.map((rate) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rate.operationLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: MomoProviderId.values.map((provider) {
                        final key = '${rate.operationType}_${provider.name}';
                        final controller = _controllers[key]!;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(provider.icon, style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 3),
                                    Text(provider.shortLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.muted)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: controller,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  decoration: InputDecoration(
                                    suffixText: rate.unit,
                                    suffixStyle: TextStyle(color: c.muted, fontSize: 11),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (_saved) ...[
            AppCard(
              backgroundColor: c.greenLight,
              borderColor: c.green.withOpacity(0.3),
              child: Center(
                child: Text('✅ Rates saved successfully', style: TextStyle(fontWeight: FontWeight.w700, color: c.green)),
              ),
            ),
            const SizedBox(height: 12),
          ],

          AppButton(label: 'Save Commission Rates', width: double.infinity, onPressed: _save),
        ],
      ),
    );
  }
}
