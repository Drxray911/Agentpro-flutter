import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';

/// Transaction types matching spec §4.1 transactions.type ENUM.
enum TransactionType { cashin, cashout, send, merchant, bill, airtime, bundle, balance, statement, reversal }

extension TransactionTypeX on TransactionType {
  String get apiValue => name; // matches ENUM values exactly
}

/// Request body for POST /transactions (spec §5.2).
class TransactionRequest {
  final TransactionType type;
  final String provider; // 'mtn' | 'telecel' | 'at'
  final String customerPhone;
  final double amount;
  final int simSlot; // 1 or 2
  final Map<String, dynamic>? metadata; // bill details, merchant code, etc.

  const TransactionRequest({
    required this.type,
    required this.provider,
    required this.customerPhone,
    required this.amount,
    required this.simSlot,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'type': type.apiValue,
        'provider': provider,
        'customer_phone': customerPhone,
        'amount': amount,
        'sim_slot': simSlot,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Response from POST /transactions (spec §5.2).
class TransactionResult {
  final String id;
  final String reference;
  final String status; // 'completed' | 'failed' | 'pending'
  final double commissionEarned;
  final String? responseCode;
  final String? responseMessage;
  final String? providerReference;

  const TransactionResult({
    required this.id,
    required this.reference,
    required this.status,
    required this.commissionEarned,
    this.responseCode,
    this.responseMessage,
    this.providerReference,
  });

  bool get isSuccess => status == 'completed';

  factory TransactionResult.fromJson(Map<String, dynamic> j) => TransactionResult(
        id: j['id'] as String,
        reference: j['reference'] as String,
        status: j['status'] as String,
        commissionEarned: (j['commission_earned'] as num).toDouble(),
        responseCode: j['response_code'] as String?,
        responseMessage: j['response_message'] as String?,
        providerReference: j['provider_reference'] as String?,
      );

  /// Fallback for when API is unavailable (demo mode).
  factory TransactionResult.demo({required String type, required double amount}) {
    final ref = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    return TransactionResult(
      id: ref,
      reference: ref,
      status: 'completed',
      commissionEarned: amount * 0.015,
      responseCode: '00',
      responseMessage: 'Transaction Successful',
    );
  }
}

/// Wraps a single transaction's summary for the UI to display in history.
class TransactionSummary {
  final String id;
  final String reference;
  final String type;
  final String provider;
  final String customerPhone;
  final double amount;
  final double commissionEarned;
  final String status;
  final DateTime processedAt;
  final String agentName;
  final String branchName;

  const TransactionSummary({
    required this.id,
    required this.reference,
    required this.type,
    required this.provider,
    required this.customerPhone,
    required this.amount,
    required this.commissionEarned,
    required this.status,
    required this.processedAt,
    required this.agentName,
    required this.branchName,
  });

  bool get isSuccess => status == 'completed';

  factory TransactionSummary.fromJson(Map<String, dynamic> j) => TransactionSummary(
        id: j['id'] as String,
        reference: j['reference'] as String,
        type: j['type'] as String,
        provider: j['provider'] as String,
        customerPhone: j['customer_phone'] as String,
        amount: (j['amount'] as num).toDouble(),
        commissionEarned: (j['commission_earned'] as num? ?? 0).toDouble(),
        status: j['status'] as String,
        processedAt: DateTime.parse(j['processed_at'] as String),
        agentName: j['agent_name'] as String? ?? '',
        branchName: j['branch_name'] as String? ?? '',
      );

  /// Demo data for UI development.
  static List<TransactionSummary> demoList() => [
        TransactionSummary(id: '1', reference: 'TXN-A1B2C3', type: 'cashin', provider: 'mtn', customerPhone: '0244567890', amount: 500, commissionEarned: 7.50, status: 'completed', processedAt: DateTime.now().subtract(const Duration(minutes: 20)), agentName: 'Kwame Asante', branchName: 'Accra Central'),
        TransactionSummary(id: '2', reference: 'TXN-D4E5F6', type: 'cashout', provider: 'telecel', customerPhone: '0551234567', amount: 300, commissionEarned: 4.50, status: 'completed', processedAt: DateTime.now().subtract(const Duration(hours: 1)), agentName: 'Kwame Asante', branchName: 'Accra Central'),
        TransactionSummary(id: '3', reference: 'TXN-G7H8I9', type: 'bill', provider: 'mtn', customerPhone: '0244000001', amount: 150, commissionEarned: 0.50, status: 'completed', processedAt: DateTime.now().subtract(const Duration(hours: 2)), agentName: 'Kwame Asante', branchName: 'Accra Central'),
        TransactionSummary(id: '4', reference: 'TXN-J1K2L3', type: 'send', provider: 'mtn', customerPhone: '0277890123', amount: 800, commissionEarned: 8.00, status: 'completed', processedAt: DateTime.now().subtract(const Duration(hours: 3)), agentName: 'Kwame Asante', branchName: 'Accra Central'),
        TransactionSummary(id: '5', reference: 'TXN-M4N5O6', type: 'airtime', provider: 'at', customerPhone: '0264321987', amount: 20, commissionEarned: 0.60, status: 'failed', processedAt: DateTime.now().subtract(const Duration(hours: 4)), agentName: 'Ama Boateng', branchName: 'Tema Station'),
      ];
}

/// Repository implementing spec §5.2 transaction endpoints.
class TransactionRepository {
  final Dio _dio;

  const TransactionRepository(this._dio);

  /// POST /transactions — initiate a new MoMo transaction.
  /// Falls back to demo mode if API unavailable (network error).
  Future<TransactionResult> submit(TransactionRequest req) async {
    try {
      final resp = await _dio.post('/transactions', data: req.toJson());
      return TransactionResult.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // During development, fall back to demo data on network errors
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return TransactionResult.demo(type: req.type.apiValue, amount: req.amount);
      }
      throw AppException.fromDio(e);
    }
  }

  /// GET /transactions — paginated transaction list with filters.
  Future<List<TransactionSummary>> list({
    String? type,
    String? provider,
    String? branchId,
    String? agentId,
    DateTime? from,
    DateTime? to,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final resp = await _dio.get('/transactions', queryParameters: {
        if (type != null) 'type': type,
        if (provider != null) 'provider': provider,
        if (branchId != null) 'branch_id': branchId,
        if (agentId != null) 'agent_id': agentId,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      });
      final list = resp.data['data'] as List;
      return list.map((j) => TransactionSummary.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return TransactionSummary.demoList();
      }
      throw AppException.fromDio(e);
    }
  }

  /// POST /transactions/:id/reverse — request a reversal.
  Future<void> reverse(String txnId, {required String reason, String? notes}) async {
    try {
      await _dio.post('/transactions/$txnId/reverse', data: {
        'reason': reason,
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(dioProvider)),
);

/// Cached recent transactions for the current session.
final recentTransactionsProvider = StateProvider<List<TransactionSummary>>(
  (_) => TransactionSummary.demoList(),
);
