import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/auth_models.dart';
import '../../../shared/models/user_role.dart';

/// Repository wiring spec §5.1 auth endpoints.
class AuthRepository {
  final Dio _dio;

  const AuthRepository(this._dio);

  /// POST /auth/login
  Future<LoginResponse> login(LoginRequest req) async {
    try {
      final resp = await _dio.post('/auth/login', data: req.toJson());
      final loginResp = LoginResponse.fromJson(resp.data as Map<String, dynamic>);
      await TokenStore.save(
        access: loginResp.accessToken,
        refresh: loginResp.refreshToken,
      );
      return loginResp;
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }

  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await TokenStore.clear();
    }
  }

  /// POST /auth/forgot-password
  Future<void> forgotPassword(String phone) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'phone': phone});
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }

  /// POST /auth/verify-email
  Future<void> verifyEmail(String otp) async {
    try {
      await _dio.post('/auth/verify-email', data: {'otp': otp});
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);

/// Holds the currently logged-in user.
/// Null = not authenticated.
final currentUserProvider = StateProvider<AuthUser?>((ref) => null);

/// Convenience: resolves role from currentUserProvider or falls back to
/// the demo-mode currentRoleProvider (used while real auth isn't wired).
final resolvedRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentUserProvider)?.role ?? UserRole.agent;
});
