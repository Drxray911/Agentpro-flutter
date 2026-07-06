/// Domain models for Customers (spec §3.9, §4.1).
library customer_models;

enum KycStatus { verified, unverified, pending }
enum IdType { ghanaCard, voterId, passport, nhis }

extension IdTypeX on IdType {
  String get label {
    switch (this) {
      case IdType.ghanaCard: return 'Ghana Card';
      case IdType.voterId: return 'Voter ID';
      case IdType.passport: return 'Passport';
      case IdType.nhis: return 'NHIS Card';
    }
  }
}

class Customer {
  final String id;
  final String businessId;
  final String fullName;
  final String phone;
  final IdType? idType;
  final String? idNumber;
  final String? photoUrl;
  final KycStatus kycStatus;
  final int totalTransactions;
  final double totalVolume;
  final DateTime? lastTransactionAt;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.businessId,
    required this.fullName,
    required this.phone,
    this.idType,
    this.idNumber,
    this.photoUrl,
    required this.kycStatus,
    required this.totalTransactions,
    required this.totalVolume,
    this.lastTransactionAt,
    required this.createdAt,
  });

  String get initials => fullName.isNotEmpty ? fullName[0] : '?';
  bool get isVerified => kycStatus == KycStatus.verified;

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        businessId: j['business_id'] as String,
        fullName: j['full_name'] as String,
        phone: j['phone'] as String,
        kycStatus: KycStatus.values.firstWhere((s) => s.name == j['kyc_status'], orElse: () => KycStatus.unverified),
        totalTransactions: j['total_transactions'] as int? ?? 0,
        totalVolume: (j['total_volume'] as num? ?? 0).toDouble(),
        lastTransactionAt: j['last_transaction_at'] != null ? DateTime.parse(j['last_transaction_at'] as String) : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  static List<Customer> demoList() => [
        Customer(id: '1', businessId: 'b1', fullName: 'Ama Boateng', phone: '0244 567 890', kycStatus: KycStatus.verified, totalTransactions: 48, totalVolume: 24800, lastTransactionAt: DateTime.now().subtract(const Duration(hours: 1)), createdAt: DateTime(2025, 1)),
        Customer(id: '2', businessId: 'b1', fullName: 'Kofi Mensah', phone: '0551 234 567', kycStatus: KycStatus.verified, totalTransactions: 32, totalVolume: 15600, lastTransactionAt: DateTime.now().subtract(const Duration(days: 1)), createdAt: DateTime(2025, 2)),
        Customer(id: '3', businessId: 'b1', fullName: 'Akua Sarpong', phone: '0277 890 123', kycStatus: KycStatus.unverified, totalTransactions: 8, totalVolume: 3200, lastTransactionAt: DateTime.now().subtract(const Duration(days: 3)), createdAt: DateTime(2025, 4)),
        Customer(id: '4', businessId: 'b1', fullName: 'Yaw Darko', phone: '0264 321 654', kycStatus: KycStatus.verified, totalTransactions: 21, totalVolume: 11400, lastTransactionAt: DateTime.now().subtract(const Duration(days: 2)), createdAt: DateTime(2025, 3)),
        Customer(id: '5', businessId: 'b1', fullName: 'Abena Mensah', phone: '0244 000 111', kycStatus: KycStatus.pending, totalTransactions: 3, totalVolume: 900, lastTransactionAt: DateTime.now().subtract(const Duration(days: 7)), createdAt: DateTime(2025, 6)),
      ];
}
