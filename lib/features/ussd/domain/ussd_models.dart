/// Domain models for the USSD Navigator feature.
/// Mirrors the prototype's USSD_TREES / TERMINAL_RESPONSES JS objects
/// (see agent-pro-ghana.jsx, USSDScreen) but as strongly-typed Dart classes.
///
/// A USSD session is a tree: each [UssdNode] either:
///   - presents a menu of [options] keyed by the digit the user enters, or
///   - asks for free-text [inputType] (phone/amount/pin/text) and moves to [next],
///   - or is a [terminal] leaf that resolves to a [UssdResponse].
library ussd_models;

enum UssdInputType { none, phone, amount, pin, text }

class UssdNode {
  final String title;
  final bool requiresPin;
  final UssdInputType inputType;
  final Map<String, UssdOption>? options;
  final UssdNode? next;
  final String? terminal;

  const UssdNode({
    required this.title,
    this.requiresPin = false,
    this.inputType = UssdInputType.none,
    this.options,
    this.next,
    this.terminal,
  });
}

/// An option is either a nested [UssdNode], the literal string "back",
/// or null (treated as invalid input).
class UssdOption {
  final UssdNode? node;
  final bool isBack;

  const UssdOption.node(this.node) : isBack = false;
  const UssdOption.back()
      : node = null,
        isBack = true;
}

class UssdProvider {
  final String id; // 'MTN' | 'Telecel' | 'AT'
  final String code; // e.g. *170#
  final String name;
  final int colorValue; // ARGB int, avoids importing material here
  final String icon; // emoji, matches prototype
  final UssdNode root;

  const UssdProvider({
    required this.id,
    required this.code,
    required this.name,
    required this.colorValue,
    required this.icon,
    required this.root,
  });
}

class UssdResponse {
  final bool success;
  final String messageTemplate; // contains {amount}, {ref}, {token}, {date}

  const UssdResponse({required this.success, required this.messageTemplate});

  String render({String amount = '0.00', required String ref, required String token, required String date}) {
    return messageTemplate
        .replaceAll('{amount}', amount)
        .replaceAll('{ref}', ref)
        .replaceAll('{token}', token)
        .replaceAll('{date}', date);
  }
}

enum UssdLogEntryType { system, user, display, success, error }

class UssdLogEntry {
  final UssdLogEntryType type;
  final String text;
  const UssdLogEntry(this.type, this.text);
}

/// One row in the USSD session history list.
class UssdHistoryItem {
  final String providerId;
  final String code;
  final String action;
  final String result;
  final String time;
  final bool success;

  const UssdHistoryItem({
    required this.providerId,
    required this.code,
    required this.action,
    required this.result,
    required this.time,
    required this.success,
  });
}

/// A user-saved custom USSD shortcut (spec §3.4, USSDConfigScreen).
class UssdCustomCode {
  final String label;
  final String code;
  final String shortcut;

  const UssdCustomCode({required this.label, required this.code, required this.shortcut});
}
