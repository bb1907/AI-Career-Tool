import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/job_plan.dart';
import '../../../../services/ai/ai_router.dart';
import 'job_plan_list_provider.dart';

const _uuid = Uuid();

class JobPlanNotifier extends AsyncNotifier<JobPlan?> {
  static const _kCurrentPlan = 'job_plan_current';

  @override
  Future<JobPlan?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCurrentPlan);
    if (raw == null) return null;
    try {
      return JobPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> analyze(String jobDescription) async {
    state = const AsyncLoading();
    try {
      final aiRouter = ref.read(aiRouterProvider);
      final result = await aiRouter.analyzeJobPlan(
        jobDescription: jobDescription,
      );
      final plan = JobPlan(
        id: _uuid.v4(),
        jobDescription: jobDescription,
        role: result['role'] as String? ?? 'Unknown Role',
        company: result['company'] as String? ?? 'Unknown Company',
        matchScore: (result['matchScore'] as num?)?.toInt() ?? 0,
        matchingSkills: (result['matchingSkills'] as List<dynamic>? ?? [])
            .cast<String>(),
        missingSkills: (result['missingSkills'] as List<dynamic>? ?? [])
            .cast<String>(),
        sector: result['sector'] as String? ?? 'corporate',
        photoRecommendation:
            result['photoRecommendation'] as String? ??
            'Professional attire recommended',
        createdAt: DateTime.now(),
      );
      await _persist(plan);
      // Also save to history list
      await ref.read(jobPlanListProvider.notifier).add(plan);
      state = AsyncData(plan);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleChecklist(String key) async {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = switch (key) {
      'resumeTailored' => current.copyWith(
        resumeTailored: !current.resumeTailored,
      ),
      'coverLetterWritten' => current.copyWith(
        coverLetterWritten: !current.coverLetterWritten,
      ),
      'photoUpdated' => current.copyWith(photoUpdated: !current.photoUpdated),
      'interviewPrepped' => current.copyWith(
        interviewPrepped: !current.interviewPrepped,
      ),
      'networkingMessageSent' => current.copyWith(
        networkingMessageSent: !current.networkingMessageSent,
      ),
      _ => current,
    };
    await _persist(updated);
    // Sync with history list
    await ref.read(jobPlanListProvider.notifier).updatePlan(updated);
    state = AsyncData(updated);
  }

  Future<void> _persist(JobPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentPlan, jsonEncode(plan.toJson()));
  }
}

final jobPlanProvider = AsyncNotifierProvider<JobPlanNotifier, JobPlan?>(
  JobPlanNotifier.new,
);
