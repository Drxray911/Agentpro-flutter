import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/app_exception.dart';

/// Base URL for the Agent Pro Ghana API (spec §5).
/// Override via --dart-define=API_BASE_URL=https://api.agentproghana.com/v1
const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.agentproghana.com/v1',
);

const _storage = FlutterSecureStorage();
const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

/// Provides the configured Dio instance app-wide.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.addAll([
    _AuthInterceptor(dio),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});

/// Injects the JWT access token on every request and handles 401 by
/// attempting a silent token refresh before retrying once (spec §6.1).
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for login / refresh endpoints
    if (options.path.contains('/auth/login') || options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }
    final token = await _storage.read(key: _kAccessToken);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: _kRefreshToken);
        if (refreshToken == null) throw AppException.unauthorized();

        final resp = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
        final newAccess = resp.data['access_token'] as String;
        final newRefresh = resp.data['refresh_token'] as String;

        await _storage.write(key: _kAccessToken, value: newAccess);
        await _storage.write(key: _kRefreshToken, value: newRefresh);

        // Retry original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        final retried = await _dio.fetch(err.requestOptions);
        return handler.resolve(retried);
      } catch (_) {
        // Refresh failed → clear tokens, force re-login
        await _storage.deleteAll();
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: AppException.unauthorized(),
        ));
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}

/// Token storage helpers — called by AuthRepository after login/logout.
class TokenStore {
  static Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccessToken, value: access);
    await _storage.write(key: _kRefreshToken, value: refresh);
  }

  static Future<void> clear() async => await _storage.deleteAll();

  static Future<String?> get accessToken => _storage.read(key: _kAccessToken);
}
