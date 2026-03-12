import 'dart:typed_data';

class CvUploadFile {
  const CvUploadFile({
    required this.fileName,
    required this.bytes,
    required this.sizeInBytes,
    this.mimeType = 'application/pdf',
  });

  final String fileName;
  final Uint8List bytes;
  final int sizeInBytes;
  final String mimeType;
}
