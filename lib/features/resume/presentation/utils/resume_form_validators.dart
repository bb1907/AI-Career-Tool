import 'resume_form_parser.dart';

abstract final class ResumeFormValidators {
  static String? requiredEntries(String? value, {required String fieldName}) {
    final entries = ResumeFormParser.parseEntries(value ?? '');

    if (entries.isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }
}
