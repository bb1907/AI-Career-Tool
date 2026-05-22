import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/resume/domain/resume.dart';

class ResumePdfGenerator {
  static pw.Document generate(Resume resume, {bool watermark = false}) {
    final doc = pw.Document();

    // Color palette
    const primary = PdfColor.fromInt(0xFF5B5FEF);
    const textDark = PdfColor.fromInt(0xFF1F2937);
    const textGrey = PdfColor.fromInt(0xFF6B7280);
    const border = PdfColor.fromInt(0xFFE6E8EF);
    const accentTeal = PdfColor.fromInt(0xFF00C2A8);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          // ── Header ──────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: border, width: 1)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.personalInfo.fullName,
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    if (resume.personalInfo.email.isNotEmpty)
                      _contactChip(resume.personalInfo.email, textGrey),
                    if (resume.personalInfo.phone.isNotEmpty)
                      _contactChip(resume.personalInfo.phone, textGrey),
                    if (resume.personalInfo.location.isNotEmpty)
                      _contactChip(resume.personalInfo.location, textGrey),
                    if (resume.personalInfo.linkedIn != null)
                      _contactChip(resume.personalInfo.linkedIn!, primary),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Summary ───────────────────────────────────────────────────
          if (resume.summary.isNotEmpty) ...[
            _sectionTitle('SUMMARY', primary),
            pw.Text(
              resume.summary,
              style: pw.TextStyle(
                fontSize: 10,
                color: textDark,
                lineSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 14),
          ],

          // ── Experience ────────────────────────────────────────────────
          if (resume.workExperiences.isNotEmpty) ...[
            _sectionTitle('EXPERIENCE', primary),
            ...resume.workExperiences.map(
              (exp) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          exp.position,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          '${exp.startDate} – ${exp.isCurrent ? "Present" : (exp.endDate ?? "")}',
                          style: pw.TextStyle(fontSize: 9, color: textGrey),
                        ),
                      ],
                    ),
                    pw.Text(
                      exp.company,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: primary,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      exp.description,
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: textDark,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 4),
          ],

          // ── Education ─────────────────────────────────────────────────
          if (resume.educations.isNotEmpty) ...[
            _sectionTitle('EDUCATION', primary),
            ...resume.educations.map(
              (edu) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${edu.degree} in ${edu.field}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          '${edu.startDate} – ${edu.endDate ?? "Present"}',
                          style: pw.TextStyle(fontSize: 9, color: textGrey),
                        ),
                      ],
                    ),
                    pw.Text(
                      edu.institution,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: primary,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (edu.gpa != null)
                      pw.Text(
                        'GPA: ${edu.gpa}',
                        style: pw.TextStyle(fontSize: 9, color: textGrey),
                      ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 4),
          ],

          // ── Skills ────────────────────────────────────────────────────
          if (resume.skills.isNotEmpty) ...[
            _sectionTitle('SKILLS', primary),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: resume.skills
                  .map(
                    (s) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: accentTeal.shade(0.08),
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                          color: accentTeal.shade(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: pw.Text(
                        s.name,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: accentTeal,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 14),
          ],

          // ── Projects ──────────────────────────────────────────────────
          if (resume.projects.isNotEmpty) ...[
            _sectionTitle('PROJECTS', primary),
            ...resume.projects.map(
              (p) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      p.name,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    pw.Text(
                      p.description,
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: textDark,
                        lineSpacing: 1.5,
                      ),
                    ),
                    if (p.technologies.isNotEmpty)
                      pw.Text(
                        p.technologies.join(' · '),
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: primary,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],

          // ── Watermark footer ──────────────────────────────────────────
          if (watermark) ...[
            pw.SizedBox(height: 24),
            pw.Divider(
              thickness: 0.5,
              color: const PdfColor.fromInt(0xFFE6E8EF),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'Made with AI Career Copilot — Upgrade to remove watermark',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: const PdfColor.fromInt(0xFF9CA3AF),
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Divider(thickness: 0.5, color: const PdfColor.fromInt(0xFFE6E8EF)),
          pw.SizedBox(height: 6),
        ],
      ),
    );
  }

  static pw.Widget _contactChip(String text, PdfColor color) {
    return pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color));
  }
}
