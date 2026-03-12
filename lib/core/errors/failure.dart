class Failure implements Exception {
  const Failure(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}
