/// Domain models for eCash (spec §3.6, §4.1).
library ecash_models;

enum ECashTransactionType { sent, received, requested }
enum ECashRequestStatus { pending, approved, rejected }

class ECashBalance {
  final String walletId;
  final double balance;

  const ECashBalance({required this.walletId, required this.balance});
}

class ECashTransaction {
  final String id;
  final String reference;
  final ECashTransactionType type;
  final String counterpartyName;
  final String counterpartyId;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const ECashTransaction({
    required this.id,
    required this.reference,
    required this.type,
    required this.counterpartyName,
    required this.counterpartyId,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  bool get isCredit => type == ECashTransactionType.received;

  static List<ECashTransaction> demoList() => [
        ECashTransaction(id: '1', reference: 'ECH-A1B2C3D4', type: ECashTransactionType.sent, counterpartyName: 'Abena Mensah', counterpartyId: 'APG-AM-00187', amount: 500, note: 'Float assistance', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
        ECashTransaction(id: '2', reference: 'ECH-E5F6G7H8', type: ECashTransactionType.received, counterpartyName: 'Kofi Mensah', counterpartyId: 'APG-KM-00312', amount: 1200, note: 'End of day balance', createdAt: DateTime.now().subtract(const Duration(hours: 6))),
        ECashTransaction(id: '3', reference: 'ECH-I9J0K1L2', type: ECashTransactionType.sent, counterpartyName: 'Ama Boateng', counterpartyId: 'APG-AB-00221', amount: 300, createdAt: DateTime.now().subtract(const Duration(days: 1))),
        ECashTransaction(id: '4', reference: 'ECH-M3N4O5P6', type: ECashTransactionType.received, counterpartyName: 'Yaw Larbi', counterpartyId: 'APG-YL-00089', amount: 800, note: 'Weekly settlement', createdAt: DateTime.now().subtract(const Duration(days: 2))),
      ];
}

class ECashRequest {
  final String id;
  final String fromId;
  final String fromName;
  final double amount;
  final String? note;
  final DateTime createdAt;
  ECashRequestStatus status;

  ECashRequest({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.amount,
    this.note,
    required this.createdAt,
    this.status = ECashRequestStatus.pending,
  });

  static List<ECashRequest> demoPending() => [
        ECashRequest(id: '1', fromId: 'u1', fromName: 'Kwame Asante', amount: 2000, note: 'Float top-up for weekend', createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
        ECashRequest(id: '2', fromId: 'u2', fromName: 'Ama Boateng', amount: 500, note: 'Customer advance', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
        ECashRequest(id: '3', fromId: 'u3', fromName: 'Kofi Mensah', amount: 1200, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      ];
}
