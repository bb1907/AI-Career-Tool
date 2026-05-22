import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/job_plan.dart';

class JobPlanListNotifier extends AsyncNotifier<List<JobPlan>> {
  static const _kPlans = 'job_plan_list';

  @override
  Future<List<JobPlan>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPlans);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(JobPlan.fromJson)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(JobPlan plan) async {
    final current = state.asData?.value ?? [];
    final updated = [plan, ...current];
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> delete(String id) async {
    final current = state.asData?.value ?? [];
    final updated = current.where((p) => p.id != id).toList();
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> updatePlan(JobPlan plan) async {
    final current = state.asData?.value ?? [];
    final updated = current.map((p) => p.id == plan.id ? plan : p).toList();
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> _persist(List<JobPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPlans,
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }
}

final jobPlanListProvider =
    AsyncNotifierProvider<JobPlanListNotifier, List<JobPlan>>(
      JobPlanListNotifier.new,
    );
