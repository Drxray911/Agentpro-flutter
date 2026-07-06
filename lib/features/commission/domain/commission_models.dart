/// Domain models for Commission tracking (spec §3.7, §4.1, §5.4).
library commission_models;

import '../../float/domain/float_models.dart';

enum CommissionPeriod { today, week, month, year }

extension CommissionPeriodX on CommissionPeriod {
  String get label {
    switch (this) {
      case CommissionPeriod.today:
        return 'Today';
      case CommissionPeriod.week:
        return 'Week';
      case CommissionPeriod.month:
        return 'Month';
      case CommissionPeriod.year:
        return 'Year';
    }
  }
}

/// Overall commission summary for a period.
class CommissionSummary {
  final double total;
  final int transactionCount;
  final Map<String, double> byType; // operation type → amount
  final Map<MomoProviderId, double> byProvider;
  final double previousTotal; // for % change calculation

  const CommissionSummary({
    required this.total,
    required this.transactionCount,
    required this.byType,
    required this.byProvider,
    required this.previousTotal,
  });

  double get changePercent => previousTotal == 0 ? 0 : ((total - previousTotal) / previousTotal) * 100;
  bool get isPositiveChange => total >= previousTotal;
}

/// One agent's commission totals for the leaderboard.
class AgentCommission {
  final String agentId;
  final String agentName;
  final String branch;
  final double total;
  final int transactionCount;
  final int rank;
  final int previousRank;

  const AgentCommission({
    required this.agentId,
    required this.agentName,
    required this.branch,
    required this.total,
    required this.transactionCount,
    required this.rank,
    required this.previousRank,
  });

  bool get isRankUp => rank < previousRank;
  bool get isRankDown => rank > previousRank;
}

/// Configurable per-operation, per-provider commission rate.
/// Maps to the commission_rates config managed in CommissionRatesScreen (spec §3.7).
class CommissionRate {
  final String operationType;
  final String operationLabel;
  final String unit; // '%' or 'GH₵'
  final Map<MomoProviderId, double> rateByProvider;

  const CommissionRate({
    required this.operationType,
    required this.operationLabel,
    required this.unit,
    required this.rateByProvider,
  });

  CommissionRate copyWithProvider(MomoProviderId provider, double rate) {
    return CommissionRate(
      operationType: operationType,
      operationLabel: operationLabel,
      unit: unit,
      rateByProvider: {...rateByProvider, provider: rate},
    );
  }
}

enum PayoutMethod { momo, bank }

/// A payout request submitted by an agent (spec §5.4 POST /commission/payout).
class PayoutRequest {
  final PayoutMethod method;
  final String accountNumber;
  final double amount;

  const PayoutRequest({
    required this.method,
    required this.accountNumber,
    required this.amount,
  });
}
