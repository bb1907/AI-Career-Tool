import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/errors/app_exception.dart';
import 'pdf_text_extraction_service.dart';

class SyncfusionPdfTextExtractionService implements PdfTextExtractionService {
  const SyncfusionPdfTextExtractionService();

  @override
  Future<String> extractText(Uint8List bytes) async {
    try {
      final document = PdfDocument(inputBytes: bytes);
      final extractedText = PdfTextExtractor(document).extractText().trim();
      document.dispose();

      if (extractedText.isEmpty) {
        throw const AppException(
          'This PDF does not contain readable text. Try a text-based CV PDF.',
        );
      }

      return extractedText;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('The PDF could not be read. Try another file.');
    }
  }
}
