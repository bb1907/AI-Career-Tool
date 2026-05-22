import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/skill_gap_result.dart';

class SkillGapListNotifier extends AsyncNotifier<List<SkillGapResult>> {
  static const _kResults = 'skill_gap_results';

  @override
  Future<List<SkillGapResult>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kResults);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(SkillGapResult.fromJson)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(SkillGapResult result) async {
    final current = state.asData?.value ?? [];
    final updated = [result, ...current];
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> delete(String id) async {
    final current = state.asData?.value ?? [];
    final updated = current.where((r) => r.id != id).toList();
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> _persist(List<SkillGapResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kResults,
      jsonEncode(results.map((r) => r.toJson()).toList()),
    );
  }
}

final skillGapListProvider =
    AsyncNotifierProvider<SkillGapListNotifier, List<SkillGapResult>>(
      SkillGapListNotifier.new,
    );
