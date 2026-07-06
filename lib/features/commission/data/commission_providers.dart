import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/commission_models.dart';
import '../../float/domain/float_models.dart';

/// Currently selected period in CommissionScreen.
final commissionPeriodProvider = StateProvider<CommissionPeriod>((ref) => CommissionPeriod.month);

/// Commission summary data.
/// TODO: replace with GET /commission/summary?period= (spec §5.4).
final commissionSummaryProvider = Provider.family<CommissionSummary, CommissionPeriod>((ref, period) {
  switch (period) {
    case CommissionPeriod.today:
      return const CommissionSummary(
        total: 237.50,
        transactionCount: 18,
        previousTotal: 198.00,
        byType: {'Cash In': 98.50, 'Cash Out': 72.00, 'Send Money': 44.00, 'Airtime': 18.00, 'Bill Payment': 5.00},
        byProvider: {MomoProviderId.mtn: 130.00, MomoProviderId.telecel: 68.50, MomoProviderId.at: 39.00},
      );
    case CommissionPeriod.week:
      return const CommissionSummary(
        total: 1420.00,
        transactionCount: 112,
        previousTotal: 1280.00,
        byType: {'Cash In': 580.00, 'Cash Out': 430.00, 'Send Money': 260.00, 'Airtime': 110.00, 'Bill Payment': 40.00},
        byProvider: {MomoProviderId.mtn: 780.00, MomoProviderId.telecel: 410.00, MomoProviderId.at: 230.00},
      );
    case CommissionPeriod.month:
      return const CommissionSummary(
        total: 3740.00,
        transactionCount: 482,
        previousTotal: 3200.00,
        byType: {'Cash In': 1520.00, 'Cash Out': 1140.00, 'Send Money': 680.00, 'Airtime': 290.00, 'Bill Payment': 110.00},
        byProvider: {MomoProviderId.mtn: 2050.00, MomoProviderId.telecel: 1080.00, MomoProviderId.at: 610.00},
      );
    case CommissionPeriod.year:
      return const CommissionSummary(
        total: 38200.00,
        transactionCount: 4820,
        previousTotal: 31000.00,
        byType: {'Cash In': 15400.00, 'Cash Out': 11600.00, 'Send Money': 6900.00, 'Airtime': 2900.00, 'Bill Payment': 1400.00},
        byProvider: {MomoProviderId.mtn: 21000.00, MomoProviderId.telecel: 11000.00, MomoProviderId.at: 6200.00},
      );
  }
});

/// Agent leaderboard.
/// TODO: replace with GET /commission/by-agent (spec §5.4).
final agentLeaderboardProvider = Provider<List<AgentCommission>>((ref) => [
      const AgentCommission(agentId: '1', agentName: 'Kwame Asante', branch: 'Accra Central', total: 3740, transactionCount: 482, rank: 1, previousRank: 1),
      const AgentCommission(agentId: '2', agentName: 'Ama Boateng', branch: 'Tema Station', total: 2910, transactionCount: 374, rank: 2, previousRank: 3),
      const AgentCommission(agentId: '3', agentName: 'Kofi Mensah', branch: 'Accra Central', total: 2450, transactionCount: 312, rank: 3, previousRank: 2),
      const AgentCommission(agentId: '4', agentName: 'Akua Sarpong', branch: 'Kumasi Kejetia', total: 1820, transactionCount: 241, rank: 4, previousRank: 4),
      const AgentCommission(agentId: '5', agentName: 'Yaw Larbi', branch: 'Takoradi Market', total: 1340, transactionCount: 178, rank: 5, previousRank: 6),
    ]);

/// Commission rate configuration.
/// TODO: replace with GET /commission/rates (spec §5.4).
final commissionRatesProvider = StateProvider<List<CommissionRate>>((ref) => [
      CommissionRate(operationType: 'cashin', operationLabel: 'Cash In', unit: '%', rateByProvider: {MomoProviderId.mtn: 1.5, MomoProviderId.telecel: 1.5, MomoProviderId.at: 1.5}),
      CommissionRate(operationType: 'cashout', operationLabel: 'Cash Out', unit: '%', rateByProvider: {MomoProviderId.mtn: 1.5, MomoProviderId.telecel: 1.5, MomoProviderId.at: 1.5}),
      CommissionRate(operationType: 'send', operationLabel: 'Send Money', unit: '%', rateByProvider: {MomoProviderId.mtn: 1.0, MomoProviderId.telecel: 1.0, MomoProviderId.at: 1.0}),
      CommissionRate(operationType: 'bill', operationLabel: 'Bill Payment', unit: 'GH₵', rateByProvider: {MomoProviderId.mtn: 0.50, MomoProviderId.telecel: 0.50, MomoProviderId.at: 0.50}),
      CommissionRate(operationType: 'airtime', operationLabel: 'Airtime', unit: '%', rateByProvider: {MomoProviderId.mtn: 3.0, MomoProviderId.telecel: 3.0, MomoProviderId.at: 3.0}),
      CommissionRate(operationType: 'bundle', operationLabel: 'Data Bundle', unit: '%', rateByProvider: {MomoProviderId.mtn: 2.0, MomoProviderId.telecel: 2.0, MomoProviderId.at: 2.0}),
      CommissionRate(operationType: 'merchant', operationLabel: 'Merchant Pay', unit: '%', rateByProvider: {MomoProviderId.mtn: 0.5, MomoProviderId.telecel: 0.5, MomoProviderId.at: 0.5}),
    ]);
