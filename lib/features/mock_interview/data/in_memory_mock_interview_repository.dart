import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/mock_interview_session.dart';

class MockInterviewListNotifier
    extends AsyncNotifier<List<MockInterviewSession>> {
  static const _kSessions = 'mock_interview_sessions';

  @override
  Future<List<MockInterviewSession>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessions);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(MockInterviewSession.fromJson)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(MockInterviewSession session) async {
    final current = state.asData?.value ?? [];
    final updated = [session, ...current];
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> updateSession(MockInterviewSession session) async {
    final current = state.asData?.value ?? [];
    final updated = current
        .map((s) => s.id == session.id ? session : s)
        .toList();
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> delete(String id) async {
    final current = state.asData?.value ?? [];
    final updated = current.where((s) => s.id != id).toList();
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> _persist(List<MockInterviewSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSessions,
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }
}

final mockInterviewListProvider =
    AsyncNotifierProvider<
      MockInterviewListNotifier,
      List<MockInterviewSession>
    >(MockInterviewListNotifier.new);
