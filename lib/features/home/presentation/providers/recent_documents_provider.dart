import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../history/application/history_controller.dart';
import '../../../history/domain/entities/history_snapshot.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/entities/resume_result.dart';

final recentDocumentsProvider = FutureProvider.autoDispose
    .family<RecentDocumentsState, String>((ref, userId) async {
      ref.watch(
        authControllerProvider.select(
          (state) => state.session?.userId == userId,
        ),
      );

      final snapshot = await ref
          .watch(historyRepositoryProvider)
          .fetchHistory();
      return RecentDocumentsState.fromSnapshot(snapshot);
    });

class RecentDocumentsState {
  const RecentDocumentsState({
    this.items = const [],
    this.hasSectionErrors = false,
  });

  factory RecentDocumentsState.fromSnapshot(
    HistorySnapshot snapshot, {
    int limit = 5,
  }) {
    final allItems = <RecentDocumentItem>[
      ...snapshot.resumes.items.map(RecentDocumentItem.fromResume),
      ...snapshot.coverLetters.items.map(RecentDocumentItem.fromCoverLetter),
      ...snapshot.interviewSets.items.map(RecentDocumentItem.fromInterview),
    ]..sort((left, right) => right.sortKey.compareTo(left.sortKey));

    return RecentDocumentsState(
      items: allItems.take(limit).toList(growable: false),
      hasSectionErrors: snapshot.hasAnyError,
    );
  }

  final List<RecentDocumentItem> items;
  final bool hasSectionErrors;

  bool get isEmpty => items.isEmpty;
}

class RecentDocumentItem {
  const RecentDocumentItem({
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.route,
    required this.icon,
    required this.sortKey,
  });

  factory RecentDocumentItem.fromResume(ResumeResult result) {
    final summary = result.summary.trim();
    return RecentDocumentItem(
      title: summary.isEmpty ? 'Saved resume draft' : summary,
      subtitle:
          '${result.experienceBullets.length} bullets • ${result.skills.length} skills',
      typeLabel: 'Resume',
      route: AppRoutes.resume,
      icon: Icons.description_outlined,
      sortKey: result.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory RecentDocumentItem.fromCoverLetter(CoverLetterResult result) {
    final preview = result.coverLetter.replaceAll('\n', ' ').trim();
    return RecentDocumentItem(
      title: preview.isEmpty ? 'Saved cover letter draft' : preview,
      subtitle: 'Tailored letter draft',
      typeLabel: 'Cover Letter',
      route: AppRoutes.coverLetter,
      icon: Icons.edit_note_outlined,
      sortKey: result.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory RecentDocumentItem.fromInterview(InterviewResult result) {
    final technicalQuestions = result.technicalQuestions;
    final behavioralQuestions = result.behavioralQuestions;
    final title = technicalQuestions.isNotEmpty
        ? technicalQuestions.first.question
        : behavioralQuestions.isNotEmpty
        ? behavioralQuestions.first.question
        : 'Saved interview set';

    return RecentDocumentItem(
      title: title,
      subtitle:
          '${technicalQuestions.length} technical • ${behavioralQuestions.length} behavioral',
      typeLabel: 'Interview Set',
      route: AppRoutes.interview,
      icon: Icons.record_voice_over_outlined,
      sortKey: result.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String title;
  final String subtitle;
  final String typeLabel;
  final String route;
  final IconData icon;
  final DateTime sortKey;
}
