import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/float_providers.dart';
import '../../domain/float_models.dart';

/// Port of the prototype's FloatThresholdScreen.
/// Per-provider low-float alert thresholds + SMS/Push/Email channel toggles.
class FloatThresholdScreen extends ConsumerStatefulWidget {
  const FloatThresholdScreen({super.key});

  @override
  ConsumerState<FloatThresholdScreen> createState() => _FloatThresholdScreenState();
}

class _FloatThresholdScreenState extends ConsumerState<FloatThresholdScreen> {
  final Map<MomoProviderId, TextEditingController> _controllers = {};
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _emailEnabled = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    for (final b in ref.read(floatBalancesProvider)) {
      _controllers[b.provider] = TextEditingController(text: b.alertThreshold.toStringAsFixed(0));
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
    // TODO: replace with PUT /float/thresholds (spec §5.3).
    final balances = ref.read(floatBalancesProvider);
    ref.read(floatBalancesProvider.notifier).state = balances.map((b) {
      final newThreshold = double.tryParse(_controllers[b.provider]?.text ?? '') ?? b.alertThreshold;
      return b.copyWith(alertThreshold: newThreshold);
    }).toList();
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final balances = ref.watch(floatBalancesProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Float Alert Thresholds', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Low Float Thresholds', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 6),
                Text("You'll be alerted when any provider's float drops below these amounts.", style: TextStyle(fontSize: 12, color: c.muted, height: 1.6)),
                const SizedBox(height: 14),
                ...balances.map((b) {
                  final controller = _controllers[b.provider]!;
                  final currentInput = double.tryParse(controller.text) ?? b.alertThreshold;
                  final isLowNow = currentInput > b.balance;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(b.provider.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(b.provider.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(width: 6),
                            Text('— Current: GH₵ ${b.balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: c.muted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(prefixText: 'GH₵ '),
                              ),
                            ),
                            const SizedBox(width: 10),
                            AppBadge(label: isLowNow ? '⚠ Low Now' : 'OK', color: isLowNow ? c.red : c.green),
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
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alert Channels', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 6),
                _ChannelToggle(label: '📳 Push Notification', value: _pushEnabled, onChanged: (v) => setState(() => _pushEnabled = v)),
                _ChannelToggle(label: '💬 SMS Alert', value: _smsEnabled, onChanged: (v) => setState(() => _smsEnabled = v)),
                _ChannelToggle(label: '📧 Email Alert', value: _emailEnabled, onChanged: (v) => setState(() => _emailEnabled = v), isLast: true),
              ],
            ),
          ),
          if (_saved) ...[
            const SizedBox(height: 12),
            AppCard(
              backgroundColor: c.greenLight,
              borderColor: c.green.withOpacity(0.3),
              child: Center(child: Text('✅ Thresholds saved successfully', style: TextStyle(fontWeight: FontWeight.w700, color: c.green))),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(label: 'Save Thresholds', width: double.infinity, onPressed: _save),
        ],
      ),
    );
  }
}

class _ChannelToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;
  const _ChannelToggle({required this.label, required this.value, required this.onChanged, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Switch(value: value, onChanged: onChanged, activeColor: c.green),
        ],
      ),
    );
  }
}
