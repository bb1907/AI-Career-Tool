/// Simple heuristic language detector for mock/fallback AI responses.
/// Used only when the real API is unavailable. Real API auto-detects via system prompt.
class MockLangDetector {
  /// Detect language from text input. Returns a language code like 'tr', 'es', 'en'.
  static String detect(String text) {
    if (text.isEmpty) return 'en';
    // Turkish: ç ş ğ ü ö ı İ Ğ Ş Ç Ö Ü
    if (RegExp(r'[çşğüöıİĞŞÇÖÜ]').hasMatch(text)) return 'tr';
    // Spanish: ñ ¿ ¡ á é í ó ú (excluding Portuguese overlap)
    if (RegExp(r'[ñ¿¡]').hasMatch(text)) return 'es';
    // German: ä ö ü ß (also check for common German words)
    if (RegExp(r'[äöüß]').hasMatch(text)) return 'de';
    // French: French specific patterns
    if (RegExp(r'[àâæœéèêëùûîïôÿ]').hasMatch(text)) return 'fr';
    // Russian/Ukrainian Cyrillic
    if (RegExp(r'[\u0400-\u04FF]').hasMatch(text)) return 'ru';
    // Arabic
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'ar';
    // Chinese
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) return 'zh';
    // Japanese (Hiragana/Katakana)
    if (RegExp(r'[\u3040-\u30FF]').hasMatch(text)) return 'ja';
    // Korean
    if (RegExp(r'[\uAC00-\uD7AF]').hasMatch(text)) return 'ko';
    return 'en';
  }

  /// Returns a mock cover letter in the detected/specified language.
  static String coverLetter({
    required String lang,
    required String company,
    required String role,
    required String keywordLine,
    required String tone,
  }) {
    switch (lang) {
      case 'tr':
        final selamlama = tone == 'friendly'
            ? 'Merhaba,'
            : 'Sayın İşe Alım Yetkilisi,';
        final acilis = tone == 'confident'
            ? '$company şirketindeki $role pozisyonu için en uygun aday benim.'
            : '$company şirketindeki $role pozisyonuna başvurmak için yazıyorum.';
        return '''$selamlama

$acilis $keywordLine Kariyerim boyunca çapraz fonksiyonlu ekiplerle etkin bir şekilde iş birliği yaparken tutarlı biçimde yüksek kaliteli sonuçlar elde ettim.

Önceki rollerimde karmaşık sorunları çözme ve anlamlı sonuçlar elde etme konusunda kanıtlanmış bir sicil oluşturdum. Özellikle $company şirketine, sektördeki inovasyon anlayışı ve mükemmeliyete olan bağlılığı nedeniyle ilgi duyuyorum.

Uzmanlığımı ekibinize katma değer olarak sunmak ve $companyın süregelen başarısına katkıda bulunmak için sabırsızlanıyorum. Geçmişim ve bu role olan tutkumun şirketinizin hedefleriyle nasıl örtüştüğünü tartışmaktan memnuniyet duyarım.

Başvurumu değerlendirdiğiniz için teşekkür ederim. Sizinle görüşme fırsatı bulmayı umuyorum.

Saygılarımla,
[Adınız]''';

      case 'es':
        final saludo = tone == 'friendly'
            ? 'Hola,'
            : 'Estimado/a Responsable de Selección,';
        final apertura = tone == 'confident'
            ? 'Soy el candidato ideal para el puesto de $role en $company.'
            : 'Me dirijo a usted para expresar mi interés en el puesto de $role en $company.';
        return '''$saludo

$apertura $keywordLine A lo largo de mi carrera, he demostrado una capacidad constante para obtener resultados de alta calidad colaborando eficazmente con equipos multifuncionales.

En mis roles anteriores, he desarrollado un historial probado de resolución de problemas complejos y generación de resultados significativos. Me atrae especialmente $company por su reputación de innovación y compromiso con la excelencia en el sector.

Estoy entusiasmado/a por la oportunidad de aportar mi experiencia a su equipo y contribuir al éxito continuo de $company. Me encantaría tener la oportunidad de hablar sobre cómo mi perfil se alinea con los objetivos de este puesto.

Gracias por considerar mi candidatura. Espero poder hablar con usted pronto.

Atentamente,
[Su Nombre]''';

      case 'de':
        final anrede = tone == 'friendly'
            ? 'Guten Tag,'
            : 'Sehr geehrte Damen und Herren,';
        final einleitung = tone == 'confident'
            ? 'Ich bin der ideale Kandidat für die Stelle als $role bei $company.'
            : 'Hiermit bewerbe ich mich um die Stelle als $role bei $company.';
        return '''$anrede

$einleitung $keywordLine In meiner bisherigen Karriere habe ich stets qualitativ hochwertige Ergebnisse erzielt und effektiv mit funktionsübergreifenden Teams zusammengearbeitet.

In meinen vorherigen Positionen habe ich nachweislich komplexe Probleme gelöst und bedeutende Erfolge erzielt. Ich bin besonders von $company begeistert, da das Unternehmen für Innovation und Exzellenz in der Branche bekannt ist.

Ich freue mich auf die Möglichkeit, mein Fachwissen in Ihr Team einzubringen und zum weiteren Erfolg von $company beizutragen.

Mit freundlichen Grüßen,
[Ihr Name]''';

      case 'fr':
        final salutation = tone == 'friendly'
            ? 'Bonjour,'
            : 'Madame, Monsieur,';
        final ouverture = tone == 'confident'
            ? 'Je suis le candidat idéal pour le poste de $role chez $company.'
            : 'Je vous écris pour manifester mon vif intérêt pour le poste de $role chez $company.';
        return '''$salutation

$ouverture $keywordLine Tout au long de ma carrière, j'ai démontré une capacité constante à fournir des résultats de haute qualité tout en collaborant efficacement avec des équipes pluridisciplinaires.

Dans mes fonctions précédentes, j'ai développé une expérience prouvée dans la résolution de problèmes complexes. Je suis particulièrement attiré(e) par $company en raison de sa réputation d'innovation et d'excellence.

Je serais ravi(e) de rejoindre votre équipe et de contribuer au succès de $company. N'hésitez pas à me contacter pour un entretien.

Cordialement,
[Votre Nom]''';

      default: // 'en' and all others
        final greeting = tone == 'friendly'
            ? 'Hi there,'
            : 'Dear Hiring Manager,';
        final opening = tone == 'confident'
            ? 'I am the ideal candidate for the $role position at $company.'
            : 'I am writing to express my strong interest in the $role position at $company.';
        return '''$greeting

$opening $keywordLine Throughout my career, I have demonstrated a consistent ability to deliver high-quality results while collaborating effectively with cross-functional teams.

In my previous roles, I have developed a proven track record of solving complex problems and driving meaningful outcomes. I am particularly drawn to $company because of its reputation for innovation and commitment to excellence in the industry.

I am excited about the opportunity to bring my expertise to your team and contribute to ${company}s continued success. I would welcome the chance to discuss how my background and enthusiasm align with the goals of this role.

Thank you for considering my application. I look forward to the opportunity to speak with you further.

Sincerely,
[Your Name]''';
    }
  }
}
