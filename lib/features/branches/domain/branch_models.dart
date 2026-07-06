/// Domain models for Branches & Staff (spec §3.8, §4.1).
library branch_models;

/// Maps to the `branches` table (spec §4.1).
class Branch {
  final String id;
  final String businessId;
  final String name;
  final String? location;
  final String? region;
  final String status; // 'active' | 'inactive'
  final DateTime? openedAt;
  final int agentCount;
  final double totalFloat;

  const Branch({
    required this.id,
    required this.businessId,
    required this.name,
    this.location,
    this.region,
    required this.status,
    this.openedAt,
    this.agentCount = 0,
    this.totalFloat = 0,
  });

  bool get isActive => status == 'active';

  factory Branch.fromJson(Map<String, dynamic> j) => Branch(
        id: j['id'] as String,
        businessId: j['business_id'] as String,
        name: j['name'] as String,
        location: j['location'] as String?,
        region: j['region'] as String?,
        status: j['status'] as String? ?? 'active',
        openedAt: j['opened_at'] != null ? DateTime.parse(j['opened_at'] as String) : null,
        agentCount: j['agent_count'] as int? ?? 0,
        totalFloat: (j['total_float'] as num? ?? 0).toDouble(),
      );

  static List<Branch> demoList() => [
        Branch(id: '1', businessId: 'b1', name: 'Accra Central', location: 'Kwame Nkrumah Ave, Accra', region: 'Greater Accra', status: 'active', agentCount: 4, totalFloat: 12400, openedAt: DateTime(2025, 1)),
        Branch(id: '2', businessId: 'b1', name: 'Tema Station', location: 'Community 1, Tema', region: 'Greater Accra', status: 'active', agentCount: 3, totalFloat: 7400, openedAt: DateTime(2025, 3)),
        Branch(id: '3', businessId: 'b1', name: 'Kumasi Kejetia', location: 'Kejetia Market, Kumasi', region: 'Ashanti', status: 'active', agentCount: 5, totalFloat: 16100, openedAt: DateTime(2025, 2)),
        Branch(id: '4', businessId: 'b1', name: 'Takoradi Market', location: 'Market Circle, Takoradi', region: 'Western', status: 'inactive', agentCount: 2, totalFloat: 3500, openedAt: DateTime(2025, 6)),
      ];
}

/// A staff member (agent or manager) listed under a branch.
class StaffMember {
  final String id;
  final String fullName;
  final String phone;
  final String role; // 'agent' | 'manager' | 'auditor'
  final String branchId;
  final String branchName;
  final String status; // 'active' | 'suspended' | 'invited'
  final int todayTransactions;
  final double todayCommission;

  const StaffMember({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.branchId,
    required this.branchName,
    required this.status,
    this.todayTransactions = 0,
    this.todayCommission = 0,
  });

  bool get isActive => status == 'active';
  String get initials => fullName.isNotEmpty ? fullName[0] : '?';

  factory StaffMember.fromJson(Map<String, dynamic> j) => StaffMember(
        id: j['id'] as String,
        fullName: j['full_name'] as String,
        phone: j['phone'] as String,
        role: j['role'] as String,
        branchId: j['branch_id'] as String? ?? '',
        branchName: j['branch_name'] as String? ?? '',
        status: j['status'] as String? ?? 'active',
        todayTransactions: j['today_transactions'] as int? ?? 0,
        todayCommission: (j['today_commission'] as num? ?? 0).toDouble(),
      );

  static List<StaffMember> demoList() => [
        const StaffMember(id: '1', fullName: 'Kwame Asante', phone: '0244 000 000', role: 'agent', branchId: '1', branchName: 'Accra Central', status: 'active', todayTransactions: 18, todayCommission: 237.50),
        const StaffMember(id: '2', fullName: 'Ama Boateng', phone: '0551 234 567', role: 'agent', branchId: '1', branchName: 'Accra Central', status: 'active', todayTransactions: 14, todayCommission: 185.00),
        const StaffMember(id: '3', fullName: 'Kofi Mensah', phone: '0244 987 654', role: 'agent', branchId: '2', branchName: 'Tema Station', status: 'active', todayTransactions: 7, todayCommission: 94.50),
        const StaffMember(id: '4', fullName: 'Akosua Mensah', phone: '0277 321 000', role: 'manager', branchId: '1', branchName: 'Accra Central', status: 'active', todayTransactions: 0, todayCommission: 0),
        const StaffMember(id: '5', fullName: 'Yaw Larbi', phone: '0264 567 890', role: 'agent', branchId: '3', branchName: 'Kumasi Kejetia', status: 'suspended', todayTransactions: 0, todayCommission: 0),
      ];
}
