import '../../shared/models/user_role.dart';

/// The authenticated user entity, populated after a successful login.
/// Maps to the `users` table (spec §4.1).
class AuthUser {
  final String id;
  final String businessId;
  final UserRole role;
  final String fullName;
  final String phone;
  final String? email;
  final String? profilePhotoUrl;
  final String? branchId;
  final String? branchName;
  final bool biometricEnabled;

  const AuthUser({
    required this.id,
    required this.businessId,
    required this.role,
    required this.fullName,
    required this.phone,
    this.email,
    this.profilePhotoUrl,
    this.branchId,
    this.branchName,
    this.biometricEnabled = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as String,
        businessId: j['business_id'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => UserRole.agent,
        ),
        fullName: j['full_name'] as String,
        phone: j['phone'] as String,
        email: j['email'] as String?,
        profilePhotoUrl: j['profile_photo_url'] as String?,
        branchId: j['branch_id'] as String?,
        branchName: j['branch_name'] as String?,
        biometricEnabled: j['biometric_enabled'] as bool? ?? false,
      );
}

class LoginRequest {
  final String phone;
  final String password;

  const LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {'phone': phone, 'password': password};
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        accessToken: j['access_token'] as String,
        refreshToken: j['refresh_token'] as String,
        user: AuthUser.fromJson(j['user'] as Map<String, dynamic>),
      );
}
