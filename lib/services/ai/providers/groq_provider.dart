import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';

/// Groq — ultra-fast inference via OpenAI-compatible API.
/// Primary for: chat responses, skill suggestions, networking messages.
class GroqProvider implements AiProvider {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final String _apiKey;
  final http.Client _http;

  GroqProvider(this._apiKey, {http.Client? client})
    : _http = client ?? http.Client();

  @override
  String get name => 'Groq';

  @override
  bool get isAvailable => _apiKey.isNotEmpty && _apiKey != 'placeholder';

  // ── Core call ────────────────────────────────────────────────────────────

  Future<String> _call(
    List<Map<String, String>> messages, {
    bool jsonMode = false,
    double temperature = 0.7,
  }) async {
    final body = <String, dynamic>{
      'model': _model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': 4096,
    };
    if (jsonMode) body['response_format'] = {'type': 'json_object'};

    final response = await _http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      final err = _tryDecodeError(response.body);
      throw AiProviderException(
        provider: name,
        message: err,
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['choices'][0]['message']['content'] as String;
  }

  // ── AiProvider interface ─────────────────────────────────────────────────

  @override
  Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    bool jsonMode = false,
    double temperature = 0.7,
  }) {
    return _call(
      [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  @override
  Future<String> generateChat({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) {
    return _call(messages, temperature: temperature);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _tryDecodeError(String body) {
    try {
      final m = jsonDecode(body) as Map<String, dynamic>;
      return (m['error'] as Map?)?['message'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}
