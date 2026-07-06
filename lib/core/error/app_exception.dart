/// Typed exceptions thrown by repositories and caught by presentation layer.
/// Avoids leaking raw DioException / SocketException into UI code.
class AppException implements Exception {
  final String message;
  final AppExceptionType type;

  const AppException._(this.type, this.message);

  factory AppException.network() =>
      const AppException._(AppExceptionType.network, 'No internet connection. Please check your network.');

  factory AppException.unauthorized() =>
      const AppException._(AppExceptionType.unauthorized, 'Session expired. Please sign in again.');

  factory AppException.server(String? msg) =>
      AppException._(AppExceptionType.server, msg ?? 'Server error. Please try again.');

  factory AppException.notFound(String resource) =>
      AppException._(AppExceptionType.notFound, '$resource not found.');

  factory AppException.validation(String msg) =>
      AppException._(AppExceptionType.validation, msg);

  factory AppException.fromDio(Object error) {
    // Imported inline to avoid pulling dio into every file that uses AppException
    final type = error.runtimeType.toString();
    if (type.contains('DioException')) {
      final code = (error as dynamic).response?.statusCode as int?;
      final msg = (error as dynamic).response?.data?['message'] as String?;
      switch (code) {
        case 401:
          return AppException.unauthorized();
        case 404:
          return AppException.notFound('Resource');
        case 422:
          return AppException.validation(msg ?? 'Invalid input');
        default:
          if (code == null) return AppException.network();
          return AppException.server(msg);
      }
    }
    return AppException.network();
  }

  @override
  String toString() => message;
}

enum AppExceptionType { network, unauthorized, server, notFound, validation }
