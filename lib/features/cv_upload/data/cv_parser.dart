import '../domain/uploaded_cv.dart';

/// Helpers for converting AI router output into a [ParsedProfile].
///
/// The actual parsing happens in the AI router (Gemini multimodal for files,
/// Gemini Flash-Lite / OpenAI text models for pasted text). This class only flattens the
/// structured JSON the router returns into the simple [ParsedProfile] shape
/// that the existing UI consumes.
class CvParser {
  /// Convert the AI router's CV JSON response into a [ParsedProfile].
  static ParsedProfile fromAiResponse(Map<String, dynamic> data) {
    final skills = (data['skills'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final experiences = <String>[];
    final rawExp = data['workExperiences'] as List<dynamic>? ?? [];
    for (final raw in rawExp) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final position = (m['position'] ?? '').toString().trim();
      final company = (m['company'] ?? '').toString().trim();
      final start = (m['startDate'] ?? '').toString().trim();
      final isCurrent = m['isCurrent'] == true;
      final endRaw = (m['endDate'] ?? '').toString().trim();
      final end = isCurrent ? 'Present' : endRaw;
      final description = (m['description'] ?? '').toString().trim();

      final header = [
        position,
        if (company.isNotEmpty) 'at $company',
      ].where((p) => p.isNotEmpty).join(' ');
      final period = [start, end].where((p) => p.isNotEmpty).join('–');
      final headerWithPeriod = period.isEmpty ? header : '$header ($period)';
      final line = description.isEmpty
          ? headerWithPeriod
          : '$headerWithPeriod — $description';
      if (line.trim().isNotEmpty) experiences.add(line);
    }

    final education = <String>[];
    final rawEdu = data['education'] as List<dynamic>? ?? [];
    for (final raw in rawEdu) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final degree = (m['degree'] ?? '').toString().trim();
      final field = (m['field'] ?? '').toString().trim();
      final institution = (m['institution'] ?? '').toString().trim();
      final start = (m['startDate'] ?? '').toString().trim();
      final end = (m['endDate'] ?? '').toString().trim();
      final period = [start, end].where((p) => p.isNotEmpty).join('–');
      final head = [
        if (degree.isNotEmpty) degree,
        if (field.isNotEmpty) 'in $field',
        if (institution.isNotEmpty) ', $institution',
      ].join(' ').replaceAll(' ,', ',').trim();
      final line = period.isEmpty ? head : '$head ($period)';
      if (line.trim().isNotEmpty) education.add(line);
    }

    final summary = (data['summary'] ?? '').toString().trim();

    return ParsedProfile(
      skills: skills,
      experiences: experiences,
      education: education,
      summary: summary.isEmpty ? null : summary,
    );
  }
}
