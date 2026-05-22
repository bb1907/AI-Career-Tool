class AppError implements Exception {
  final String message;
  final String? code;
  const AppError({required this.message, this.code});

  @override
  String toString() => 'AppError($code): $message';

  static const AppError unauthorized = AppError(
    message: 'Unauthorized',
    code: 'unauthorized',
  );
  static const AppError notFound = AppError(
    message: 'Not found',
    code: 'not_found',
  );
}
