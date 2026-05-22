import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';

/// Gemini — primary content-generation + CV parsing provider.
/// Uses Google Generative Language REST API (no SDK needed).
///
/// Pass [model] to select the specific Gemini variant:
///   • 'gemini-2.5-flash'       — standard content generation (default)
///   • 'gemini-2.5-flash-lite'  — lightweight parse / suggestion tasks
///   • 'gemini-2.5-pro'         — flagship quality for Pro Max tier
class GeminiProvider implements AiProvider {
  static const _baseHost =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final String _apiKey;
  final String _model;
  final http.Client _http;

  /// URL for non-streaming generateContent on the selected model.
  String get _generateUrl => '$_baseHost/$_model:generateContent';

  GeminiProvider(
    this._apiKey, {
    String model = 'gemini-2.5-flash',
    http.Client? client,
  }) : _model = model,
       _http = client ?? http.Client();

  @override
  String get name => 'Gemini';

  @override
  bool get isAvailable => _apiKey.isNotEmpty && _apiKey != 'placeholder';

  /// Parses a binary file (PDF, image) using Gemini's multimodal input.
  /// Returns the model's text response.
  Future<String> generateFromBytes({
    required String systemPrompt,
    required String userPrompt,
    required Uint8List bytes,
    required String mimeType,
    bool jsonMode = true,
  }) async {
    final body = <String, dynamic>{
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Encode(bytes),
              },
            },
            {'text': userPrompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 8192,
        if (jsonMode) 'response_mime_type': 'application/json',
      },
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
    };

    final uri = Uri.parse('$_generateUrl?key=$_apiKey');
    final response = await _http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw AiProviderException(
        provider: name,
        message: _tryDecodeError(response.body),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw AiProviderException(
        provider: name,
        message: 'Gemini returned no candidates',
      );
    }
    final parts = (candidates[0]['content']?['parts'] as List<dynamic>?) ?? [];
    if (parts.isEmpty) {
      throw AiProviderException(
        provider: name,
        message: 'Gemini returned empty parts',
      );
    }
    return parts[0]['text'] as String;
  }

  // ── Core call ────────────────────────────────────────────────────────────

  Future<String> _call(
    String? systemPrompt,
    List<Map<String, dynamic>> contents, {
    bool jsonMode = false,
    double temperature = 0.7,
  }) async {
    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': 8192,
        if (jsonMode) 'response_mime_type': 'application/json',
      },
      if (systemPrompt != null)
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
    };

    final uri = Uri.parse('$_generateUrl?key=$_apiKey');
    final response = await _http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      final err = _tryDecodeError(response.body);
      throw AiProviderException(
        provider: name,
        message: err,
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>;
    final parts = (candidates[0]['content']['parts'] as List<dynamic>);
    return parts[0]['text'] as String;
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
      systemPrompt,
      [
        {
          'role': 'user',
          'parts': [
            {'text': userPrompt},
          ],
        },
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
    // Extract system message if present (Gemini handles it separately)
    String? systemPrompt;
    final chatMessages = <Map<String, dynamic>>[];

    for (final msg in messages) {
      if (msg['role'] == 'system') {
        systemPrompt = msg['content'];
        continue;
      }
      // Gemini uses 'model' for assistant role
      final role = msg['role'] == 'assistant' ? 'model' : 'user';
      chatMessages.add({
        'role': role,
        'parts': [
          {'text': msg['content']},
        ],
      });
    }

    return _call(systemPrompt, chatMessages, temperature: temperature);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _tryDecodeError(String body) {
    try {
      final m = jsonDecode(body) as Map<String, dynamic>;
      final err = m['error'] as Map?;
      return err?['message'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}
