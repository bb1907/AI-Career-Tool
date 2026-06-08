import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// FASHN AI — Virtual try-on service.
/// Docs: https://fashn.ai/docs
///
/// Fallback: OpenAI image editing (gpt-image-1 / dall-e-2)
/// Demo mode: Returns original image after simulated delay.
class AiPhotoService {
  final String _fashnKey;
  final String _openAiKey;

  static const _fashnBase = 'https://api.fashn.ai/v1';
  static const _openAiBase = 'https://api.openai.com/v1';

  const AiPhotoService({required String fashnKey, required String openAiKey})
    : _fashnKey = fashnKey,
      _openAiKey = openAiKey;

  bool get hasFashn => _valid(_fashnKey);
  bool get hasOpenAi => _valid(_openAiKey);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generate a professional-looking photo.
  /// Returns the resulting image as raw bytes (JPEG or PNG).
  Future<Uint8List> generateProfessionalPhoto({
    required Uint8List imageBytes,
    required String jobType,
    required String outfitDescription,
    required String garmentImageUrl,
    required String garmentCategory,
  }) async {
    // 1. FASHN API (real try-on with garment image)
    if (hasFashn) {
      try {
        return await _fashnGenerate(
          imageBytes: imageBytes,
          garmentImageUrl: garmentImageUrl,
          category: garmentCategory,
        );
      } catch (_) {
        // fall through
      }
    }

    // 2. OpenAI image editing (text-based outfit change)
    if (hasOpenAi) {
      try {
        return await _openAiGenerate(
          imageBytes: imageBytes,
          outfitDescription: outfitDescription,
        );
      } catch (_) {
        // fall through
      }
    }

    // 3. Demo mode — simulate processing, return original
    await Future.delayed(const Duration(seconds: 4));
    return imageBytes;
  }

  // ---------------------------------------------------------------------------
  // FASHN API
  // ---------------------------------------------------------------------------

  Future<Uint8List> _fashnGenerate({
    required Uint8List imageBytes,
    required String garmentImageUrl,
    required String category,
  }) async {
    // Submit job
    final base64Image = base64Encode(imageBytes);
    final submitRes = await http.post(
      Uri.parse('$_fashnBase/run'),
      headers: {
        'Authorization': 'Bearer $_fashnKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model_image': 'data:image/jpeg;base64,$base64Image',
        'garment_image': garmentImageUrl,
        'category': category,
        'mode': 'performance',
        'nsfw_filter': true,
      }),
    );

    if (submitRes.statusCode != 200) {
      throw Exception(
        'FASHN submit error ${submitRes.statusCode}: ${submitRes.body}',
      );
    }

    final submitData = jsonDecode(submitRes.body) as Map<String, dynamic>;
    final predId = submitData['id'] as String;

    // Poll for result (max 60 seconds)
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final statusRes = await http.get(
        Uri.parse('$_fashnBase/status/$predId'),
        headers: {'Authorization': 'Bearer $_fashnKey'},
      );

      if (statusRes.statusCode != 200) continue;

      final statusData = jsonDecode(statusRes.body) as Map<String, dynamic>;
      final status = statusData['status'] as String? ?? '';

      if (status == 'completed') {
        final output = statusData['output'] as List?;
        if (output == null || output.isEmpty) {
          throw Exception('FASHN: empty output');
        }
        final imageUrl = output.first as String;
        return _downloadBytes(imageUrl);
      } else if (status == 'failed') {
        throw Exception('FASHN failed: ${statusData['error']}');
      }
      // still processing — keep polling
    }

    throw Exception('FASHN timeout');
  }

  // ---------------------------------------------------------------------------
  // OpenAI image editing fallback
  // ---------------------------------------------------------------------------

  Future<Uint8List> _openAiGenerate({
    required Uint8List imageBytes,
    required String outfitDescription,
  }) async {
    final prompt =
        'Professional headshot. Keep the person\'s face, hairstyle, and '
        'background exactly the same. Change only the clothing/outfit to: '
        '$outfitDescription. Maintain professional studio lighting.';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_openAiBase/images/edits'),
    );
    request.headers['Authorization'] = 'Bearer $_openAiKey';
    request.fields['model'] = 'gpt-image-1';
    request.fields['prompt'] = prompt;
    request.fields['n'] = '1';
    request.fields['size'] = '1024x1024';

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'photo.png',
        contentType: MediaType('image', 'png'),
      ),
    );

    final streamedRes = await request.send();
    final body = await streamedRes.stream.bytesToString();

    if (streamedRes.statusCode != 200) {
      throw Exception(
        'OpenAI image edit error ${streamedRes.statusCode}: $body',
      );
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final imageData = (data['data'] as List).first as Map<String, dynamic>;

    // gpt-image-1 returns b64_json by default
    if (imageData.containsKey('b64_json')) {
      return base64Decode(imageData['b64_json'] as String);
    }

    // dall-e-2 may return a URL
    final url = imageData['url'] as String?;
    if (url != null) return _downloadBytes(url);

    throw Exception('OpenAI: no image data in response');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<Uint8List> _downloadBytes(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Download failed: ${res.statusCode}');
    }
    return res.bodyBytes;
  }

  static bool _valid(String key) => key.isNotEmpty && key != 'placeholder';
}
