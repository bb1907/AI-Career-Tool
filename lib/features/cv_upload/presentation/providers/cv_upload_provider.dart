import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/uploaded_cv.dart';

class UploadedCVNotifier extends Notifier<UploadedCV?> {
  @override
  UploadedCV? build() => null;

  void set(UploadedCV cv) => state = cv;

  void clear() => state = null;
}

final uploadedCVProvider = NotifierProvider<UploadedCVNotifier, UploadedCV?>(
  UploadedCVNotifier.new,
);
