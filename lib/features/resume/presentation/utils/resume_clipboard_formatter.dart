import '../../domain/entities/resume_result.dart';

abstract final class ResumeClipboardFormatter {
  static String format(ResumeResult result) {
    final buffer = StringBuffer()
      ..writeln('Professional Summary')
      ..writeln(result.summary)
      ..writeln()
      ..writeln('Experience Highlights');

    for (final bullet in result.experienceBullets) {
      buffer.writeln('- $bullet');
    }

    buffer
      ..writeln()
      ..writeln('Skills')
      ..writeln(result.skills.join(', '))
      ..writeln()
      ..writeln('Education')
      ..writeln(result.education);

    return buffer.toString().trim();
  }
}
