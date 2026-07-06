/// The five user roles defined in the Developer Specification, Section 2.
enum UserRole { superuser, owner, manager, agent, auditor }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.superuser:
        return 'Superuser';
      case UserRole.owner:
        return 'Business Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.agent:
        return 'Agent';
      case UserRole.auditor:
        return 'Auditor';
    }
  }

  /// Whether this role can initiate Mobile Money transactions.
  bool get canTransact => this == UserRole.agent;

  /// Whether this role has read-only access across the platform.
  bool get isReadOnly => this == UserRole.auditor;
}
