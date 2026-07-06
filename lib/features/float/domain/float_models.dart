/// Domain models for Float Management (spec §3.5, §4.1 float_balances/float_movements).
library float_models;

enum MomoProviderId { mtn, telecel, at }

extension MomoProviderIdX on MomoProviderId {
  String get label {
    switch (this) {
      case MomoProviderId.mtn:
        return 'MTN MoMo';
      case MomoProviderId.telecel:
        return 'Telecel Cash';
      case MomoProviderId.at:
        return 'AT Money';
    }
  }

  String get shortLabel {
    switch (this) {
      case MomoProviderId.mtn:
        return 'MTN';
      case MomoProviderId.telecel:
        return 'Telecel';
      case MomoProviderId.at:
        return 'AT';
    }
  }

  String get icon {
    switch (this) {
      case MomoProviderId.mtn:
        return '🟡';
      case MomoProviderId.telecel:
        return '🔴';
      case MomoProviderId.at:
        return '🔵';
    }
  }

  int get colorValue {
    switch (this) {
      case MomoProviderId.mtn:
        return 0xFFFFCC00;
      case MomoProviderId.telecel:
        return 0xFFDC143C;
      case MomoProviderId.at:
        return 0xFF0047AB;
    }
  }
}

/// Maps to the `float_balances` table (spec §4.1).
class FloatBalance {
  final MomoProviderId provider;
  final double balance;
  final double limit;
  final double alertThreshold;

  const FloatBalance({
    required this.provider,
    required this.balance,
    required this.limit,
    required this.alertThreshold,
  });

  bool get isLow => balance < alertThreshold;
  double get ratio => limit == 0 ? 0 : (balance / limit).clamp(0, 1);

  FloatBalance copyWith({double? balance, double? limit, double? alertThreshold}) {
    return FloatBalance(
      provider: provider,
      balance: balance ?? this.balance,
      limit: limit ?? this.limit,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }
}

enum FloatMovementType { topup, debit, reversalCredit }
enum FloatTopUpSource { momo, bank, cash }

/// Maps to the `float_movements` table (spec §4.1).
class FloatMovement {
  final FloatMovementType type;
  final String description;
  final double amount; // signed: positive = credit, negative = debit
  final double balanceAfter;
  final DateTime time;

  const FloatMovement({
    required this.type,
    required this.description,
    required this.amount,
    required this.balanceAfter,
    required this.time,
  });
}

/// One branch's float snapshot, used by the multi-branch comparison screen.
class BranchFloatSnapshot {
  final String branchName;
  final Map<MomoProviderId, double> byProvider;

  const BranchFloatSnapshot({required this.branchName, required this.byProvider});

  double get total => byProvider.values.fold(0, (a, b) => a + b);
}
