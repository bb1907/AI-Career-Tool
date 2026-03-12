import 'dart:typed_data';

abstract class PdfTextExtractionService {
  Future<String> extractText(Uint8List bytes);
}
