class UploadedCvRecordModel {
  const UploadedCvRecordModel({
    required this.id,
    required this.fileName,
    required this.storagePath,
    required this.status,
  });

  final String id;
  final String fileName;
  final String storagePath;
  final String status;

  factory UploadedCvRecordModel.fromJson(Map<String, dynamic> json) {
    return UploadedCvRecordModel(
      id: json['id'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      storagePath: json['storage_path'] as String? ?? '',
      status: json['parsing_status'] as String? ?? '',
    );
  }
}
