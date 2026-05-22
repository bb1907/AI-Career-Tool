/// Thrown when a provider call fails.
class AiProviderException implements Exception {
  final String provider;
  final String message;
  final int? statusCode;

  const AiProviderException({
    required this.provider,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() =>
      '[$provider] $message${statusCode != null ? " (HTTP $statusCode)" : ""}';
}

/// Thrown when every provider in the fallback chain fails.
class AiRouterException implements Exception {
  final String message;
  final List<AiProviderException> errors;

  const AiRouterException(this.message, {this.errors = const []});

  @override
  String toString() =>
      'AiRouterException: $message\n${errors.map((e) => '  • $e').join('\n')}';
}

/// Unified interface every AI provider must implement.
abstract class AiProvider {
  /// Human-readable provider name for logging / debugging.
  String get name;

  /// Whether this provider has a valid API key configured.
  bool get isAvailable;

  /// Single system+user prompt → text response.
  Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    bool jsonMode = false,
    double temperature = 0.7,
  });

  /// Multi-turn chat history → next assistant message.
  /// Each message: {'role': 'user'|'assistant'|'system', 'content': '...'}
  Future<String> generateChat({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  });
}
