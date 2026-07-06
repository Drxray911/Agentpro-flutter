import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/float_models.dart';

/// Mock float balances for the active branch.
/// TODO: replace with a repository call to GET /float/balances (spec §5.3).
final floatBalancesProvider = StateProvider<List<FloatBalance>>((ref) => [
      const FloatBalance(provider: MomoProviderId.mtn, balance: 2400, limit: 5000, alertThreshold: 2500),
      const FloatBalance(provider: MomoProviderId.telecel, balance: 1620, limit: 3000, alertThreshold: 1000),
      const FloatBalance(provider: MomoProviderId.at, balance: 800, limit: 2000, alertThreshold: 1000),
    ]);

/// Mock movement history.
/// TODO: replace with GET /float/movements (spec §5.3).
final floatMovementsProvider = Provider<List<FloatMovement>>((ref) => [
      FloatMovement(type: FloatMovementType.topup, description: 'MTN Float Top-up', amount: 2000, balanceAfter: 4820, time: DateTime.now()),
      FloatMovement(type: FloatMovementType.debit, description: 'AT Money Cash Out', amount: -500, balanceAfter: 2820, time: DateTime.now().subtract(const Duration(days: 1))),
      FloatMovement(type: FloatMovementType.topup, description: 'Telecel Cash In', amount: 800, balanceAfter: 3320, time: DateTime.now().subtract(const Duration(days: 1))),
    ]);

/// Mock multi-branch float comparison.
/// TODO: replace with GET /float/balances/comparison (spec §5.3, Manager+ only).
final branchFloatComparisonProvider = Provider<List<BranchFloatSnapshot>>((ref) => [
      const BranchFloatSnapshot(branchName: 'Accra Central', byProvider: {
        MomoProviderId.mtn: 6200,
        MomoProviderId.telecel: 3800,
        MomoProviderId.at: 2400,
      }),
      const BranchFloatSnapshot(branchName: 'Kumasi Kejetia', byProvider: {
        MomoProviderId.mtn: 8100,
        MomoProviderId.telecel: 4200,
        MomoProviderId.at: 3800,
      }),
      const BranchFloatSnapshot(branchName: 'Tema Station', byProvider: {
        MomoProviderId.mtn: 3400,
        MomoProviderId.telecel: 2800,
        MomoProviderId.at: 1200,
      }),
      const BranchFloatSnapshot(branchName: 'Takoradi Market', byProvider: {
        MomoProviderId.mtn: 1800,
        MomoProviderId.telecel: 900,
        MomoProviderId.at: 800,
      }),
    ]);
