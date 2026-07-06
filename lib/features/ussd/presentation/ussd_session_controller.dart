import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/ussd_data.dart';
import 'ussd_models.dart';

/// Immutable snapshot of an active USSD session.
class UssdSessionState {
  final UssdProvider? provider;
  final bool active;
  final UssdNode? currentNode;
  final List<UssdNode> stack; // breadcrumb for "0. Back"
  final List<UssdLogEntry> log;
  final Map<UssdInputType, String> capturedInputs;
  final bool resolved; // true once a terminal response has been shown
  final bool resolvedSuccess;

  const UssdSessionState({
    this.provider,
    this.active = false,
    this.currentNode,
    this.stack = const [],
    this.log = const [],
    this.capturedInputs = const {},
    this.resolved = false,
    this.resolvedSuccess = false,
  });

  UssdSessionState copyWith({
    UssdProvider? provider,
    bool? active,
    UssdNode? currentNode,
    List<UssdNode>? stack,
    List<UssdLogEntry>? log,
    Map<UssdInputType, String>? capturedInputs,
    bool? resolved,
    bool? resolvedSuccess,
  }) {
    return UssdSessionState(
      provider: provider ?? this.provider,
      active: active ?? this.active,
      currentNode: currentNode ?? this.currentNode,
      stack: stack ?? this.stack,
      log: log ?? this.log,
      capturedInputs: capturedInputs ?? this.capturedInputs,
      resolved: resolved ?? this.resolved,
      resolvedSuccess: resolvedSuccess ?? this.resolvedSuccess,
    );
  }

  /// Hint text shown above the input field, based on the current node.
  String get inputHint {
    final node = currentNode;
    if (node == null) return 'Enter option';
    if (node.requiresPin) return 'Enter 4-digit PIN';
    switch (node.inputType) {
      case UssdInputType.pin:
        return 'Enter 4-digit PIN';
      case UssdInputType.phone:
        return 'Enter phone number';
      case UssdInputType.amount:
        return 'Enter amount in GH₵';
      case UssdInputType.text:
        return 'Enter value';
      case UssdInputType.none:
        return 'Enter option number';
    }
  }
}

/// Drives one USSD session: dialling, menu navigation, free-text capture,
/// and terminal resolution. Mirrors the prototype's processInput / resolveTerminal.
class UssdSessionController extends StateNotifier<UssdSessionState> {
  UssdSessionController() : super(const UssdSessionState());

  final _rng = Random();
  final List<UssdHistoryItem> history = [
    const UssdHistoryItem(providerId: 'MTN', code: '*170#', action: 'Check Balance', result: 'GH₵ 2,400.00', time: 'Today 10:41 AM', success: true),
    const UssdHistoryItem(providerId: 'Telecel', code: '*110#', action: 'Send Money', result: 'GH₵ 300 → 0201234567', time: 'Yesterday 3:15 PM', success: true),
  ];

  String _genRef() => 'GH${_rng.nextInt(900000) + 100000}';
  String _genToken() => List.generate(4, (_) => (1000 + _rng.nextInt(9000)).toString()).join('-');

  void startSession(UssdProvider provider) {
    state = UssdSessionState(
      provider: provider,
      active: true,
      currentNode: provider.root,
      stack: const [],
      log: [UssdLogEntry(UssdLogEntryType.system, 'Dialling ${provider.code}...')],
      capturedInputs: const {},
    );
  }

  void endSession() {
    state = const UssdSessionState();
  }

  void submitInput(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    final node = state.currentNode;
    if (node == null) return;

    final newLog = [...state.log, UssdLogEntry(UssdLogEntryType.user, value)];

    // 1. Root PIN gate
    if (node.requiresPin) {
      final next = node.next!;
      state = state.copyWith(
        log: [...newLog, const UssdLogEntry(UssdLogEntryType.system, 'Verifying PIN...'), UssdLogEntry(UssdLogEntryType.display, next.title)],
        currentNode: next,
      );
      return;
    }

    // 2. Free-text input node (phone/amount/pin/text)
    if (node.inputType != UssdInputType.none) {
      final newInputs = {...state.capturedInputs, node.inputType: value};
      if (node.terminal != null) {
        state = state.copyWith(log: newLog, capturedInputs: newInputs);
        _resolveTerminal(node.terminal!, newInputs);
      } else if (node.next != null) {
        state = state.copyWith(
          log: [...newLog, UssdLogEntry(UssdLogEntryType.display, node.next!.title)],
          stack: [...state.stack, node],
          currentNode: node.next,
          capturedInputs: newInputs,
        );
      }
      return;
    }

    // 3. Menu selection
    if (node.options != null) {
      if (value == '0' && node.options!['0']?.isBack == true) {
        _goBack(newLog);
        return;
      }
      final choice = node.options![value];
      if (choice == null) {
        state = state.copyWith(
          log: [...newLog, const UssdLogEntry(UssdLogEntryType.error, 'Invalid option. Please try again.'), UssdLogEntry(UssdLogEntryType.display, node.title)],
        );
        return;
      }
      if (choice.isBack) {
        _goBack(newLog);
        return;
      }
      final chosenNode = choice.node!;
      if (chosenNode.terminal != null) {
        state = state.copyWith(log: [...newLog, UssdLogEntry(UssdLogEntryType.display, chosenNode.title)]);
        _resolveTerminal(chosenNode.terminal!, state.capturedInputs);
        return;
      }
      state = state.copyWith(
        log: [...newLog, UssdLogEntry(UssdLogEntryType.display, chosenNode.title)],
        stack: [...state.stack, node],
        currentNode: chosenNode,
      );
    }
  }

  void _goBack(List<UssdLogEntry> logSoFar) {
    if (state.stack.isEmpty) return;
    final prev = state.stack.last;
    state = state.copyWith(
      stack: state.stack.sublist(0, state.stack.length - 1),
      currentNode: prev,
      log: [...logSoFar, UssdLogEntry(UssdLogEntryType.display, prev.title)],
    );
  }

  Future<void> _resolveTerminal(String key, Map<UssdInputType, String> inputs) async {
    final resp = UssdData.responses[key];
    if (resp == null) {
      state = state.copyWith(log: [...state.log, const UssdLogEntry(UssdLogEntryType.error, 'Service unavailable. Try again.')]);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    final ref = _genRef();
    final token = _genToken();
    final amount = inputs[UssdInputType.amount] ?? '0.00';
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final rendered = resp.render(amount: amount, ref: ref, token: token, date: date);

    state = state.copyWith(
      log: [...state.log, UssdLogEntry(resp.success ? UssdLogEntryType.success : UssdLogEntryType.error, rendered)],
      resolved: true,
      resolvedSuccess: resp.success,
    );

    final providerName = state.provider?.name ?? '';
    final readableAction = key.replaceAll('_', ' ');
    history.insert(
      0,
      UssdHistoryItem(
        providerId: state.provider?.id ?? '',
        code: state.provider?.code ?? '',
        action: readableAction[0].toUpperCase() + readableAction.substring(1),
        result: resp.success ? 'GH₵ $amount · Ref: $ref' : 'Failed',
        time: 'Today ${DateFormat('h:mm a').format(DateTime.now())}',
        success: resp.success,
      ),
    );
  }
}

final ussdSessionProvider = StateNotifierProvider<UssdSessionController, UssdSessionState>(
  (ref) => UssdSessionController(),
);
