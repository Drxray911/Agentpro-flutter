import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../data/ussd_data.dart';
import '../domain/ussd_models.dart';
import 'ussd_session_controller.dart';

/// Port of the prototype's USSDScreen.
/// Three states: provider picker (idle), active session (terminal + keypad),
/// and a History tab. Quick Codes tab omitted here for brevity — same
/// pattern as History, see prototype for reference.
class UssdScreen extends ConsumerStatefulWidget {
  const UssdScreen({super.key});

  @override
  ConsumerState<UssdScreen> createState() => _UssdScreenState();
}

class _UssdScreenState extends ConsumerState<UssdScreen> {
  String _tab = 'Dial';
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final controller = ref.read(ussdSessionProvider.notifier);
    controller.submitInput(_inputController.text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _keypadTap(String key) {
    if (key == 'DEL') {
      if (_inputController.text.isNotEmpty) {
        _inputController.text = _inputController.text.substring(0, _inputController.text.length - 1);
      }
      return;
    }
    if (key == 'SEND') {
      _send();
      return;
    }
    _inputController.text += key;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(ussdSessionProvider);
    final c = context.colors;

    if (session.active) return _buildSession(context, session, c);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'USSD Navigator',
        trailing: TextButton(onPressed: () => setState(() => _tab = 'History'), child: const Text('History')),
      ),
      body: Column(
        children: [
          AppTabs(tabs: const ['Dial', 'History'], active: _tab, onChanged: (t) => setState(() => _tab = t)),
          Expanded(child: _tab == 'History' ? _buildHistory(context) : _buildDial(context)),
        ],
      ),
    );
  }

  Widget _buildDial(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          const Text('📟', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text('USSD Navigator', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c.charcoal)),
          const SizedBox(height: 4),
          Text('Select a provider to start a USSD session', style: TextStyle(fontSize: 13, color: c.muted)),
          const SizedBox(height: 24),
          ...UssdData.providers.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => ref.read(ussdSessionProvider.notifier).startSession(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: c.white,
                      border: Border.all(color: c.border, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(color: Color(p.colorValue), borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.center,
                          child: Text(p.icon, style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.charcoal)),
                              const SizedBox(height: 2),
                              Text('Dial ${p.code} · Tap to start session', style: TextStyle(fontSize: 13, color: c.muted)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: c.muted, size: 22),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.goldLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.gold.withOpacity(0.4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠ Important Notice', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.goldDark)),
                const SizedBox(height: 6),
                Text(
                  'This USSD navigator guides you through approved Mobile Money workflows. No PINs are stored by Agent Pro Ghana. This feature uses operator-approved USSD flows only.',
                  style: TextStyle(fontSize: 12, color: c.slate, height: 1.65),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final c = context.colors;
    final controller = ref.read(ussdSessionProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Text('RECENT USSD SESSIONS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        ...controller.history.map((h) {
          final provider = UssdData.byId(h.providerId);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                top: BorderSide(color: c.border),
                right: BorderSide(color: c.border),
                bottom: BorderSide(color: c.border),
                left: BorderSide(color: h.success ? c.green : c.red, width: 4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.action, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('${provider?.icon ?? ''} ${h.providerId} · ${h.code}', style: TextStyle(fontSize: 12, color: c.muted)),
                      Text(h.result, style: TextStyle(fontSize: 11, color: c.muted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppBadge(label: h.success ? 'OK' : 'Failed', color: h.success ? c.green : c.red),
                    const SizedBox(height: 4),
                    Text(h.time, style: TextStyle(fontSize: 10, color: c.muted)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSession(BuildContext context, UssdSessionState session, AppColors c) {
    final provider = session.provider!;
    final screenColor = Color(provider.colorValue);

    return Scaffold(
      backgroundColor: c.surface,
      body: Column(
        children: [
          // Session header bar
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 10),
            color: screenColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('USSD SESSION ACTIVE', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      Text('${provider.name} · ${provider.code}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                  onPressed: () => ref.read(ussdSessionProvider.notifier).endSession(),
                  child: const Text('End ✕'),
                ),
              ],
            ),
          ),

          // Terminal screen
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...session.log.map((entry) => _LogLine(entry: entry)),
                    if (!session.resolved && session.log.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(session.inputHint, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('›', style: TextStyle(color: Color(0xFF7EFFC5), fontFamily: 'monospace')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: AnimatedBuilder(
                                animation: _inputController,
                                builder: (_, __) {
                                  final isPin = session.currentNode?.inputType == UssdInputType.pin;
                                  final display = isPin ? '•' * _inputController.text.length : _inputController.text;
                                  return Text(
                                    '${display}_',
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.white),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (session.resolved) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
                              onPressed: () => ref.read(ussdSessionProvider.notifier).endSession(),
                              child: const Text('New Session'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7EFFC5), foregroundColor: const Color(0xFF1A1A1A)),
                              onPressed: () => ref.read(ussdSessionProvider.notifier).startSession(provider),
                              child: const Text('Retry Same'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Keypad
          if (!session.resolved)
            Container(
              color: c.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
                        .map((k) => OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border, width: 1.5),
                                foregroundColor: c.charcoal,
                              ),
                              onPressed: () => _keypadTap(k),
                              child: Text(k, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(label: '⌫ DEL', variant: AppButtonVariant.danger, onPressed: () => _keypadTap('DEL')),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(label: 'SEND ↵', onPressed: () => _keypadTap('SEND')),
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
}

class _LogLine extends StatelessWidget {
  final UssdLogEntry entry;
  const _LogLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late Color? borderColor;
    switch (entry.type) {
      case UssdLogEntryType.user:
        color = const Color(0xFF7EFFC5);
        borderColor = const Color(0xFF7EFFC5);
        break;
      case UssdLogEntryType.success:
        color = const Color(0xFF7EFFC5);
        borderColor = const Color(0xFF7EFFC5);
        break;
      case UssdLogEntryType.error:
        color = const Color(0xFFFF6B6B);
        borderColor = const Color(0xFFFF6B6B);
        break;
      case UssdLogEntryType.system:
        color = const Color(0xFF888888);
        borderColor = null;
        break;
      case UssdLogEntryType.display:
        color = const Color(0xFFE0E0E0);
        borderColor = null;
        break;
    }

    final text = entry.type == UssdLogEntryType.user ? '> ${entry.text}' : entry.text;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: borderColor != null ? const EdgeInsets.only(left: 8) : EdgeInsets.zero,
      decoration: borderColor != null ? BoxDecoration(border: Border(left: BorderSide(color: borderColor, width: 3))) : null,
      child: Text(text, style: TextStyle(fontSize: 13, color: color, fontFamily: 'monospace', height: 1.5)),
    );
  }
}
