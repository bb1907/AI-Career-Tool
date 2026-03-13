class CoverLetterClarifyingContext {
  const CoverLetterClarifyingContext({
    required this.whyThisCompany,
    required this.keyAchievement,
    required this.emphasisNotes,
  });

  final String whyThisCompany;
  final String keyAchievement;
  final String emphasisNotes;

  bool get hasContent =>
      whyThisCompany.trim().isNotEmpty ||
      keyAchievement.trim().isNotEmpty ||
      emphasisNotes.trim().isNotEmpty;
}
