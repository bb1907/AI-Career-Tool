class AppException implements Exception {
  const AppException(this.message, {this.code, this.isRetryable = false});

  final String message;
  final String? code;
  final bool isRetryable;

  @override
  String toString() => message;
}
